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
  add({ source = 'L3MON4D3/LuaSnip', hooks = { post_checkout = function() vim.cmd('make install_jsregexp') end } })

  add({
    source = 'Saghen/blink.cmp',
    checkout = "v1.0.0",
    hooks = {
      post_checkout = function(params)
        vim.system({ 'cargo', 'build', '--release' }, { cwd = params.path }):wait()
      end,
      post_install = function(params)
        vim.system({ 'cargo', 'build', '--release' }, { cwd = params.path }):wait()
      end,
    },
  })

  vim.diagnostic.enable(true, nil)

  vim.diagnostic.config({
    underline = false,
    virtual_text = true,
    virtual_lines = false,
    signs = {
      priority = 11,
      numhl = {
        [vim.diagnostic.severity.HINT] = "",
        [vim.diagnostic.severity.INFO] = "Todo",
        [vim.diagnostic.severity.WARN] = "Todo",
        [vim.diagnostic.severity.ERROR] = "WarningMsg",
      },
      linehl = {
        [vim.diagnostic.severity.HINT] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.ERROR] = "",
      },
      text = {
        [vim.diagnostic.severity.HINT] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.WARN] = "*",
        [vim.diagnostic.severity.ERROR] = ">",
      },
    },
  })

  require('blink.cmp').setup({
    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },
    completion = {
      keyword = { range = 'full', },
      accept = { auto_brackets = { enabled = false }, },
      documentation = { auto_show = true, auto_show_delay_ms = 0 },
      ghost_text = { enabled = false },
      menu = {
        auto_show = true,
      },
      trigger = {
        prefetch_on_insert = true,
        show_on_keyword = false,
        show_on_trigger_character = true,
        show_on_accept_on_trigger_character = true,
        show_on_insert_on_trigger_character = true,
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = true,
        },
      },
    },
    snippets = { preset = 'luasnip' },
    signature = { enabled = true },
    keymap = {
      preset = 'default',
      ['<CR>'] = { 'select_and_accept', 'fallback' },
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
    },
  })

  vim.lsp.config('*', {
    capabilities = merge(
      require('blink.cmp').get_lsp_capabilities(),
      { semanticTokensProvider = false }
    )
  })

  -- disable semantic highlighting.
  --
  -- NOTE: i think the above method is the new proper way? but it doesn't
  -- seem to work, at least for rust, so doing the nuclear option.
  -- probably need to configure rustacean.nvim but whatever.
  for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
  end

  require("luasnip.loaders.from_snipmate").lazy_load()

  applyall(
    function(lsp, opts)
      vim.lsp.config(lsp, opts or {})
      vim.lsp.enable(lsp)
    end,
    {
      -- Only `clangd` is sane, so we have to make it insane.
      -- https://github.com/neovim/nvim-lspconfig/issues/2184#issuecomment-1273705335
      { 'clangd', { capabilities = { offsetEncoding = "utf-16" } } },
      { 'elixirls', { cmd = { 'elixir-ls' } } },
      { 'kotlin_language_server' },
      { 'gopls' },
      { 'basedpyright' },
      { 'texlab' },
      { 'ts_ls' },
      { 'tinymist', { settings = { exportPdf = 'onSave' } } },
      { 'zls' },
      { 'rust_analyzer', { settings = { ['rust-analyzer'] = { cargo = { targetDir = true } } } } },
    }
  )

  applyall(vim.keymap.set, {
    { {'i', 's'}, '<C-j>', require('luasnip').expand_or_jump },
  })

  -- rust-analyzer
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client.name == "rust_analyzer" then
        vim.keymap.set("n", "<C-k>", function()
          local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
          client.request("experimental/externalDocs", params, function(err, result)
            if err then
              vim.notify("Error fetching docs: " .. vim.inspect(err), vim.log.levels.ERROR)
              return
            end
            if result then
              local url = type(result) == "string" and result or result.web
              if url then
                vim.ui.open(url)
              else
                vim.notify("No documentation found", vim.log.levels.WARN)
              end
            else
              vim.notify("No documentation found", vim.log.levels.WARN)
            end
          end)
        end, { buffer = args.buf, desc = "Open external documentation" })
      end
    end,
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
        args = { "--wrap-text" },
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

function find_files_project()
  local cwd = vim.lsp.buf.list_workspace_folders()[1]
  require('telescope.builtin').find_files({ cwd = cwd })
end

function toggle_virtual_text()
  local x = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config({ virtual_text = x })
end

function toggle_virtual_lines()
  local x = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = x })
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

  { 'n', '  ', require('telescope.builtin').find_files },
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
  { 'n', ' lt', toggle_virtual_text },
  { 'n', ' lT', toggle_virtual_lines },

  { 'n', ' gB', '<cmd>Git blame<CR>' },
  { 'n', '[h', '<cmd>GitGutterPrevHunk<CR>' },
  { 'n', ']h', '<cmd>GitGutterNextHunk<CR>' },
})
