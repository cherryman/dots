local api, fn, keymap = vim.api, vim.fn, vim.keymap
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
  use 'nvim-neotest/nvim-nio' -- nvim-dap-ui
  use 'neovim/nvim-lspconfig'
  use 'mfussenegger/nvim-lint'
  use 'nvim-telescope/telescope.nvim'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use { 'L3MON4D3/LuaSnip', run = "make install_jsregexp" }
  use 'saadparwaiz1/cmp_luasnip'
  use {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup {
        suggestion = {
          enabled = true,
          auto_trigger = false,
          keymap = {
            accept = "<M-Enter>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = {
          enabled = false,
          auto_refresh = false,
        },
      }
    end,
  }
  use {
    -- "jackMort/ChatGPT.nvim",
    "~/contrib/chatgpt.nvim",
    config = function()
    end,
    requires = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim"
    },
  }
  use 'mfussenegger/nvim-dap'
  use 'theHamsta/nvim-dap-virtual-text'
  use 'rcarriga/nvim-dap-ui'
  -- 1ae9b0e4558fe7868f8cda2db65239cfb14836d0 breaks 'material.vim', need to fix
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', commit = '1ae9b0e4558fe7868f8cda2db65239cfb14836d0~' }
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  -- use { 'JoosepAlviste/nvim-ts-context-commentstring', branch = 'main' }
  use 'sindrets/diffview.nvim' -- neogit integration
  use 'NeogitOrg/neogit'
  use 'kristijanhusak/orgmode.nvim'
  use 'ggandor/leap.nvim'
  use 'kyazdani42/nvim-tree.lua'
  use { 'mrcjkb/rustaceanvim', config = function()
    vim.g.rustaceanvim = {
      tools = {
        reload_workspace_from_cargo_toml = false,
        hover_actions = { replace_builtin_hover = false },
      },
      dap = {
        executable = {
          args = { "--liblldb", "/usr/lib/liblldb.so", "--port", "${port}" },
          command = "codelldb"
        },
        host = "127.0.0.1",
        port = "${port}",
        type = "server"
      },
    }
  end}
  use { 'jpalardy/vim-slime', setup = function()
    -- https://github.com/jpalardy/vim-slime/blob/main/assets/doc/targets/tmux.md
    vim.g.slime_no_mappings = 1
    vim.g.slime_target = 'tmux'
    vim.g.slime_paste_file = vim.fn.stdpath('cache') .. '/_slime_paste'
    vim.g.slime_bracketed_paste = 1
    vim.g.slime_default_config = { socket_name = 'default', target_pane = '{last}' }
  end}
  use 'kaarmu/typst-palettes'
  use { 'ThePrimeagen/harpoon', branch = 'harpoon2' }
end).install()

vim.o.runtimepath = '~/.vim,' .. vim.o.runtimepath .. ',~/.vim/after'
vim.o.packpath = vim.o.runtimepath
vim.o.exrc = true

vim.cmd [[ source ~/.vimrc ]]

if vim.g.neovide then
  vim.o.guifont = "Source Code Pro:h12"
end

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

applyall(vim.fn.sign_define, {
  { 'DiagnosticSignInformation', { text = '-', texthl = 'Todo', linehl = '', numhl = '' } },
  { 'DiagnosticSignHint', { text = '*', texthl = 'Todo', linehl = '', numhl = '' } },
  { 'DiagnosticSignWarning', { text = '*', texthl = 'Todo', linehl = '', numhl = '' } },
  { 'DiagnosticSignError', { text = '>', texthl = 'WarningMsg', linehl = '', numhl = '' } },
})

-- Shouldn't be hardcoded, but whatever. `bg` value from material.vim
-- with +5% K in CMYK.
local darkbg = '#1d272b'

