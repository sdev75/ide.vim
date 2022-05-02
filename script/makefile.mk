
include Makefile

print-var_-%:
	@printf "%b" "$($*)"

setflags : BUILD = release
setflags : EXTRA_CFLAGS = -ggdb
setflags:
	echo test

preprocess-%:
	@echo $(CC) $(CFLAGS) $(CPPFLAGS) -E $*.c | awk -E $(AWKFILE)

preprocess_:
	$(CC) $(CFLAGS) $(CPPFLAGS) -E $(FILENAME) | awk -E $(AWKFILE)

objdump_: $(basename $(FILENAME)).o
	objdump -D $(basename $(FILENAME)).o -M intel -j .text -l

objdump_dwarf_: $(basename $(FILENAME)).o
	objdump -dj .text -M intel $< -l

objdump_symtable_: $(basename $(FILENAME)).o
	objdump -t $<

test_cmd_:
	@echo $$FILENAME and $$VAR2
