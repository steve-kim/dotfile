local map = vim.keymap.set

-- Terminal
map('t', '<esc><esc>', '<C-\\><C-N>')

-- Buffer navigation
map('n', '<leader>T',  ':enew<CR>')
map('n', '<leader>l',  ':bnext<CR>')
map('n', '<leader>h',  ':bprevious<CR>')
map('n', '<leader>bq', ':bp <BAR> bd #<CR>')
map('n', '<leader>bl', ':ls<CR>')

-- Telescope
map('n', '<leader>ff', '<Cmd>Telescope find_files<CR>')
map('n', '<leader>fg', '<Cmd>Telescope live_grep<CR>')
map('n', '<leader>fb', '<Cmd>Telescope buffers<CR>')
map('n', '<leader>fs', '<Cmd>Telescope lsp_document_symbols<CR>')
map('n', '<leader>fe', '<Cmd>Telescope file_browser<CR>')
map('n', '<leader>fk', '<Cmd>Telescope keymaps<CR>')

-- CodeCompanion
map({ 'n', 'v' }, '<leader>cc', '<Cmd>CodeCompanion<CR>',     { desc = 'CodeCompanion inline' })
map({ 'n', 'v' }, '<leader>ca', '<Cmd>CodeCompanionChat<CR>', { desc = 'CodeCompanion chat' })
map('n',          '<leader>ct', '<Cmd>CodeCompanionChat Toggle<CR>', { desc = 'Toggle chat' })

-- Worktrees
map('n', '<leader>ww', '<Cmd>Telescope git_worktree git_worktree<CR>', { desc = 'Switch worktree' })
map('n', '<leader>wc', function()
  local main = vim.fn.system('git worktree list --porcelain | head -1'):match('worktree (.+)\n')
  require('telescope').extensions.git_worktree.create_git_worktree({ cwd = main })
end, { desc = 'Create worktree' })
-- <leader>wo registered in worktree.lua
