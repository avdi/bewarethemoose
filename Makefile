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

################################################################################
# RULES
################################################################################
all:
	@. functions.sh;													\
	for impl in $(dir $?); do $(MAKE) `impl_logs $$impl`; done

clean:
	-rm -r ./log

log/%.log: log
	@. functions.sh;													\
	$(MAKE) -C implementations/`log_impl $@` btm;						\
	run_script `log_impl $@` `log_script $@` $@

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

