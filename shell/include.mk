.PHONY: sh zsh vim nvim tmux git

DIR	= $(ROOT)/shell


### sh
sh: 	$(HOME)/.profile
$(HOME)/.%: $(DIR)/sh/%
	$(LINK) $? $@


### zsh
zsh:	sh $(HOME)/.zshrc $(XDGC)/zplug $(XDGC)/base16-shell

$(HOME)/.%: $(DIR)/zsh/%
	$(LINK) $? $@

$(XDGC)/%: $(DIR)/zsh/%
	$(LINK) $? $@


### vim
vim:	$(HOME)/.vim/ $(HOME)/.vimrc $(HOME)/.vim/vim-plug

$(HOME)/.vimrc: $(DIR)/vim/vimrc
	$(LINK) $? $@

$(HOME)/.vim/vim-plug: $(DIR)/vim/vim-plug
	$(LINK) $? $@


### nvim
nvim:	vim $(XDGC)/nvim

$(XDGC)/nvim: $(DIR)/nvim
	$(LINK) $? $@


### tmux
tmux:	$(HOME)/.tmux.conf $(HOME)/.tmuxline.conf \
	$(HOME)/.tmux/plugins/ $(HOME)/.tmux/plugins/tpm

$(HOME)/.%.conf: $(DIR)/tmux/%.conf
	$(LINK) $? $@

$(HOME)/.tmux/plugins/tpm: $(HOME)/.tmux/plugins/ $(DIR)/tmux/tpm
	$(LINK) $(DIR)/tmux/tpm $@


### git
git:	$(XDGC) $(XDGC)/git/ $(XDGC)/git/config $(XDGC)/git/ignore

$(XDGC)/git/%: $(DIR)/git/%
	$(LINK) $? $@
