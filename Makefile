IMPLS        = $(wildcard implementations/*)
SCRIPTS      = $(wildcard scripts/*)
IMPL_NAMES   = $(notdir $(IMPLS))
SCRIPT_NAMES = $(notdir $(SCRIPTS))
LOGS         = $(foreach impl,$(IMPL_NAMES),$(foreach script,$(SCRIPT_NAMES),log/$(impl)-$(script).log))
EXPECT       = expect
EXPECTFLAGS  =
export IMPL  ?= btm_ruby.rb

all:
	@for log in $(LOGS); do \
		$(MAKE) $$log; \
	done

log/$(IMPL)-%.log : scripts/% implementations/$(IMPL)
	@echo ===================================================================
	@echo "Script: $<; Implementation: $(IMPL)"
	@echo ===================================================================
	$(EXPECT) $(EXPECTFLAGS) $< implementations/$(IMPL) $@
