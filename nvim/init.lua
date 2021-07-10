local api = vim.api
local fn = vim.fn

local termcode = function(x)
    return api.nvim_replace_termcodes(x, true, true, true)
end

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd('packadd packer.nvim')
end

require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    use 'neovim/nvim-lspconfig'
    use 'mfussenegger/nvim-dap'
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
    }
    use 'JoosepAlviste/nvim-ts-context-commentstring'
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            'nvim-lua/popup.nvim',
            'nvim-lua/plenary.nvim',
        },
    }
end).install()

vim.o.runtimepath = '~/.vim,' .. vim.o.runtimepath .. ',~/.vim/after'
vim.o.packpath = vim.o.runtimepath
vim.cmd('source ~/.vimrc')

local context_commentstring = require('ts_context_commentstring.internal')
local dap = require('dap')

_G.f = {} -- custom namespace
_G.f.telescope = require('telescope.builtin')
_G.f.dap = dap
_G.f.comment_run = function(mapping)
    pcall(context_commentstring.update_commentstring)
    return termcode('<Plug>' .. mapping)
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

require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ["<C-u>"] = false,
                ["<Esc>"] = require('telescope.actions').close,
            }
        }
    },
}

local lspconfig = require('lspconfig')
local lspattach = function(_client, bufnr)
    api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    local function map(...) api.nvim_buf_set_keymap(bufnr, ...) end
    map('n', 'gr', '<cmd>lua _G.f.telescope.lsp_references()<CR>',
        { noremap = true })
end
local lspservers = {
    {'elixirls', {cmd = {'elixir-ls'}}},
    'pyright',
    'rust_analyzer',
    'texlab',
    'tsserver',
    'zls',
}
lspconfig.util.default_config = vim.tbl_extend(
    "force",
    lspconfig.util.default_config,
    {
        on_attach = lspattach,
        handlers = {
            -- Disable diagnostics
            ['textDocument/publishDiagnostics'] = function(...) end,
        }
    }
)

for _, lsp in ipairs(lspservers) do
    if type(lsp) == 'table' then
        lspconfig[lsp[1]].setup(lsp[2])
    else
        lspconfig[lsp].setup({})
    end
end

local map = api.nvim_set_keymap
map('', 'gc', "v:lua.f.comment_run('Commentary')", { expr = true })
map('', 'gy', "v:lua.f.comment_run('(CommentaryYank)')", { expr = true })
map('n', 'gcc', "v:lua.f.comment_run('CommentaryLine')", { expr = true })
map('n', 'gyy', "v:lua.f.comment_run('(CommentaryYankLine)')", { expr = true })
map('n', 'cgc', "v:lua.f.comment_run('ChangeCommentary')", { expr = true })
map('n', '<leader>ff', "<cmd>lua _G.f.telescope.find_files()<CR>", { noremap = true })
map('n', '<leader>fg', "<cmd>lua _G.f.telescope.live_grep()<CR>", { noremap = true })
map('n', '<leader>fb', "<cmd>lua _G.f.telescope.buffers()<CR>", { noremap = true })
