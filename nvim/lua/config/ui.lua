-- Options: nord, catppuccin, catppuccin-latte, catppuccin-frappe,
--          catppuccin-macchiato, catppuccin-mocha,
--          nightfox, dayfox, dawnfox, duskfox, nordfox, carbonfox, terafox
vim.cmd('colorscheme catppuccin-mocha')

vim.g['airline#extensions#tabline#enabled']  = 1
vim.g['airline#extensions#tabline#fnamemod'] = ':t'
vim.g['airline#extensions#nvimlsp#enabled']  = 1
