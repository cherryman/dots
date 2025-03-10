vim.loader.enable()

-- bootstrap mini-deps
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim',
    mini_path,
  })
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

require('mini.deps').setup({ path = { package = path_package } })

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

local api, fn, keymap = vim.api, vim.fn, vim.keymap
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

vim.o.runtimepath = '~/.vim,' .. vim.o.runtimepath .. ',~/.vim/after'
vim.o.packpath = vim.o.runtimepath
vim.o.exrc = true

vim.cmd [[ source ~/.vimrc ]]

if vim.g.neovide then
  vim.o.guifont = "Source Code Pro:h15"
end

applyall(vim.fn.sign_define, {
  { 'DiagnosticSignInformation', { text = '-', texthl = 'Todo', linehl = '', numhl = '' } },
  { 'DiagnosticSignHint', { text = '*', texthl = 'Todo', linehl = '', numhl = '' } },
  { 'DiagnosticSignWarning', { text = '*', texthl = 'Todo', linehl = '', numhl = '' } },
  { 'DiagnosticSignError', { text = '>', texthl = 'WarningMsg', linehl = '', numhl = '' } },
})

-- Shouldn't be hardcoded, but whatever. `bg` value from material.vim
-- with +5% K in CMYK.
local DARKBG = '#1d272b'

now(function()
  -- these are used by a lot of plugins, and i lost track which
  -- ones depend on them, so just installing it now.
  add({ source = 'nvim-lua/plenary.nvim' })
  add({ source = 'nvim-lua/popup.nvim' })
  -- miscellaneous plugins which should probably be loaded early.
end)

now(function()
  add({ source = 'kaarmu/typst.vim' })
  -- vim.g.typst_pdf_viewer = 'zathura'
end)

now(function()
  require("mini.misc").setup_restore_cursor()
  require("mini.ai").setup()

  require("mini.bracketed").setup({
    buffer     = { suffix = 'b', options = {} },
    comment    = { suffix = 'c', options = {} },
    conflict   = { suffix = 'x', options = {} },
    diagnostic = { suffix = 'e', options = {} },
    file       = { suffix = 'f', options = {} },
    indent     = { suffix = 'i', options = {} },
    jump       = { suffix = 'j', options = {} },
    location   = { suffix = 'l', options = {} },
    oldfile    = { suffix = 'o', options = {} },
    quickfix   = { suffix = 'q', options = {} },
    -- treesitter = { suffix = 't', options = {} },
    undo       = { suffix = 'u', options = {} },
    window     = { suffix = 'w', options = {} },
    yank       = { suffix = 'y', options = {} },
  })

  applyall(vim.keymap.set, {
    { 'n', ']t', '<cmd>tabnext<CR>' },
    { 'n', '[t', '<cmd>tabprevious<CR>' },
  })

  require("mini.pairs").setup({
    modes = { insert = true, command = false, terminal = false },

    -- Global mappings. Each right hand side should be a pair information, a
    -- table with at least these fields (see more in |MiniPairs.map|):
    -- - <action> - one of 'open', 'close', 'closeopen'.
    -- - <pair> - two character string for pair to be used.
    -- By default pair is not inserted after `\`, quotes are not recognized by
    -- `<CR>`, `'` does not insert pair after a letter.
    -- Only parts of tables can be tweaked (others will use these defaults).
    mappings = {
      ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
      ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
      ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },

      [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
      [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
      ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },

      ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
      ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
      ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },

      -- TODO add html comment tags too
      -- nvm can't it's just single characters
    },
  })
end)

