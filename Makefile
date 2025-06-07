XDGC		= $(HOME)/.config
DOTDIR		= dots
LNFLAGS		=
LINK		= ln -sfn $(LNFLAGS)

HOME_DIRS	= .config bin                               \
		  .local .local/share .local/src .local/bin \
		  doc doc/desk doc/www                      \
		  media media/pic media/vid media/music

### Targets
.PHONY: all
all: dir xdg

# for $XDG_CONFIG_HOME/* type targets
XDGC_TARGETS	= alacritty    \
		  mpv          \
		  i3           \
		  sway	       \
		  waybar       \
		  picom        \
		  bspwm        \
		  dunst        \
		  rofi         \
		  sxhkd        \
		  fontconfig   \
		  base16-shell \
		  tmux         \
		  htop         \
		  nvim         \
		  emacs        \
		  doom         \
		  darktable    \
		  hypr         \
		  eww          \
		  btop         \
		  qmk          \
		  direnv       \
		  aerospace    \
		  fish         \
		  ghostty      \
		  xonsh        \
		  git

.PHONY: $(XDGC_TARGETS)
$(XDGC_TARGETS):
	$(LINK) ../$(DOTDIR)/$@ $(XDGC)/$(@F)


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
	mkdir -p $(HOME)/bin
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
	$(LINK) $(DOTDIR)/$@/env ../.env

.PHONY: zsh
zsh:	base16-shell
	$(LINK) $(DOTDIR)/$@/zshrc ../.zshrc
	$(LINK) $(DOTDIR)/$@/zshenv ../.zshenv
	$(LINK) ../$(DOTDIR)/$@/zplug $(XDGC)

.PHONY: npm
npm:
	$(LINK) $(DOTDIR)/$@/npmrc ../.npmrc

.PHONY: restic
restic:
	$(LINK) $(DOTDIR)/$@/exclude ../.resticexclude

.PHONY: redshift
redshift:
	$(LINK) ../$(DOTDIR)/$@/redshift.conf $(XDGC)

.PHONY: python
python:
	$(LINK) ../$(DOTDIR)/$@/pythonrc.py $(XDGC)

.PHONY: xorg
xorg: xkb
	$(LINK) $(DOTDIR)/$@/Xresources ../.Xresources
	$(LINK) $(DOTDIR)/$@/xprofile ../.xprofile
	$(LINK) $(DOTDIR)/$@/xinitrc ../.xinitrc

.PHONY: xkb
xkb:
	(cd / && sudo patch -u -p0 < "$(PWD)/$@/patch")

.PHONY: claude
claude:
	$(LINK) $(DOTDIR)/$@ ../.claude
