XDGC		= $(HOME)/.config
DOTDIR		= dots
LN		= ln
LNFLAGS		=
LINK		= $(LN) -sfn $(LNFLAGS)

HOME_DIRS	= .config bin                               \
		  .local .local/share .local/src .local/bin \
		  doc doc/desk doc/www                      \
		  media media/pic media/vid media/music

# for $XDG_CONFIG_HOME/* type targets
XDGC_TARGETS	= alacritty    \
		  mpv          \
		  i3           \
		  sway	       \
		  waybar       \
		  bspwm        \
		  dunst        \
		  rofi         \
		  sxhkd        \
		  base16-shell \
		  nvim         \
		  git

### Targets
.PHONY: all
all: dir xdg

.PHONY: $(XDGC_TARGETS)
$(XDGC_TARGETS):
	$(LINK) $(PWD)/$@ $(XDGC)/$(@F)


.PHONY: dir
dir:
	cd '$(HOME)'; mkdir -p $(HOME_DIRS)

.PHONY: xdg
xdg:
	$(LINK) ../$(DOTDIR)/$@/user-dirs.dirs $(XDGC)

FIREFOX_DIR	= $(HOME)/.mozilla/firefox
.PHONY: firefox
firefox:
	mkdir -p '$(FIREFOX_DIR)/profile/chrome'
	cp $@/profiles.ini '$(HOME)/.mozilla/firefox'
	cd '$(FIREFOX_DIR)/profile/chrome' && \
	    $(LINK) ../../../../$(DOTDIR)/$@/*.css .

.PHONY: bin
bin:
	cd $(HOME)/bin && $(LINK) ../$(DOTDIR)/$@/* .

.PHONY: vim
vim:
	mkdir -p $(HOME)/.vim $(HOME)/.cache/vim
	$(LINK) $(DOTDIR)/$@/vimrc ../.vimrc
	$(LINK) ../$(DOTDIR)/$@/vim-plug ../.vim/
	$(LINK) ../$(DOTDIR)/$@/snippets ../.vim/

.PHONY: sh
sh:
	$(LINK) $(DOTDIR)/$@/profile ../.profile
	$(LINK) ../$(DOTDIR)/$@/shell $(XDGC)

.PHONY: zsh
zsh:	base16-shell
	$(LINK) $(DOTDIR)/$@/zshrc ../.zshrc
	$(LINK) ../$(DOTDIR)/$@/zplug $(XDGC)

.PHONY: tmux
tmux:
	mkdir -p $(HOME)/.tmux/plugins
	$(LINK) $(DOTDIR)/$@/tmux.conf ../.tmux.conf
	$(LINK) ../$(DOTDIR)/$@/scripts ../.tmux/scripts
	$(LINK) ../../$(DOTDIR)/$@/tpm ../.tmux/plugins/tpm

.PHONY: npm
npm:
	$(LINK) $(DOTDIR)/$@/npmrc ../.npmrc

.PHONY: redshift
redshift:
	$(LINK) ../$(DOTDIR)/$@/redshift.conf $(XDGC)

.PHONY: xorg
xorg: xkb
	$(LINK) $(DOTDIR)/$@/Xresources ../.Xresources
	$(LINK) $(DOTDIR)/$@/xprofile ../.xprofile
	$(LINK) $(DOTDIR)/$@/xinitrc ../.xinitrc

.PHONY: xkb
xkb:
	(cd / && sudo patch -u -p0 < "$(PWD)/$@/patch")
