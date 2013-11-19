; Compile with NASM: "nasm filename"
[BITS 32]
	xor ecx, ecx		; set ecx to 0x0
	push ecx		; push 0x0 onto the stack
	push "n/ls"		; add "//bin/ls" to the stack
   	push "//bi"
	mov ebx, esp		; save a pointer to this location

	push ecx	 	; push 0x0 onto the stack
	push "//-l"		; push the argument: "//-l" onto the stack 
	mov ecx, esp		; save pointer to this location

	xor eax, eax		; zero out eax
	push eax		; push 0x0 onto the stack

	;int execve(const char *filename,char *const argv[],char *const envp[])
	; execve("//bin/ls", "//-l", NULL);
	push ecx		; save ecx onto the stack
	mov ecx, esp		; get a pointer to ecx
	mov al, 0x0B		; callcode of execve
	xor edx, edx		; envp = null
	int 0x80		; call kernel
