require('git-worktree').setup()

local function open_in_tmux(path)
  vim.fn.system(string.format("tmux new-window -c '%s' 'nvim .'", path))
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'GitWorktree',
  callback = function(ev)
    if ev.data.event == 'create' then
      open_in_tmux(ev.data.path)
    end
  end,
})

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

vim.keymap.set('n', '<leader>wo', pick_worktree_for_tmux)
