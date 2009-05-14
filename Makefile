SHELL        = bash --rcfile functions.sh
IMPLS        = $(wildcard implementations/*)
SCRIPTS      = $(wildcard scripts/*)
IMPL_NAMES   = $(notdir $(IMPLS))
SCRIPT_NAMES = $(notdir $(SCRIPTS))
EXECUTABLES  = $(addsuffix /btm, $(IMPLS))
EXPECT       = expect
EXPECTFLAGS  =


all: $(EXECUTABLES)
	@. functions.sh;													\
	for impl in $(dir $?); do $(MAKE) `impl_logs $$impl`; done

log/%.log: log
	@. functions.sh;													\
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

