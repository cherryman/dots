.POSIX:

XDGC	= $(HOME)/.config/
LN	= ln -s -f

all:	dirs term wm shell

# Current defaults
term:	alacritty
wm:	bspwm
shell:	zsh shutil

# Groups
X:	xorg rofi sxhkd dunst compton
shutil:	vim tmux git

# Setup
dirs:
	mkdir -p $(HOME)/bin
	mkdir -p $(HOME)/.config/
	mkdir -p $(HOME)/.local/
	mkdir -p $(HOME)/.local/{share,bin,src}
	mkdir -p $(HOME)/.local/share/fonts

# Software
alacritty: dirs
	$(LN) $(PWD)/alacritty $(XDGC)

bin:	dirs
	$(LN) $(PWD)/bin/* $(HOME)/bin

bspwm:	dirs
	$(LN) $(PWD)/bspwm/ $(XDGC)

compton:dirs xorg
	$(LN) $(PWD)/compton/compton.conf $(XDGC)

dunst: 	dirs xorg
	$(LN) $(PWD)/dunst/ $(XDGC)

git:	dirs
	mkdir -p $(XDGC)/git
	$(LN) $(PWD)/git/config $(XDGC)/git/
	$(LN) $(PWD)/git/ignore $(XDGC)/git/

i3:	dirs X xorg
	$(LN) $(PWD)/i3/ $(XDGC)

rofi:	dirs xorg
	$(LN) $(PWD)/rofi/ $(XDGC)

sxhkd:	dirs xorg
	$(LN) $(PWD)/sxhkd/ $(XDGC)

tmux:	dirs
	mkdir -p $(HOME)/.tmux/plugins
	$(LN) $(PWD)/tmux/.tmux/plugins/tpm $(HOME)/.tmux/plugins/
	$(LN) $(PWD)/tmux/.tmux.conf $(HOME)/
	$(LN) $(PWD)/tmux/.tmuxline.conf $(HOME)/

vim:
	mkdir -p $(HOME)/.vim/
	$(LN) $(PWD)/vim/.vim/vim-plug $(HOME)/.vim/
	$(LN) $(PWD)/vim/.vimrc $(HOME)/

nvim:	dirs vim
	$(LN) $(PWD)/nvim/ $(XDGC)

xorg:
	$(LN) $(PWD)/xorg/* $(HOME)/

zsh:	dirs
	$(LN) $(PWD)/zsh/.zshrc $(HOME)/
	$(LN) $(PWD)/zsh/.zshenv $(HOME)/
	$(LN) $(PWD)/zsh/.zprofile $(HOME)/
	$(LN) $(PWD)/zsh/base16-shell/ $(XDGC)
	$(LN) $(PWD)/zsh/pyenv/ $(XDGC)
	$(LN) $(PWD)/zsh/zplug/ $(XDGC)
