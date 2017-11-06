.POSIX:

OFF	= ../$(shell basename $(PWD))/
XDGC	= $(HOME)/.config/
LN	= ln -s -f

all:	dirs shell X misc
shell:	nvim vim zsh tmux git
X:	xorg i3 rofi sxhkd dunst compton
misc: 	alacritty bin

dirs:
	mkdir -p $(HOME)/bin
	mkdir -p $(HOME)/.config/
	mkdir -p $(HOME)/.local/
	mkdir -p $(HOME)/.local/{share,bin,src}
	mkdir -p $(HOME)/.local/share/fonts

term:	dirs
	$(LN) $(OFF)/alacritty/ $(XDGC)

bin:	dirs
	$(LN) $(OFF)/bin/* $(HOME)/bin

compton:dirs xorg
	$(LN) $(OFF)/compton/compton.conf $(XDGC)

dunst: 	dirs xorg
	$(LN) $(OFF)/dunst/ $(XDGC)

git:	dirs
	mkdir -p $(XDGC)/git
	$(LN) ../$(OFF)/git/config $(XDGC)/git/
	$(LN) ../$(OFF)/git/ignore $(XDGC)/git/

i3:	dirs xorg rofi
	$(LN) $(OFF)/i3/ $(XDGC)

rofi:	dirs xorg
	$(LN) $(OFF)/rofi/ $(XDGC)

sxhkd:	dirs
	$(LN) $(OFF)/sxhkd/ $(XDGC)

tmux:	dirs
	mkdir -p $(HOME)/.tmux/plugins
	$(LN) $(OFF)/tmux/*.conf $(HOME)/
	$(LN) $(OFF)/tmux/.tmux/plugins/tpm $(HOME)/.tmux/plugins/

vim:
	mkdir -p $(HOME)/.vim/
	$(LN) $(OFF)/vim/.vim/vim-plug $(HOME)/.vim/
	$(LN) $(OFF)/vim/.vimrc $(HOME)/

nvim:	dirs vim
	$(LN) $(OFF)/nvim/ $(XDGC)

xorg:
	$(LN) $(OFF)/xorg/* $(HOME)/

zsh:	dirs
	$(LN) $(OFF)/zsh/.zshrc $(HOME)/
	$(LN) $(OFF)/zsh/base16-shell/ $(XDGC)
	$(LN) $(OFF)/zsh/pyenv/ $(XDGC)
	$(LN) $(OFF)/zsh/zplug/ $(XDGC)
