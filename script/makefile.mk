
include Makefile

print-var-%:
	@printf "%b" "$($*)"

preprocess-%:
	@echo $(CC)$ $(CFLAGS) $(CPPFLAGS) -E $*.c | awk -E $(AWKFILE)
