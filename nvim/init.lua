vim.g.mapleader = ' '

require('config.plugins')   -- bootstraps lazy.nvim and loads non-lazy plugins
require('config.settings')
require('config.keymaps')
require('config.lsp')
require('config.ui')
-- treesitter is configured via its plugin spec's config function
