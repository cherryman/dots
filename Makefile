XDGC		= $(HOME)/.config
DOTDIR		= dots
LN		= ln
LNFLAGS		=
LINK		= $(LN) -sfn $(LNFLAGS)

HOME_DIRS	= .config bin                               \
		  .local .local/share .local/src .local/bin \
		  doc doc/desk doc/www                      \
		  media media/pic

# for $XDG_CONFIG_HOME/* type targets
XDGC_TARGETS	= alacritty    \
		  i3           \
		  bspwm        \
		  dunst        \
		  rofi         \
		  sxhkd        \
		  base16-shell \
		  nvim         \
		  git

### Targets
all:		dir xdg

$(XDGC_TARGETS):
	$(LINK) $(PWD)/$@ $(XDGC)/$(@F)


dir:
	cd '$(HOME)'; mkdir -p $(HOME_DIRS)

xdg:
	$(LINK) ../$(DOTDIR)/$@/user-dirs.dirs $(XDGC)

FIREFOX_DIR	= $(HOME)/.mozilla/firefox
firefox:
	mkdir -p '$(FIREFOX_DIR)/profile/chrome'
	cp $@/profiles.ini '$(HOME)/.mozilla/firefox'
	cd '$(FIREFOX_DIR)/profile/chrome' && \
	    $(LINK) ../../../../$(DOTDIR)/$@/*.css .

compton:
	$(LINK) $(PWD)/$@/* $(XDGC)

bin:
	cd $(HOME)/bin && $(LINK) ../$(DOTDIR)/$@/* .

vim:
	mkdir -p $(HOME)/.vim
	$(LINK) $(DOTDIR)/$@/vimrc ../.vimrc
	$(LINK) ../$(DOTDIR)/$@/vim-plug ../.vim/

sh:
	$(LINK) $(DOTDIR)/$@/aliasrc ../.aliasrc
	$(LINK) $(DOTDIR)/$@/aliasrc.d ../.aliasrc.d
	$(LINK) $(DOTDIR)/$@/profile ../.profile

zsh:	base16-shell
	$(LINK) $(DOTDIR)/$@/zshrc ../.zshrc
	$(LINK) ../$(DOTDIR)/$@/zplug $(XDGC)

tmux:
	mkdir -p $(HOME)/.tmux/plugins
	$(LINK) $(DOTDIR)/$@/tmux.conf ../.tmux.conf
	$(LINK) ../../$(DOTDIR)/$@/tpm ../.tmux/plugins/tpm

xorg:
	$(LINK) $(DOTDIR)/$@/Xmodmap ../.Xmodmap
	$(LINK) $(DOTDIR)/$@/Xresources ../.Xresources
	$(LINK) $(DOTDIR)/$@/xprofile ../.xprofile
	$(LINK) $(DOTDIR)/$@/xinitrc ../.xinitrc

.PHONY: all dir xdg
.PHONY: $(XDGC_TARGETS)
.PHONY: compton bin vim sh zsh tmux xorg