now(function()
  add({ source = 'neovim/nvim-lspconfig' })
  add({ source = 'hrsh7th/cmp-nvim-lsp' })
  add({ source = 'hrsh7th/nvim-cmp' })
  add({ source = 'L3MON4D3/LuaSnip', hooks = { post_checkout = function() vim.cmd('make install_jsregexp') end } })
  add({ source = 'saadparwaiz1/cmp_luasnip' })

  vim.diagnostic.disable()
  vim.diagnostic.config({ virtual_text = false })

  capabilities = require('cmp_nvim_lsp').default_capabilities()
  capabilities.semanticTokensProvider = false

  -- disable semantic highlighting.
  --
  -- NOTE: i think the above method is the new proper way? but it doesn't
  -- seem to work, at least for rust, so doing the nuclear option.
  -- probably need to configure rustacean.nvim but whatever.
  for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
  end

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

  applyall(
    function(lsp, opts)
      opts = merge(opts or {}, { capabilities = capabilities })
      require('lspconfig')[lsp].setup(opts)
    end,
    {
      -- Only `clangd` is sane, so we have to make it insane.
      -- https://github.com/neovim/nvim-lspconfig/issues/2184#issuecomment-1273705335
      { 'clangd', { capabilities = { offsetEncoding = "utf-16" } } },
      { 'elixirls', { cmd = { 'elixir-ls' } } },
      { 'kotlin_language_server' },
      { 'gopls' },
      { 'basedpyright' },
      { 'solidity_ls_nomicfoundation' },
      { 'texlab' },
      { 'ts_ls' },
      { 'tinymist', { settings = { exportPdf = 'onSave' } } },
      { 'zls' },
    }
  )

  applyall(vim.keymap.set, {
    { {'i', 's'}, '<C-j>', require('luasnip').expand_or_jump },
  })
end)

now(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  add({ source = 'nvim-treesitter/nvim-treesitter-textobjects' })
  add({ source = 'windwp/nvim-ts-autotag' })
  require('nvim-treesitter.configs').setup({
    ensure_installed = "all",
    ignore_install = {"tex", "latex", "markdown", "wing"},
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
  })
  require('nvim-ts-autotag').setup({
    opts = {
      -- Defaults
      enable_close = true, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = false -- Auto close on trailing </
    },
    -- Also override individual filetype configs, these take priority.
    -- Empty by default, useful if one of the "opts" global settings
    -- doesn't work well in a specific filetype
    per_filetype = {
      -- ["html"] = {
      --   enable_close = false
      -- }
    },
  })
end)

now(function()
  add({ source = 'nvim-telescope/telescope.nvim' })

  applyall(vim.api.nvim_set_hl, {
    { 0, 'TelescopeNormal', { bg = DARKBG } },
    { 0, 'TelescopePromptBorder', { bg = DARKBG, fg = DARKBG } },
    { 0, 'TelescopeBorder', { bg = DARKBG, fg = DARKBG } },
    { 0, 'TelescopePreviewTitle', { bg = DARKBG, fg = DARKBG } },
    { 0, 'TelescopePromptTitle', { bg = DARKBG, fg = DARKBG } },
    { 0, 'TelescopeResultsTitle', { bg = DARKBG, fg = DARKBG } },
  })

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
end)

later(function()
  add({ source = 'mfussenegger/nvim-dap' })
  add({ source = 'theHamsta/nvim-dap-virtual-text' })
  add({ source = 'rcarriga/nvim-dap-ui', depends = { 'nvim-neotest/nvim-nio' } })

  require("nvim-dap-virtual-text").setup {}
  require("dapui").setup {}

  local widgets = require('dap.ui.widgets')
  local dap = require('dap')

  applyall(vim.keymap.set, {
    { 'n', ' d ', dap.toggle_breakpoint },
    { 'n', ' dd', require("dapui").toggle },
    { 'n', ' ds', dap.close },
    { 'n', ' dc', dap.continue },
    { 'n', ' dr', dap.repl.open },
    { 'n', ' di', widgets.hover },
    { 'n', ' d?', function() widgets.centered_float(widgets.scopes) end },
    { 'n', '<A-J>', dap.step_over },
    { 'n', '<A-H>', dap.step_out },
    { 'n', '<A-L>', dap.step_into },
  })
end)

