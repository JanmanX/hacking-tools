%define SYS_OPEN 0x05
%define SYS_READ 0x03
%define SYS_WRITE 0x04
%define O_RDONLY 0x0000
%define STDOUT 0x01

%define SHELLCODE_SIZE 0x200

section .data
	error_generic db "Error occured", 0xA, 0x0
	error_generic_len equ $-error_generic
	error_arg_msg db "No argument given. Terminating",0xA, 0x0
	error_arg_msg_len equ $-error_arg_msg

section .bss
	shellcode resb SHELLCODE_SIZE	; Shellcode buffer

section .text
	global _start
_start:
	push ebp						; Create stack frame
	mov ebp, esp					; ---

	mov eax, DWORD [ebp+0x4]		; get number of arguments
	cmp eax, 0x1
	jle _print_error				; Print error message if only 1 argument given

	mov esi, DWORD [ebp+0xc]		; get first "real" argument

	; OPEN
	; int open(const char *pathname, int flags);
	mov eax, 0x05
	mov ebx, esi
	mov ecx, O_RDONLY
	int 0x80

	; error check
	cmp eax, 0x0
	jle _generic_error

	; READ
	; ssize_t read(int fd, void* buf, size_t count)
	mov ebx, eax
	mov eax, SYS_READ
	mov ecx, shellcode
	mov edx, SHELLCODE_SIZE
	int 0x80

	; Save bytes read for later
	push eax

	; CLOSE FD
	mov eax, 0x06
	int 0x80

	pop eax				;Get bytes read
	call _print_shellcode

	; RUN SHELLCODE
	jmp shellcode

	jmp _exit

_exit:
	mov esp, ebp
	pop ebp

	mov eax, 0x1
	mov ebx, 0x0
	int 0x80


_print_error:
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, error_arg_msg
	mov edx, error_arg_msg_len
	int 0x80
	call _exit

_generic_error:
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, error_generic
	mov edx, error_generic_len
	int 0x80
	call _exit

_print_shellcode:
	mov edx, eax			; Bytes read
	inc edx
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, shellcode
	int 0x80

	; Print new line
	push ebp
	mov ebp, esp

	push 0x00
	push 0x0A 			; New Line

	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, esp
	mov edx, 1
	int 0x80


	mov esp, ebp
	pop ebp
	ret
