XDGC	= $(HOME)/.config/
ROOT	= $(PWD)
LN	= -ln
LNARGS	= -s
LINK	= $(LN) $(LNARGS)

include bin/include.mk
include shell/include.mk
include wm/include.mk
include wmutil/include.mk


all:	$(XDGC) \
	$(HOME)/.local

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
