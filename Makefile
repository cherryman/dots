XDGC	= $(HOME)/.config/
ROOT	= $(PWD)
LN	= -ln
LNFLAGS	= -s
LINK	= $(LN) $(LNFLAGS)

### Inference rules
%/:
	mkdir -p $@

$(HOME)/.%: 	$(ROOT)/%
	$(LINK) $? $@

# This assumes $(XDGC) exists
$(XDGC)/%: 	$(ROOT)/%
	$(LINK) $? $@


### Targets
all:		dir xdg
dir:		$(XDGC)/              \
		$(HOME)/bin/          \
		$(HOME)/.local/       \
		$(HOME)/.local/share/ \
		$(HOME)/.local/bin/   \
		$(HOME)/.local/src/   \
		$(HOME)/doc/          \
		$(HOME)/doc/desktop/  \
		$(HOME)/doc/download/ \
		$(HOME)/media/        \
		$(HOME)/media/pic/
xdg:		$(XDGC)/user-dirs.dirs
alacritty:	$(XDGC)/alacritty
i3:		$(XDGC)/i3
bspwm:		$(XDGC)/bspwm
compton:	$(XDGC)/compton.conf
dunst:		$(XDGC)/dunst
rofi:		$(XDGC)/rofi
sxhkd:		$(XDGC)/sxhkd
base16-shell:	$(XDGC)/base16-shell
sh: 		$(HOME)/.profile
nvim:		$(XDGC)/nvim vim

$(HOME)/bin/%: $(ROOT)/bin/%
	$(LINK) $? $@
bin:		$(HOME)/bin/          \
		$(HOME)/bin/backlight \
		$(HOME)/bin/bar       \
		$(HOME)/bin/keymap    \
		$(HOME)/bin/mkscript  \
		$(HOME)/bin/notif     \
		$(HOME)/bin/startwm   \
		$(HOME)/bin/vol       \
		$(HOME)/bin/wmrc


$(HOME)/.vimrc: $(ROOT)/vim/vimrc
	$(LINK) $? $@
$(HOME)/.vim/vim-plug: $(ROOT)/vim/vim-plug
	mkdir -p "$(HOME)/.vim"
	$(LINK) $? $@
vim:		$(HOME)/.vimrc $(HOME)/.vim/vim-plug


$(HOME)/.zshrc: $(ROOT)/zsh/zshrc
	$(LINK) $? $@
$(XDGC)/zplug: $(ROOT)/zsh/zplug
	$(LINK) $? $@
zsh:	sh $(HOME)/.zshrc $(XDGC)/zplug base16-shell


$(XDGC)/git/%:	$(ROOT)/git/%
	mkdir -p "$(XDGC)/git"
	$(LINK) $? $@
git:		$(XDGC)/git/ $(XDGC)/git/config $(XDGC)/git/ignore


$(HOME)/.tmux%: $(ROOT)/tmux/tmux%
	$(LINK) $? $@
$(HOME)/.tmux/plugins/tpm: $(ROOT)/tmux/tpm
	mkdir -p "$(HOME)/.tmux/plugins"
	$(LINK) $? $@
tmux:	$(HOME)/.tmux.conf     \
	$(HOME)/.tmuxline.conf \
	$(HOME)/.tmux/plugins/tpm

$(HOME)/.%:	$(ROOT)/xorg/%
	$(LINK) $? $@
xorg:		$(HOME)/.Xmodmap    \
		$(HOME)/.Xresources \
		$(HOME)/.xinitrc    \
		$(HOME)/.xprofile

.PHONY: all dir xdg
.PHONY: i3 bspwm
.PHONY: compton dunst rofi sxhkd xorg
.PHONY: sh zsh tmux vim nvim alacritty bin
