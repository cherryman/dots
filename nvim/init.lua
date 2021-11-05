local api = vim.api
local fn = vim.fn
local lsp = vim.lsp

function merge(x, y)
  return vim.tbl_extend("force", x, y)
end

function termcode(x)
  return api.nvim_replace_termcodes(x, true, true, true)
end

-- Using several tricks from https://www.lua.org/pil/20.html.
function splitunquoted(s)
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

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone',
    'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd('packadd packer.nvim')
end

require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim' -- common dependency
  use 'nvim-lua/popup.nvim' -- telescope.nvim
  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/completion-nvim'
  use 'mfussenegger/nvim-dap'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-dap.nvim'
  use 'folke/which-key.nvim'
  use 'sindrets/diffview.nvim'
  use 'TimUntersberger/neogit'
  use 'kristijanhusak/orgmode.nvim'
  use 'tjdevries/astronauta.nvim'
end).install()

require('astronauta.keymap')

vim.o.runtimepath = '~/.vim,' .. vim.o.runtimepath .. ',~/.vim/after'
vim.o.packpath = vim.o.runtimepath
vim.cmd('source ~/.vimrc')

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

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<Esc>"] = require('telescope.actions').close,
      },
    },
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        width = 0.95,
        height = 0.95,
        preview_width = 0.55,
      },
    },
  },
}
require('telescope').load_extension('dap')

local diffview_cb = require('diffview.config').diffview_callback
require('diffview').setup {
  file_panel = {
    use_icons = false,
  },
  key_bindings = {
    view = {
      ['q'] = diffview_cb('focus_files'),
    },
    file_panel = {
      ['q'] = ':DiffviewClose<CR>',
    },
  },
}

vim.g.completion_enable_auto_popup = 0
vim.g.completion_confirm_key = ''

vim.cmd [[
  sign define LspDiagnosticsSignInformation text=- texthl=Todo linehl= numhl=
  sign define LspDiagnosticsSignHint text=* texthl=Todo linehl= numhl=
  sign define LspDiagnosticsSignWarning text=* texthl=Todo linehl= numhl=
  sign define LspDiagnosticsSignError text=> texthl=WarningMsg linehl= numhl=
]]

local lspconfig = require('lspconfig')
local lspattach = function(client, bufnr)
  local function nmap(x)
    vim.keymap.nnoremap(merge(x, { buffer = bufnr }))
  end

  local function iremap(x)
    vim.keymap.imap(merge(x, { buffer = bufnr }))
  end

  require('completion').on_attach(client, bufnr)

  api.nvim_buf_set_var(bufnr, 'ale_enabled', 0)
  api.nvim_buf_set_var(bufnr, 'ale_disable_lsp', 1)
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  nmap { 'gd', lsp.buf.definition }
  nmap { 'K', lsp.buf.hover }
  iremap { '<C-space>', '<Plug>(completion_trigger)' }

  if client.resolved_capabilities.declaration then
    nmap { 'gD', lsp.buf.declaration }
  else
    nmap { 'gD', lsp.buf.definition }
  end

  require('which-key').register({
    ['<Leader>l'] = {
      r = { vim.lsp.buf.rename, 'Rename' },
      R = { require('telescope.builtin').lsp_references, 'References' },
      D = { lsp.buf.type_definition, 'Type definition' },
    },
    ['[d'] = { vim.lsp.diagnostic.goto_prev, 'Previous error' },
    [']d'] = { vim.lsp.diagnostic.goto_next, 'Next error' },
  }, { buffer = bufnr })
end

local function lspenabled(_bufnr, _client_id)
  return vim.api.nvim_get_var('ale_enabled') ~= 0
end

lspconfig.util.default_config = merge(
  lspconfig.util.default_config,
  {
    on_attach = lspattach,
    handlers = {
      -- Disable diagnostics
      ['textDocument/publishDiagnostics'] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          virtual_text = false,
          underline = lspenabled,
          signs = lspenabled,
        }
      ),
    }
  }
)

local lspservers = {
  {'elixirls', {cmd = {'elixir-ls'}}},
  'pyright',
  'rust_analyzer',
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
      return splitunquoted(fn.input('Args: '))
    end,
  },
}

local dap_widgets = require('dap.ui.widgets')
local telescope = require('telescope.builtin')
local telescope_ext = require('telescope').extensions
local neogit = require('neogit')

local nmap = vim.keymap.nnoremap
local remap = vim.keymap.map
local nremap = vim.keymap.nmap

function _G.comment_run(mapping)
  pcall(require('ts_context_commentstring.internal')
    .update_commentstring)
  return termcode('<Plug>' .. mapping)
end

remap { 'gc', 'v:lua.comment_run("Commentary")', expr = true }
remap { 'gy', 'v:lua.comment_run("(CommentaryYank)")', expr = true  }
nremap { 'gcc', 'v:lua.comment_run("CommentaryLine")', expr = true  }
nremap { 'gyy', 'v:lua.comment_run("(CommentaryYankLine)")', expr = true  }
nremap { 'cgc', 'v:lua.comment_run("ChangeCommentary")', expr = true  }
nmap { '<A-J>', dap.step_over }
nmap { '<A-H>', dap.step_out }
nmap { '<A-L>', dap.step_into }

require('which-key').register({
  ['<Leader>f'] = {
    name = "find",
    f = { telescope.find_files, 'Find files' },
    g = { telescope.live_grep, 'Live grep' },
    b = { telescope.buffers, 'Buffers' },
    t = 'Tree',
  },
  ['<Leader>d'] = {
    name = "debug",
    [' '] = { dap.toggle_breakpoint, 'Toggle breakpoint' },
    s = { dap.close, 'Stop' },
    c = { dap.continue, 'Continue' },
    r = { dap.repl.open, 'Open repl' },
    i = { dap_widgets.hover, 'Info' },
    f = { telescope_ext.dap.frames, 'View callframe' },
    b = { telescope_ext.dap.list_breakpoints, 'List breakpoints' },
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
  },
  ['<leader>w'] = {
    name = 'window',
    v = 'which_key_ignore',
    s = 'which_key_ignore',
  },
  ['[t'] = { ':tabprev<CR>', 'Previous tab' },
  [']t'] = { ':tabnext<CR>', 'Next tab' },
  ['[c'] = { ':GitGutterPrevHunk<CR>', 'Previous hunk' },
  [']c'] = { ':GitGutterNextHunk<CR>', 'Next hunk' },
})
