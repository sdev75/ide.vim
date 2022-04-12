
include Makefile

print-var_-%:
	@printf "%b" "$($*)"

preprocess-%:
	@echo $(CC) $(CFLAGS) $(CPPFLAGS) -E $*.c | awk -E $(AWKFILE)

preprocess_:
	$(CC) $(CFLAGS) $(CPPFLAGS) -E $(FILENAME) | awk -E $(AWKFILE)

objdump_: $(basename $(FILENAME)).o
	objdump -D $(basename $(FILENAME)).o -M intel -j .text -l

