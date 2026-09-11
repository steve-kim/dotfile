local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', lazypath })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup(
  {
    -- LSP (non-lazy: needed at startup)
    { 'neovim/nvim-lspconfig' },
    { 'j-hui/fidget.nvim', config = true },

    -- Treesitter (lazy: config runs when plugin loads)
    {
      'nvim-treesitter/nvim-treesitter',
      event = 'BufReadPost',
      cmd = { 'TSUpdate', 'TSInstall', 'TSInstallInfo', 'TSUninstall' },
      build = ':TSUpdate',
      dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
      config = function() require('config.treesitter') end,
    },
    {
      'numToStr/Comment.nvim',
      event = 'BufReadPost',
      config = true,
    },

    -- Navigation (lazy: loaded on command/key)
    {
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-file-browser.nvim',
      },
      config = function()
        require('telescope').setup({
          defaults = {
            git_timeout = 15000,
          },
        })
        require('telescope').load_extension('file_browser')
        require('telescope').load_extension('git_worktree')
      end,
    },
    {
      'polarmutex/git-worktree.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function() require('config.worktree') end,
    },

    { 'christoomey/vim-tmux-navigator' },

    -- AI
    {
      'olimorris/codecompanion.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
      },
      config = function()
        local adapter
        if vim.env.AWS_ACCESS_KEY_ID or vim.env.AWS_PROFILE then
          adapter = 'bedrock'
        elseif vim.env.ANTHROPIC_API_KEY then
          adapter = 'anthropic'
        else
          adapter = nil
          vim.notify('CodeCompanion: no AI credentials found. Set ANTHROPIC_API_KEY or AWS credentials to enable.', vim.log.levels.WARN)
        end

        require('codecompanion').setup({
          adapters = {
            bedrock = function()
              return require('codecompanion.adapters').extend('bedrock', {
                schema = {
                  model = { default = 'anthropic.claude-sonnet-4-5' },
                },
              })
            end,
          },
          strategies = {
            chat   = { adapter = adapter or 'anthropic' },
            inline = { adapter = adapter or 'anthropic' },
          },
        })
      end,
    },
    { 'folke/which-key.nvim', event = 'VeryLazy' },

    -- UI (non-lazy)
    { 'arcticicestudio/nord-vim' },
    { 'catppuccin/nvim', name = 'catppuccin' },
    { 'EdenEast/nightfox.nvim' },
    { 'vim-airline/vim-airline' },
  },
  {
    rocks = { enabled = false },
  }
)
