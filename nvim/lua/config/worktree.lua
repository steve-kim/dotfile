local function open_in_tmux(path)
  vim.fn.system(string.format("tmux new-window -c '%s' 'nvim .'", path))
end

local function pick_worktree_for_tmux()
  local output = vim.fn.system('git worktree list --porcelain')
  local worktrees = {}
  for path, branch in output:gmatch('worktree ([^\n]+)\n[^\n]+\nbranch refs/heads/([^\n]+)') do
    table.insert(worktrees, { path = path, branch = branch })
  end
  require('telescope.pickers').new({}, {
    prompt_title = 'Open Worktree (new tmux window)',
    finder = require('telescope.finders').new_table({
      results = worktrees,
      entry_maker = function(e)
        return { value = e, display = e.branch .. '  ' .. e.path, ordinal = e.branch .. e.path }
      end,
    }),
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      require('telescope.actions').select_default:replace(function()
        local sel = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)
        open_in_tmux(sel.value.path)
      end)
      return true
    end,
  }):find()
end

-- Returns the Bazel output base for a given path, or nil if not a Bazel project.
-- Detection happens before deletion while the worktree directory still exists —
-- the delete hook fires after git removes the directory, so marker files are gone by then.
local function get_bazel_output_base(path)
  local markers = { 'WORKSPACE', 'WORKSPACE.bazel', 'MODULE.bazel' }
  for _, marker in ipairs(markers) do
    if vim.uv.fs_stat(path .. '/' .. marker) then
      local base = vim.fn.system(string.format('cd "%s" && bazel info output_base 2>/dev/null', path))
      return base:gsub('%s+$', '')  -- strip trailing newline
    end
  end
end

-- Build system cleanup on worktree delete:
--   Bazel: output base lives outside the worktree in ~/.cache/bazel/, so it must be
--          removed explicitly — git worktree remove won't touch it.
--   Cargo: target/ lives inside the worktree directory and is removed automatically
--          when git deletes the worktree, so no explicit cleanup is needed.
--
-- delete_worktree is not exported from the telescope extension (only git_worktree and
-- create_git_worktree are), so we build a custom picker that calls the underlying API directly.
local function pick_worktree_to_delete()
  local output = vim.fn.system('git worktree list --porcelain')
  local worktrees = {}
  for path, branch in output:gmatch('worktree ([^\n]+)\n[^\n]+\nbranch refs/heads/([^\n]+)') do
    table.insert(worktrees, { path = path, branch = branch })
  end
  require('telescope.pickers').new({}, {
    prompt_title = 'Delete Worktree',
    finder = require('telescope.finders').new_table({
      results = worktrees,
      entry_maker = function(e)
        return { value = e, display = e.branch .. '  ' .. e.path, ordinal = e.branch .. e.path }
      end,
    }),
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      require('telescope.actions').select_default:replace(function()
        local sel = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)
        local path = sel.value.path
        local bazel_base = get_bazel_output_base(path)
        local function do_delete(force)
          require('git-worktree').delete_worktree(path, force, {
            on_success = function()
              vim.schedule(function()
                if bazel_base and bazel_base ~= '' then
                  vim.fn.system(string.format('rm -rf "%s"', bazel_base))
                  vim.notify('Cleaned Bazel output base: ' .. bazel_base)
                end
              end)
            end,
            on_failure = function()
              vim.schedule(function()
                local ans = vim.fn.input('Worktree has uncommitted changes. Force delete? [y/n]: ')
                if ans == 'y' then
                  do_delete(true)
                else
                  vim.notify('Worktree deletion cancelled.', vim.log.levels.WARN)
                end
              end)
            end,
          })
        end
        do_delete(false)
      end)
      return true
    end,
  }):find()
end

vim.keymap.set('n', '<leader>wo', pick_worktree_for_tmux, { desc = 'Open worktree in new tmux window' })
vim.keymap.set('n', '<leader>wd', pick_worktree_to_delete, { desc = 'Delete worktree' })
