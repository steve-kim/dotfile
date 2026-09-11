vim.g.rustfmt_autosave = 1

local function pkg(hints)
  local managers = { 'brew', 'apt', 'dnf', 'pacman', 'zypper' }
  for _, m in ipairs(managers) do
    if vim.fn.executable(m) == 1 and hints[m] then return hints[m] end
  end
  return hints.default or '(see project docs)'
end

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    local tools = {
      { cmd = 'rust-analyzer', hint = pkg({ default = 'rustup component add rust-analyzer' }) },
      { cmd = 'clangd',        hint = pkg({ brew = 'brew install llvm', apt = 'sudo apt install clangd', dnf = 'sudo dnf install clang-tools-extra', pacman = 'sudo pacman -S clang' }) },
      { cmd = 'pyright',       hint = pkg({ brew = 'brew install pyright', default = 'npm install -g pyright' }) },
      { cmd = 'taplo',         hint = pkg({ brew = 'brew install taplo', default = 'cargo install taplo-cli' }) },
      { cmd = 'bear',          hint = pkg({ brew = 'brew install bear', apt = 'sudo apt install bear', dnf = 'sudo dnf install bear', pacman = 'sudo pacman -S bear' }) },
      { cmd = 'rg',            hint = pkg({ brew = 'brew install ripgrep', apt = 'sudo apt install ripgrep', dnf = 'sudo dnf install ripgrep', pacman = 'sudo pacman -S ripgrep' }) },
      { cmd = 'tree-sitter',   hint = pkg({ brew = 'brew install tree-sitter', default = 'cargo install tree-sitter-cli' }) },
    }
    local missing = {}
    for _, t in ipairs(tools) do
      if vim.fn.executable(t.cmd) == 0 then
        table.insert(missing, '  • ' .. t.cmd .. ' → ' .. t.hint)
      end
    end
    if #missing > 0 then
      vim.notify('Missing tools:\n' .. table.concat(missing, '\n'), vim.log.levels.WARN)
    end
  end,
})

local on_attach = function(_, bufnr)
  local map = function(keys, fn) vim.keymap.set('n', keys, fn, { buffer = bufnr, silent = true }) end
  map('gd',         vim.lsp.buf.definition)
  map('gt',         vim.lsp.buf.type_definition)
  map('gi',         vim.lsp.buf.implementation)
  map('gr',         vim.lsp.buf.references)
  map('K',          vim.lsp.buf.hover)
  map('GA',         vim.lsp.buf.code_action)
  map('<leader>rn', vim.lsp.buf.rename)
  map('<leader>e',  vim.diagnostic.open_float)
end

vim.lsp.config('*', { on_attach = on_attach })

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      procMacro = { enable = true },
      checkOnSave = { enable = false },
    }
  }
})

vim.lsp.enable({ 'rust_analyzer', 'clangd', 'pyright', 'taplo' })