later(function()
  add({
    source = 'NeogitOrg/neogit',
    depends = { 'sindrets/diffview.nvim' }
  })
  applyall(vim.api.nvim_set_hl, {
    { 0, 'NeogitDiffAdd', { link = 'DiffAdd' } },
    { 0, 'NeogitDiffAddHighlight', { link = 'DiffAdd' } },
    { 0, 'NeogitDiffDelete', { link = 'DiffDelete' } },
    { 0, 'NeogitDiffDeleteHighlight', { link = 'DiffDelete' } },
  })
  require('neogit').setup {}
  applyall(vim.keymap.set, {
    { 'n', ' gg', require('neogit').open },
  })
end)

later(function()
  add({ source = 'ggandor/leap.nvim' })
  require('leap').set_default_keymaps()
  vim.g.surround_no_mappings = 1
end)

later(function()
  add({ source = 'kyazdani42/nvim-tree.lua' })
  require('nvim-tree').setup({
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
  })
  applyall(vim.keymap.set, {
    { 'n', ' ft', require('nvim-tree.api').tree.open },
  })
end)

later(function()
  add({ source = 'mfussenegger/nvim-lint' })
  require('lint').linters_by_ft = {
    sh = { 'shellcheck' },
    nix = { 'nix' },
  }
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })
end)

later(function()
  add({ source = 'supermaven-inc/supermaven-nvim' })
  require("supermaven-nvim").setup({
    keymaps = {
      accept_suggestion = "<M-Enter>",
    },
    ignore_filetypes = {
      typst = false,
    },
    disable_inline_completion = false,
  })
end)

later(function()
  add({
    source = 'mrcjkb/rustaceanvim',
    depends = {
      -- > This plugin will automatically register the necessary client
      -- > capabilities if you have cmp-nvim-lsp installed.
      -- https://github.com/mrcjkb/rustaceanvim#how-to-enable-auto-completion
      'hrsh7th/cmp-nvim-lsp',
      -- adding this to make sure dap is read.
      'mfussenegger/nvim-dap',
    },
  })
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
    server = {
      default_settings = {
        ["rust-analyzer"] = {
          cargo = {
            targetDir = true,
          },
        },
      },
    },
  }
  applyall(vim.keymap.set, {
    { 'n', '<C-k>', '<cmd>RustLsp externalDocs<CR>' },
    { 'n', 'go', '<cmd>RustLsp parentModule<CR>' },
  })
end)

later(function()
  add({ source = 'jpalardy/vim-slime' })

  -- https://github.com/jpalardy/vim-slime/blob/main/assets/doc/targets/tmux.md
  vim.g.slime_no_mappings = 1
  vim.g.slime_target = 'tmux'
  vim.g.slime_paste_file = vim.fn.stdpath('cache') .. '/_slime_paste'
  vim.g.slime_bracketed_paste = 1
  vim.g.slime_default_config = { socket_name = 'default', target_pane = '{last}' }

  applyall(vim.keymap.set, {
    { 'x', '<C-c><C-c>', '<Plug>SlimeRegionSend' },
    { 'n', '<C-c><C-c>', '<Plug>SlimeParagraphSend' },
    { 'n', '<C-c>v', '<Plug>SlimeConfig' },
  })
end)

later(function()
  add({ source = 'stevearc/conform.nvim' })
  require("conform").setup({
    -- formats asynchronously, as opposed to `format_on_save`.
    format_after_save = {
      -- don't enable this, lsp formatters should never have existed.
      -- lsp_format = "fallback",
    },
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      rust = { "rustfmt" },
      kotlin = { "ktfmt" },
      nix = { "nixfmt" },
      zig = { "zigfmt" },
      typst = { "typstyle" },
    },
    formatters = {
      nixfmt = {
        command = "nixfmt",
      },
      typstyle = {
        command = "typstyle",
      },
    },
  })
end)

later(function()
  add({ source = 'Julian/lean.nvim' })
  require('lean').setup({
    mappings = true,
  })
end)

