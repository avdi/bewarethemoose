IMPLS        = $(wildcard implementations/*)
SCRIPTS      = $(wildcard scripts/*)
IMPL_NAMES   = $(notdir $(IMPLS))
SCRIPT_NAMES = $(notdir $(SCRIPTS))
LOGS         = $(foreach impl,$(IMPL_NAMES),$(foreach script,$(SCRIPT_NAMES),log/$(impl)-$(script).log))
EXPECT       = expect
EXPECTFLAGS  =
export IMPL  ?= ruby

all:
	$(MAKE) log/hello-$(IMPL).log
	$(MAKE) log/mazes_local-$(IMPL).log
	$(MAKE) log/aisles_local-$(IMPL).log

log/%-$(IMPL).log : scripts/% implementations/$(IMPL)
	$(EXPECT) $(EXPECTFLAGS) implementations/$(IMPL) $< $@
