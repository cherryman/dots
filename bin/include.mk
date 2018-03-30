DIR	= $(ROOT)/bin

bin:	$(HOME)/bin/          \
	$(HOME)/bin/backlight \
	$(HOME)/bin/bar       \
	$(HOME)/bin/keymap    \
	$(HOME)/bin/mkscript  \
	$(HOME)/bin/notif     \
	$(HOME)/bin/startwm   \
	$(HOME)/bin/vol

$(HOME)/bin/%: $(DIR)/%
	$(LINK) $? $@