later(function()
  add({
    source = 'stevearc/aerial.nvim',
    depends = {
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
  })
  require('aerial').setup({
    backends = { "treesitter", "lsp" },
  })
  vim.keymap.set('n', 'gO', require("telescope").extensions.aerial.aerial)
end)

later(function()
  add({
    source = 'yetone/avante.nvim',
    monitor = 'main',
    depends = {
      -- dressing.nvim seems "required", but avante works without.
      -- it's too distacting so disabling.
      -- 'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'echasnovski/mini.icons'
    },
    hooks = { post_checkout = function() vim.cmd('make') end }
  })
  require('avante_lib').load()
  require("avante").setup({
    provider = "claude",
    auto_suggestions_provider = "claude",

    claude = {
      endpoint = "https://api.anthropic.com",
      model = "claude-3-5-sonnet-20241022",
      temperature = 0,
      max_tokens = 4096,
    },

    ---Specify the special dual_boost mode
    ---1. enabled: Whether to enable dual_boost mode. Default to false.
    ---2. first_provider: The first provider to generate response. Default to "openai".
    ---3. second_provider: The second provider to generate response. Default to "claude".
    ---4. prompt: The prompt to generate response based on the two reference outputs.
    ---5. timeout: Timeout in milliseconds. Default to 60000.
    ---How it works:
    --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
    ---Note: This is an experimental feature and may not work as expected.
    dual_boost = {
      enabled = false,
      first_provider = "openai",
      second_provider = "claude",
      prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
      timeout = 60000, -- Timeout in milliseconds
    },

    behaviour = {
      auto_suggestions = false, -- experimental
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true, -- remove unchanged lines
    },

    mappings = {
      --- @class AvanteConflictMappings
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },

    hints = {
      enabled = true,
    },

    windows = {
      ---@type "right" | "left" | "top" | "bottom"
      position = "right", -- the position of the sidebar
      wrap = true, -- similar to vim.o.wrap
      width = 30, -- default % based on available width
      sidebar_header = {
        enabled = true, -- true, false to enable/disable the header
        align = "center", -- left, center, right for title
        rounded = true,
      },
      input = {
        prefix = "> ",
        height = 8, -- Height of the input window in vertical layout
      },
      edit = {
        border = "rounded",
        start_insert = true, -- Start insert mode when opening the edit window
      },
      ask = {
        floating = false, -- Open the 'AvanteAsk' prompt in a floating window
        start_insert = true, -- Start insert mode when opening the ask window
        border = "rounded",
        ---@type "ours" | "theirs"
        focus_on_apply = "ours", -- which diff to focus after applying
      },
    },
    highlights = {
      ---@type AvanteConflictHighlights
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },
    --- @class AvanteConflictUserConfig
    diff = {
      autojump = true,
      ---@type string | fun(): any
      list_opener = "copen",
      --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
      --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
      --- Disable by setting to -1.
      override_timeoutlen = 500,
    },
  })
end)

function find_files_project()
  local cwd = vim.lsp.buf.list_workspace_folders()[1]
  require('telescope.builtin').find_files({ cwd = cwd })
end

_G.__commentyank = function(mode)
  if mode == nil then
    vim.o.operatorfunc = 'v:lua.__commentyank'
    return 'g@'
  end

  local mark_from, mark_to = "'[", "']"
  local lnum_from, col_from = vim.fn.line(mark_from), vim.fn.col(mark_from)
  local lnum_to, col_to = vim.fn.line(mark_to), vim.fn.col(mark_to)

  if (lnum_from > lnum_to) or (lnum_from == lnum_to and col_from > col_to) then
    return
  end

  local l = vim.api.nvim_buf_get_lines(0, lnum_from - 1, lnum_to, false)
  vim.fn.setreg(vim.v.register, l)

  -- WARN: Relying on implementation details of `gc`.
  require('vim._comment').toggle_lines(lnum_from, lnum_to, vim.api.nvim_win_get_cursor(0))

  return ''
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

  { {'n', 'x', 'o'}, 'gy', _G.__commentyank, { expr = true } },
  { 'n', 'gyy', 'yygcc', { remap = true } },

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

  { 'n', ' gB', '<cmd>Git blame<CR>' },

  { 'n', '[h', '<cmd>GitGutterPrevHunk<CR>' },
  { 'n', ']h', '<cmd>GitGutterNextHunk<CR>' },
})
