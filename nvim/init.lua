local api, fn, lsp = vim.api, vim.fn, vim.lsp
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone',
    'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd('packadd packer.nvim')
end

require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim' -- common dependency
  use 'nvim-lua/popup.nvim'
  use 'neovim/nvim-lspconfig'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'ojroques/nvim-lspfuzzy'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'mfussenegger/nvim-dap'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'folke/which-key.nvim'
  use 'sindrets/diffview.nvim'
  use 'TimUntersberger/neogit'
  use 'kristijanhusak/orgmode.nvim'
  use 'ggandor/lightspeed.nvim'
  use 'tjdevries/astronauta.nvim'
end).install()

require('astronauta.keymap')

vim.o.runtimepath = '~/.vim,' .. vim.o.runtimepath .. ',~/.vim/after'
vim.o.packpath = vim.o.runtimepath
vim.cmd('source ~/.vimrc')

function merge(x, y)
  return vim.tbl_extend("force", x, y)
end

function termcode(x)
  return api.nvim_replace_termcodes(x, true, true, true)
end

-- Using several tricks from https://www.lua.org/pil/20.html.
function shellsplit(s)
  -- Characters that can be '\' escaped.
  local esc = '\'"%s\\'

  -- Encode escaped characters as \ddd. Also encode
  -- \d to avoid any issues when decoding.
  s = string.gsub(s, '\\([' .. esc .. '%d])', function (c)
    return string.format('\\%03d', string.byte(c))
  end)

  -- Encode text within quotes. Spaces and quote
  -- characters are escaped. There is a leading
  -- '"' to handle empty strings.
  s = string.gsub(s, '([\'"])(.-)%1', function (_, t)
    t = string.gsub(t, '([\'"%s])', function (c)
      return string.format('\\%03d', string.byte(c))
    end)
    return '"' .. t
  end)

  local t = {}
  for w in string.gfind(s, '[^%s]+') do
    w = string.gsub(w, '"', '') -- remove added '"'
    w = string.gsub(w, '\\(%d%d%d)', function (c)
      return '\\' .. string.char(c)
    end)
    w = string.gsub(w, '\\([' .. esc .. '])', '%1')
    table.insert(t, w)
  end

  return t
end

require('nvim-treesitter.configs').setup {
  ensure_installed = "all",
  ignore_install = {},
  highlight = {
    enable = true,
    disable = {},
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
  },
}

local diffview_cb = require('diffview.config').diffview_callback
require('diffview').setup {
  key_bindings = {
    view = {
      ['q'] = diffview_cb('focus_files'),
    },
    file_panel = {
      ['q'] = ':DiffviewClose<CR>',
    },
  },
}

vim.cmd [[
  sign define DiagnosticSignInformation text=- texthl=Todo linehl= numhl=
  sign define DiagnosticSignHint text=* texthl=Todo linehl= numhl=
  sign define DiagnosticSignWarning text=* texthl=Todo linehl= numhl=
  sign define DiagnosticSignError text=> texthl=WarningMsg linehl= numhl=
]]

local cmp = require('cmp')
cmp.setup({
    mapping = {
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
    }),
    completion = {
      autocomplete = false,
    },
})

require('lspfuzzy').setup({})

require("null-ls").setup({
    sources = {
        require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.diagnostics.shellcheck,
    },
})

local lspconfig = require('lspconfig')
local lspattach = function(client, bufnr)
  local function nmap(x)
    vim.keymap.nnoremap(merge(x, { buffer = bufnr }))
  end

  local function iremap(x)
    vim.keymap.imap(merge(x, { buffer = bufnr }))
  end

  nmap { 'gd', lsp.buf.definition }
  nmap { 'K', lsp.buf.hover }
  nmap { 'gt', lsp.buf.type_definition }

  if client.resolved_capabilities.declaration then
    nmap { 'gD', lsp.buf.declaration }
  else
    nmap { 'gD', lsp.buf.definition }
  end
end

vim.g.linting = 0
vim.diagnostic.disable()

local function togglelsp()
  if vim.g.linting == 0 then
    vim.diagnostic.enable()
    vim.g.linting = 1
  else
    vim.diagnostic.disable()
    vim.g.linting = 0
  end
end

vim.diagnostic.config({
    virtual_text = false,
})
lspconfig.util.default_config = merge(
  lspconfig.util.default_config,
  {
    on_attach = lspattach,
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  }
)

