DIR	= $(ROOT)/wmutil

compton:	$(XDGC)/compton.conf
dunst:		$(XDGC)/dunst
rofi:		$(XDGC)/rofi
sxhkd:		$(XDGC)/sxhkd
xorg:		$(HOME)/.Xmodmap    \
		$(HOME)/.Xresources \
		$(HOME)/.xinitrc    \
		$(HOME)/.xprofile

$(XDGC)/%: $(DIR)/%
	$(LINK) $? $@

$(HOME)/.%: $(DIR)/xorg/%
	$(LINK) $? $@

$(XDGC)/compton.conf: $(DIR)/compton/compton.conf
	$(LINK) $? $@
