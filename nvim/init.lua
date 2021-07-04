local api = vim.api
local fn = vim.fn
local map = api.nvim_set_keymap

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
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'JoosepAlviste/nvim-ts-context-commentstring'
end).install()

vim.o.runtimepath = '~/.vim,' .. vim.o.runtimepath .. ',~/.vim/after'
vim.o.packpath = vim.o.runtimepath
vim.o.guicursor = ''
vim.cmd('source ~/.vimrc')

_G.f = {} -- custom namespace

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

local context_commentstring = require('ts_context_commentstring.internal')
function _G.f.comment_run(mapping)
    pcall(context_commentstring.update_commentstring)
    return termcode('<Plug>' .. mapping)
end

map('', 'gc', "v:lua.f.comment_run('Commentary')", { expr = true })
map('', 'gy', "v:lua.f.comment_run('(CommentaryYank)')", { expr = true })
map('n', 'gcc', "v:lua.f.comment_run('CommentaryLine')", { expr = true })
map('n', 'gyy', "v:lua.f.comment_run('(CommentaryYankLine)')", { expr = true })
map('n', 'cgc', "v:lua.f.comment_run('ChangeCommentary')", { expr = true })
