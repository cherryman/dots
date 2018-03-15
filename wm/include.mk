DIR	= $(ROOT)/wm

i3:	$(XDGC)/i3
bspwm:	$(XDGC)/bspwm

$(XDGC)/%: $(DIR)/%
	$(LINK) $? $@
