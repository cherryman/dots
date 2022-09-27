local api, fn, keymap, lsp = vim.api, vim.fn, vim.keymap, vim.lsp
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
  use 'nvim-telescope/telescope.nvim'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'mfussenegger/nvim-dap'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use { 'JoosepAlviste/nvim-ts-context-commentstring', branch = 'main' }
  use 'TimUntersberger/neogit'
  use 'kdheepak/lazygit.nvim'
  use 'kristijanhusak/orgmode.nvim'
  use 'ggandor/leap.nvim'
  use 'kyazdani42/nvim-tree.lua'
end).install()

vim.o.runtimepath = '~/.vim,' .. vim.o.runtimepath .. ',~/.vim/after'
vim.o.packpath = vim.o.runtimepath
vim.cmd('source ~/.vimrc')

vim.cmd [[
  sign define DiagnosticSignInformation text=- texthl=Todo linehl= numhl=
  sign define DiagnosticSignHint text=* texthl=Todo linehl= numhl=
  sign define DiagnosticSignWarning text=* texthl=Todo linehl= numhl=
  sign define DiagnosticSignError text=> texthl=WarningMsg linehl= numhl=
]]

function applyall(f, as)
  for _, a in ipairs(as) do
    f(unpack(a))
  end
end

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
  textobjects = {
    select = {
      enable = true,
      include_surrounding_whitespace = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
      },
      selection_modes = {
        ['@function.inner'] = 'V',
        ['@function.outer'] = 'V',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
      },
    },
  },
  context_commentstring = {
    enable = true,
    enable_autocmd = false,
    commentary_integration = {
      Commentary = false,
      CommentaryLine = false,
      ChangeCommentary = false,
      CommentaryUndo = false,
    }
  },
}

require('nvim-tree').setup {
  sort_by = "case_sensitive",
  hijack_cursor = true,
  renderer = {
    special_files = {},
    icons = {
      git_placement = "after",
      symlink_arrow = " -> ",
      padding = "",
      glyphs = {
        default = "",
        symlink = "",
        bookmark = "",
        folder = {
          arrow_closed = "+",
          arrow_open = "-",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
          symlink_open = "",
        },
        git = {
          unstaged = "M",
          staged = "M",
          unmerged = "U",
          renamed = "R",
          untracked = "?",
          deleted = "D",
          ignored = "-",
        },
      },
    },
  },
  view = {
    width = 28,
    mappings = {
      custom_only = true,
      list = {
        { key = { "<CR>", "o", "<2-LeftMouse>", "l" }, action = "edit" },
        { key = "<F5>", action = "refresh" },
        { key = "h", action = "close_node" },
        { key = "d", action = "remove" },
        { key = "q", action = "close" },
        { key = "r", action = "rename" },
        { key = "N", action = "create" },
        { key = "K", action = "toggle_file_info" },
      },
    },
  },
  git = {
    ignore = false,
  },
}

local cmp = require('cmp')
cmp.setup({
    mapping = {
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
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

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = require("telescope.actions").close,
        ["<C-u>"] = false,
      },
    },
    layout_config = {
      horizontal = {
        width = 0.95,
        height = 0.95,
        preview_width = 0.6,
      },
    },
  },
})

require("null-ls").setup({
    sources = {
        require("null-ls").builtins.diagnostics.shellcheck,
    },
})

local lspconfig = require('lspconfig')
local lspattach = function(client, bufnr)
  keymap.set('n', 'gd', lsp.buf.definition, { buffer = bufnr })
  keymap.set('n', 'K', lsp.buf.hover, { buffer = bufnr })
  keymap.set('n', 'gt', lsp.buf.type_definition, { buffer = bufnr })
  keymap.set({'n', 'i'}, '<C-s>', lsp.buf.signature_help, { buffer = bufnr })

  if client.resolved_capabilities.declaration then
    keymap.set('n', 'gD', lsp.buf.declaration, { buffer = bufnr })
  else
    keymap.set('n', 'gD', lsp.buf.definition, { buffer = bufnr })
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

applyall(
  function(lsp)
    if type(lsp) == 'table' then
      lspconfig[lsp[1]].setup(lsp[2])
    else
      lspconfig[lsp].setup({})
    end
  end,
  {
    { {'elixirls', {cmd = {'elixir-ls'}}} },
    { 'pyright' },
    {
      {'rust_analyzer', {
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = 'clippy'
            }
          }
        }
      }}
    },
    { 'texlab' },
    { 'tsserver' },
    { 'zls' },
  }
)

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

function comment_aux(mapping)
  return function()
    pcall(require('ts_context_commentstring.internal').update_commentstring)
    return '<Plug>' .. mapping
  end
end

-- leap setup
require('leap').set_default_keymaps()
vim.g.surround_no_mappings = 1

applyall(keymap.set, {
  { 'n', 'ds', '<Plug>Dsurround' },
  { 'n', 'cs', '<Plug>Csurround' },
  { 'n', 'cS', '<Plug>CSurround' },
  { 'n', 'ys', '<Plug>Ysurround' },
  { 'n', 'yS', '<Plug>YSurround' },
  { 'n', 'yss', '<Plug>Yssurround' },
  { 'n', 'ySs', '<Plug>YSsurround' },
  { 'n', 'ySS', '<Plug>YSsurround' },
  { 'x', 'S', '<Plug>VSurround' },
  { 'x', 'gS', '<Plug>VgSurround' },

  { {'n', 'v', 'o'}, 'gc', comment_aux('Commentary'), { expr = true, remap = true } },
  { {'n', 'v', 'o'}, 'gy', comment_aux('(CommentaryYank)'), { expr = true, remap = true } },
  { 'n', 'gcc', comment_aux('CommentaryLine'), { expr = true, remap = true } },
  { 'n', 'gyy', comment_aux('(CommentaryYankLine)'), { expr = true, remap = true } },
  { 'n', 'cgc', comment_aux('ChangeCommentary'), { expr = true, remap = true } },

  { 'n', ' ft', require('nvim-tree').focus },
  { 'n', ' ff', require('telescope.builtin').find_files },
  { 'n', ' fb', require('telescope.builtin').buffers },
  { 'n', ' fg', require('telescope.builtin').live_grep },

  { 'n', ' lr', require('telescope.builtin').lsp_references },
  { 'n', ' lR', lsp.buf.rename },
  { 'n', ' ld', function() require('telescope.builtin').diagnostics({ bufnr = 0}) end },
  { 'n', ' lD', require('telescope.builtin').diagnostics },

  { 'n', ' d ', dap.toggle_breakpoint },
  { 'n', ' ds', dap.close },
  { 'n', ' dc', dap.continue },
  { 'n', ' dr', dap.repl.open },
  { 'n', ' di', dap_widgets.hover },

  { 'n', 'gs', neogit.open },
  { 'n', 'gl', function() neogit.open({'log'}) end },
  { 'n', 'gm', '<Plug>(git-messenger)' },

  { 'n', ' tl', togglelsp },
  { 'n', '[t', '<cmd>tabprev<CR>' },
  { 'n', ']t', '<cmd>tabnext<CR>' },
  { 'n', '[c', '<cmd>GitGutterPrevHunk<CR>' },
  { 'n', ']c', '<cmd>GitGutterNextHunk<CR>' },
  { 'n', '[d', vim.diagnostic.goto_prev },
  { 'n', ']d', vim.diagnostic.goto_next },

  { 'n', '<A-J>', dap.step_over },
  { 'n', '<A-H>', dap.step_out },
  { 'n', '<A-L>', dap.step_into },
})
