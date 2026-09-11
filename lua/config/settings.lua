vim.opt.expandtab  = true
vim.opt.tabstop    = 4
vim.opt.shiftwidth = 4
vim.opt.hidden     = true
vim.opt.signcolumn = 'yes'
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust', 'c', 'cpp', 'lua', 'python', 'toml' },
  callback = function()
    vim.treesitter.start()
    vim.opt_local.foldmethod    = 'expr'
    vim.opt_local.foldexpr      = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt_local.foldlevelstart = 99
  end,
})
