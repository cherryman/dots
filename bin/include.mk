DIR	= $(ROOT)/bin

bin:	$(HOME)/bin/          \
	$(HOME)/bin/backlight \
	$(HOME)/bin/bar       \
	$(HOME)/bin/keymap    \
	$(HOME)/bin/startwm   \
	$(HOME)/bin/volume

$(HOME)/bin/%: $(DIR)/%
	$(LINK) $? $@
