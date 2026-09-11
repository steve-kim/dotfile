vim.opt.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

local function session_file()
  local session_dir = vim.fn.stdpath('data') .. '/sessions'
  local name = vim.fn.getcwd():gsub('/', '%%')
  return session_dir .. '/' .. name .. '.vim'
end

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    local f = session_file()
    if vim.fn.filereadable(f) == 1 and vim.fn.argc() == 0 then
      vim.cmd('source ' .. f)
    end
  end,
})

vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    local session_dir = vim.fn.stdpath('data') .. '/sessions'
    vim.fn.mkdir(session_dir, 'p')
    vim.cmd('mksession! ' .. session_file())
  end,
})

vim.opt.expandtab  = true
vim.opt.tabstop    = 4
vim.opt.shiftwidth = 4
vim.opt.hidden     = true
vim.opt.autoread   = true
vim.opt.swapfile   = false
vim.opt.confirm    = true
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