local lspservers = {
  {'elixirls', {cmd = {'elixir-ls'}}},
  'pyright',
  'rls',
  'texlab',
  'tsserver',
  'zls',
}
for _, lsp in ipairs(lspservers) do
  if type(lsp) == 'table' then
    lspconfig[lsp[1]].setup(lsp[2])
  else
    lspconfig[lsp].setup({})
  end
end

local dap = require('dap')
dap.adapters.lldb = {
  type = 'executable',
  command = 'lldb-vscode',
  args = {},
}
dap.configurations.rust = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    runInTerminal = false,
    program = function()
      return fn.input('Executable: ', fn.getcwd() .. '/target/debug/', 'file')
    end,
    args = function()
      return shellsplit(fn.input('Args: '))
    end,
  },
}

local dap_widgets = require('dap.ui.widgets')
local neogit = require('neogit')

local nmap = vim.keymap.nnoremap
local remap = vim.keymap.map
local nremap = vim.keymap.nmap
local xremap = vim.keymap.xmap

function _G.comment_run(mapping)
  pcall(require('ts_context_commentstring.internal')
    .update_commentstring)
  return termcode('<Plug>' .. mapping)
end

-- lightspeed setup
vim.g.surround_no_mappings = 1
nremap { 'ds', '<Plug>Dsurround' }
nremap { 'cs', '<Plug>Csurround' }
nremap { 'cS', '<Plug>CSurround' }
nremap { 'ys', '<Plug>Ysurround' }
nremap { 'yS', '<Plug>YSurround' }
nremap { 'yss', '<Plug>Yssurround' }
nremap { 'ySs', '<Plug>YSsurround' }
nremap { 'ySS', '<Plug>YSsurround' }
xremap { 'S', '<Plug>VSurround' }
xremap { 'gS', '<Plug>VgSurround' }

remap { 'gc', 'v:lua.comment_run("Commentary")', expr = true }
remap { 'gy', 'v:lua.comment_run("(CommentaryYank)")', expr = true  }
nremap { 'gcc', 'v:lua.comment_run("CommentaryLine")', expr = true  }
nremap { 'gyy', 'v:lua.comment_run("(CommentaryYankLine)")', expr = true  }
nremap { 'cgc', 'v:lua.comment_run("ChangeCommentary")', expr = true  }
nmap { '<A-J>', dap.step_over }
nmap { '<A-H>', dap.step_out }
nmap { '<A-L>', dap.step_into }

require('which-key').setup({
    plugins = {
        presets = false,
    },
})
require('which-key').register({
  ['<Leader>f'] = {
    name = "find",
    f = 'Files',
    g = 'Grep',
    b = 'Buffers',
    t = 'Tree',
  },
  ['<Leader>d'] = {
    name = "debug",
    [' '] = { dap.toggle_breakpoint, 'Toggle breakpoint' },
    s = { dap.close, 'Stop' },
    c = { dap.continue, 'Continue' },
    r = { dap.repl.open, 'Open repl' },
    i = { dap_widgets.hover, 'Info' },
  },
  ['<Leader>g'] = {
    name = 'vcs',
    q = 'which_key_ignore',
    s = { neogit.open, 'Status' },
    l = { function() neogit.open({ 'log' }) end, 'Log' },
    d = { ':DiffviewOpen<CR>', 'Diff' },
    m = { '<Plug>(git-messenger)', 'Info' },
    h = { '<Plug>(GitGutterStageHunk)', 'Stage hunk' },
    H = { '<Plug>(GitGutterUndoHunk)', 'Undo stage hunk' },
  },
  ['<Leader>l'] = {
    name = 'code',
    a = { '<Plug>(EasyAlign)', 'Align' },
    r = { lsp.buf.references, 'References'},
    R = { vim.lsp.buf.rename, 'Rename' },
    d = { function() require('lspfuzzy').diagnostics(0) end, 'Diagnostics' },
    D = { require('lspfuzzy').diagnostics_all, 'Workspace diagnostics' },
  },
  ['<leader>w'] = {
    name = 'window',
    v = 'which_key_ignore',
    s = 'which_key_ignore',
  },
  ['<leader>t'] = {
    l = { togglelsp, 'Toggle linting' }
  },
  ['[t'] = { ':tabprev<CR>', 'Previous tab' },
  [']t'] = { ':tabnext<CR>', 'Next tab' },
  ['[c'] = { ':GitGutterPrevHunk<CR>', 'Previous hunk' },
  [']c'] = { ':GitGutterNextHunk<CR>', 'Next hunk' },
  ['[d'] = { vim.diagnostic.goto_prev, 'Previous error' },
  [']d'] = { vim.diagnostic.goto_next, 'Next error' },
})