applyall(vim.api.nvim_set_hl, {
  { 0, 'TelescopeNormal', { bg = darkbg } },
  { 0, 'TelescopePromptBorder', { bg = darkbg, fg = darkbg } },
  { 0, 'TelescopeBorder', { bg = darkbg, fg = darkbg } },
  { 0, 'TelescopePreviewTitle', { bg = darkbg, fg = darkbg } },
  { 0, 'TelescopePromptTitle', { bg = darkbg, fg = darkbg } },
  { 0, 'TelescopeResultsTitle', { bg = darkbg, fg = darkbg } },
  { 0, 'NeogitDiffAdd', { link = 'DiffAdd' } },
  { 0, 'NeogitDiffAddHighlight', { link = 'DiffAdd' } },
  { 0, 'NeogitDiffDelete', { link = 'DiffDelete' } },
  { 0, 'NeogitDiffDeleteHighlight', { link = 'DiffDelete' } },
})

-- Disable semantic highlighting.
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end

require('nvim-treesitter.configs').setup {
  ensure_installed = "all",
  ignore_install = {"tex", "latex", "markdown"},
  indent = {
    disable = {"tex", "latex"},
  },
  highlight = {
    enable = true,
    disable = {"tex", "latex"},
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
      selection_modes = {},
    },
    move = {
      enable = true,
      disable = {'tex', 'latex'},
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
}

-- require('ts_context_commentstring').setup {
--   enable_autocmd = false,
--   commentary_integration = false,
-- }

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
  },
  git = {
    ignore = false,
  },
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')
    local function opts(desc)
      return {
        desc = 'nvim-tree: ' .. desc,
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
      }
    end

    applyall(vim.keymap.set, {
      { 'n', '<CR>', api.node.open.edit, opts('Open') },
      { 'n', 'o', api.node.open.edit, opts('Open') },
      { 'n', '<2-LeftMouse>', api.node.open.edit, opts('Open') },
      { 'n', 'l', api.node.open.edit, opts('Open') },
      { 'n', '<F5>', api.tree.reload, opts('Refresh') },
      { 'n', 'h', api.node.navigate.parent_close, opts('Close Directory') },
      { 'n', 'D', api.fs.remove, opts('Delete') },
      { 'n', 'q', api.tree.close, opts('Close') },
      { 'n', 'R', api.fs.rename, opts('Rename') },
      { 'n', 'N', api.fs.create, opts('Create') },
      { 'n', 'K', api.node.show_info_popup, opts('Info') },
    })
  end
}

require("chatgpt").setup {}

local cmp = require('cmp')
cmp.setup({
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
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
      require('luasnip').lsp_expand(args.body)
    end,
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }),
  completion = {
    autocomplete = false,
  },
  experimental = { 
    ghost_text = { hlgroup = "Comment" },
  },
})

require("luasnip.loaders.from_snipmate").lazy_load()

local telescope_bottom = {
  border = false,
  layout_strategy = "bottom_pane",
  sorting_strategy = "ascending",
  layout_config = { height = 20 },
  previewer = false,
}

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<Esc>"] = require("telescope.actions").close,
        ["<C-u>"] = false,
        ["<C-x>"] = false,
        ["<C-s>"] = require("telescope.actions").select_horizontal,
      },
    },
    layout_config = {
      horizontal = {
        width = 0.98,
        height = 0.96,
        preview_width = 0.6,
      },
    },
  },
  pickers = {
    find_files = telescope_bottom,
    diagnostics = telescope_bottom,
    buffers = merge(telescope_bottom, {
      mappings = {
        i = {
          ["<C-x>"] = require("telescope.actions").delete_buffer,
        },
      },
    }),
  },
})

require('harpoon').setup {}

