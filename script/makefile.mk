
include Makefile

ifeq ($(FILENAME),)
$(error FILENAME variable cannot be empty)
endif

OBJDIR := $(CURDIR)/.ide/obj
FILENAME_BASE := $(subst $(CURDIR),,$(FILENAME))
FILENAME_OBJ := $(basename $(FILENAME_BASE)).o
FILENAME_OUT := $(addprefix $(OBJDIR), $(FILENAME_OBJ))
OUTPUT_DIR := $(OBJDIR)$(dir $(FILENAME_BASE))
ARCH := $(shell uname -m)

ifeq ($(ARCH),aarch64)
	DISASM_SYNTAX_FLAG := 
else
	DISASM_SYNTAX_FLAG := -M intel	
endif

printvar_%:
	@printf "%b" "$($*)"

printenv_:
	@printf "%20s: %-20s\n" "FILENAME" $(FILENAME)
	@printf "%20s: %-20s\n" "FILENAME OUT" $(FILENAME_OUT)
	@printf "%20s: %-20s\n" "OUTPUT DIR" $(OUTPUT_DIR)

$(OUTPUT_DIR)%.o: $(FILENAME) | $(OUTPUT_DIR)
	@echo "RUNNING .O OVERRIDEN"
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $(FILENAME) -o $(FILENAME_OUT)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

#preprocess_:
#	echo $(CC) $(CFLAGS) $(CPPFLAGS) -E $(FILENAME) | awk -E $(AWKFILE)
#
#objdump_: $(basename $(FILENAME)).o
#	echo objdump -D $(basename $(FILENAME)).o -M intel -j .text -l
#
objdump-dwarf_: $(FILENAME_OUT)
	objdump --disassemble --reloc -j .text $(DISASM_SYNTAX_FLAG) $< -l

preprocess_: $(FILENAME)
#$(CC) -E $(CFLAGS) $(CPPFLAGS) $< | cat -s
	$(CC) -E $(CFLAGS) $(CPPFLAGS) $< | awk -E $(AWKFILE) | cat -s

#
#objdump_symtable_: $(basename $(FILENAME)).o
#	echo objdump -t $<

readelf-syms_: $(FILENAME_OUT)
	readelf -s $(FILENAME_OUT)

objdump-syms_: $(FILENAME_OUT)
	objdump -tr $(FILENAME_OUT)

readelf-relocs_: $(FILENAME_OUT)
	readelf --relocs $(FILENAME_OUT)

readelf-symbols_: $(FILENAME_OUT)
	readelf --symbols $(FILENAME_OUT)
