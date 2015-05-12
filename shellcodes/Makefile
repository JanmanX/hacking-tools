ASM=nasm
F_ASM=-f elf

LFLAGS=-m elf_i386


all: runshellcode bin_sh bin_ls bind_shell connectback_sh


runshellcode: runshellcode.asm
	$(ASM) $(F_ASM) runshellcode.asm
	ld $(LFLAGS) runshellcode.o -o bin/runshellcode
	rm runshellcode.o

bin_sh: bin_sh.asm
	$(ASM) bin_sh.asm -o bin/bin_sh

bin_ls:	bin_ls.asm
	$(ASM) bin_ls.asm -o bin/bin_ls

bind_shell:	bind_shell.asm
	$(ASM) bind_shell.asm -o bin/bind_shell

connectback_sh: connectback_sh.asm
	$(ASM) connectback_sh.asm -o bin/connectback_sh

clean:
	-rm -fv *.o bin/*
	-rm -fv a.out