require('lint').linters_by_ft = {
  sh = { 'shellcheck' },
  nix = { 'nix' },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

vim.diagnostic.disable()

require('neogit').setup {}

local lspconfig = require('lspconfig')
vim.diagnostic.config({
    virtual_text = false,
})
lspconfig.util.default_config = merge(
  lspconfig.util.default_config,
  {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  }
)

applyall(
  function(lsp, opts)
    lspconfig[lsp].setup(opts or {})
  end,
  {
    -- Only `clangd` is sane, so we have to make it insane.
    -- https://github.com/neovim/nvim-lspconfig/issues/2184#issuecomment-1273705335
    { 'clangd', { capabilities = { offsetEncoding = "utf-16" } } },
    { 'elixirls', { cmd = { 'elixir-ls' } } },
    { 'pyright' },
    { 'solidity_ls_nomicfoundation' },
    { 'texlab' },
    { 'tsserver' },
    { 'typst_lsp' },
    { 'zls' },
  }
)

require("nvim-dap-virtual-text").setup {}
require("dapui").setup {}

-- leap setup
require('leap').set_default_keymaps()
vim.g.surround_no_mappings = 1

local dap_widgets = require('dap.ui.widgets')
local dap = require('dap')

function find_files_project()
  local cwd = vim.lsp.buf.list_workspace_folders()[1]
  require('telescope.builtin').find_files({ cwd = cwd })
end

function comment_aux(mapping)
  return function()
    -- pcall(require('ts_context_commentstring.internal').update_commentstring)
    return '<Plug>' .. mapping
  end
end

applyall(vim.keymap.set, {
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

  { 'n', ' ft', require('nvim-tree.api').tree.open },
  { 'n', '  ', find_files_project },
  { 'n', ' .', require('telescope.builtin').find_files },
  { 'n', ' ,', require('telescope.builtin').buffers },
  { 'n', ' /', require('telescope.builtin').live_grep },
  { 'n', ' r', require('telescope.builtin').registers },

  { 'n', ' lr', require('telescope.builtin').lsp_references },
  { 'n', ' lR', vim.lsp.buf.rename },
  { 'n', 'K', vim.lsp.buf.hover },
  { {'n', 'i'}, '<C-s>', vim.lsp.buf.signature_help },
  { 'n', ' ld', function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end },
  { 'n', ' lD', require('telescope.builtin').diagnostics },
  { 'n', 'gd', require('telescope.builtin').lsp_definitions },
  { 'n', 'gt', require('telescope.builtin').lsp_type_definitions },
  { 'n', 'gD', require('telescope.builtin').lsp_implementations },
  { 'n', '<C-k>', '<cmd>RustLsp externalDocs<CR>' },
  { 'n', 'go', '<cmd>RustLsp parentModule<CR>' },

  { 'n', ' gB', '<cmd>Git blame<CR>' },
  { 'n', ' gg', require('neogit').open },

  { 'n', '[g', '<cmd>GitGutterPrevHunk<CR>' },
  { 'n', ']g', '<cmd>GitGutterNextHunk<CR>' },
  { 'n', '[e', vim.diagnostic.goto_prev },
  { 'n', ']e', vim.diagnostic.goto_next },
  { 'n', '[t', '<cmd>tabprev<CR>' },
  { 'n', ']t', '<cmd>tabnext<CR>' },

  { {'i', 's'}, '<C-j>', require('luasnip').expand_or_jump },

  { 'n', ' d ', dap.toggle_breakpoint },
  { 'n', ' dd', require("dapui").toggle },
  { 'n', ' ds', dap.close },
  { 'n', ' dc', dap.continue },
  { 'n', ' dr', dap.repl.open },
  { 'n', ' di', dap_widgets.hover },
  { 'n', ' d?', function() dap_widgets.centered_float(dap_widgets.scopes) end },
  { 'n', '<A-J>', dap.step_over },
  { 'n', '<A-H>', dap.step_out },
  { 'n', '<A-L>', dap.step_into },

  { 'n', ' cc', '<cmd>ChatGPT<CR>' },

  { 'x', '<C-c><C-c>', '<Plug>SlimeRegionSend' },
  { 'n', '<C-c><C-c>', '<Plug>SlimeParagraphSend' },
  { 'n', '<C-c>v', '<Plug>SlimeConfig' },
})
