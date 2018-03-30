XDGC	= $(HOME)/.config/
ROOT	= $(PWD)
LN	= -ln
LNFLAGS	= -s
LINK	= $(LN) $(LNFLAGS)

include bin/include.mk
include shell/include.mk
include wm/include.mk
include wmutil/include.mk


all:	dir

dir:	$(XDGC)/              \
	$(HOME)/bin/          \
	$(HOME)/.local/       \
	$(HOME)/.local/share/ \
	$(HOME)/.local/bin/   \
	$(HOME)/.local/src/


# For directories. Must be suffixed with / to match
%/:
	mkdir -p $@


### Alacritty
alacritty:	$(XDGC)/alacritty
$(XDGC)/alacritty: $(ROOT)/alacritty
	$(LINK) $? $@
