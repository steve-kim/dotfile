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

-- Worktrees
map('n', '<leader>ww', '<Cmd>Telescope git_worktree git_worktrees<CR>')
map('n', '<leader>wc', '<Cmd>Telescope git_worktree create_git_worktree<CR>')
-- <leader>wo registered in worktree.lua
