SHELL        = /bin/bash
BASH_ENV     = ./functions.sh
IMPLS        = $(wildcard implementations/*)
SCRIPTS      = $(wildcard scripts/*)
IMPL_NAMES   = $(notdir $(IMPLS))
SCRIPT_NAMES = $(notdir $(SCRIPTS))
EXECUTABLES  = $(addsuffix /btm, $(IMPLS))
EXPECT       = expect
EXPECTFLAGS  =

################################################################################
# FUNCTIONS
################################################################################
impl_name		= $(notdir $(1))
script_name		= $(notdir $(1))
impl_logs		= $(foreach script,										\
							$(SCRIPT_NAMES),							\
							log/$(call impl_name,$(1))-$(script).log)	
log_script		= $(shell basename $(1) .log | cut -d - -f 2)
log_impl		= $(shell basename $(1) .log | cut -d - -f 1)
log_exec		= implementations/$(call log_impl, $(1))/btm
log_result      = $(wildcard $(basename $(1))-*.log)


################################################################################
# RULES
################################################################################
all: $(foreach impl, $(IMPL_NAMES), $(call impl_logs,$(impl)))

clean:
	-rm -r ./log

log/%.log: 
	$(MAKE) run_script LOG=$@

run_script: IMPL   = $(call log_impl, $(LOG))
run_script: SCRIPT = $(call log_script, $(LOG))
run_script: HEADER = $(IMPL) / $(SCRIPT)
run_script: $(IMPL) $(SCRIPT) log
	@echo
	@echo "============================================================"
	@echo "Running $(HEADER)"
	@echo "------------------------------------------------------------"

	@if scripts/$(SCRIPT) implementations/$(IMPL)/btm; then \
      ln -s `basename $(LOG)` log/`basename $(LOG) .log`-PASS.log; \
    else \
      ln -s `basename $(LOG)` log/`basename $(LOG) .log`-FAIL.log; \
    fi | tee $(LOG)

	@echo
	@echo "------------------------------------------------------------"
	@ls log/`basename $(LOG) .log`-*.log
	@echo "============================================================"

log:
	mkdir $@

shell:
	exec $(SHELL) -i

list_implementations:
	@for impl in $(IMPL_NAMES); do echo $$impl; done

list_scripts:
	@for script in $(SCRIPT_NAMES); do echo $$script; done

$(EXECUTABLES):
	@impl_dir=$(dir $@);										\
	if [ -e $$impl_dir/Makefile ]; then							\
		$(MAKE) -C $$impl_dir;									\
	else														\
		echo "No Makefile for $$impl_dir; skipping.";			\
	fi															\

