require('nvim-treesitter-textobjects').setup({
  select = { lookahead = true },
  move   = { set_jumps = true },
})

local sel = require('nvim-treesitter-textobjects.select')
local mov = require('nvim-treesitter-textobjects.move')
local swp = require('nvim-treesitter-textobjects.swap')

vim.keymap.set({ 'x', 'o' }, 'af', function() sel.select_textobject('@function.outer', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'if', function() sel.select_textobject('@function.inner', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'ac', function() sel.select_textobject('@class.outer', 'textobjects') end)
vim.keymap.set({ 'x', 'o' }, 'ic', function() sel.select_textobject('@class.inner', 'textobjects') end)

vim.keymap.set({ 'n', 'x', 'o' }, ']f', function() mov.goto_next_start('@function.outer', 'textobjects') end)
vim.keymap.set({ 'n', 'x', 'o' }, '[f', function() mov.goto_previous_start('@function.outer', 'textobjects') end)

vim.keymap.set('n', '<leader>a', function() swp.swap_next('@parameter.inner') end)
vim.keymap.set('n', '<leader>A', function() swp.swap_previous('@parameter.inner') end)

require('Comment').setup()
