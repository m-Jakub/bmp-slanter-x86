# Target executable file
EXEFILE = slbmp1

# Object files
OBJECTS = slbmp1.o slantbmp1.o

# Compiler and assembler formats
CCFMT = -m32
NASMFMT = -f elf32

# Compiler and assembler options
CCOPT = -g -O0 -Wall -Wextra
NASMOPT = -g -F dwarf -w+all

# Default target
.PHONY: all clean
all: $(EXEFILE)

# Rule for building the executable
$(EXEFILE): $(OBJECTS)
	$(CC) $(CCFMT) -o $@ $^

# Rule for compiling C files to object files
%.o: %.c
	$(CC) $(CCFMT) $(CCOPT) -c $< -o $@

# Rule for assembling .s files to object files
%.o: %.s
	nasm $(NASMFMT) $(NASMOPT) -l $*.lst -o $@ $<

# Clean target
clean:
	rm -f *.o *.lst $(EXEFILE)
