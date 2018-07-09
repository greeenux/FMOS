[ORG 0x00]
[BITS 16]

SECTION .text
;;;;;;;;;;
;code section
;;;;;;;;;;
START:
	mov ax, 0x1000
	mov ds, ax
	mov es, ax
;
;activate a20 gate with bios service iferror occour go to system control port
;
	mov ax, 0x2401
	int 0x15

	jc .A20GATEERROR
	jmp .A20GATESUCCESS

.A20GATEERROR:
		in al, 0x92
		or al, 0x02
		and al, 0xfe
		out 0x92,al
.A20GATESUCCESS:
	cli
	lgdt [GDTR]
	mov eax, 0x4000003B
	mov cr0, eax
	jmp dword 0x18:(PROTECTEDMODE - $$ + 0x10000)

[BITS 32]
PROTECTEDMODE:
	mov ax,0x20
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov gs,ax

	mov ss,ax
	mov esp,0xfffe
	mov ebp,0xfffe

	push (SWITCHSUCCESSMESSAGE -$$ + 0X10000)
	push 2
	push 0
	call PRINTMESSAGE
	add esp,12

	jmp dword 0x18:0x10200 ; go to the address 0x10200 and execute c language kernel

;;;;;;;;;;;;;;;;;;;;;;;;;;
;FUNCTION code section
;;;;;;;;;;;;;;;;;;;;;;;;;;

PRINTMESSAGE:
	push ebp
	mov ebp,esp
	push esi
	push edi
	push eax
	push ecx
	push edx

	mov eax, dword[ebp+12]
	mov esi, 160
	mul esi
	mov edi, eax

	mov eax, dword[ebp+8]
	mov esi,2
	mul esi
	add edi, eax

	mov esi, dword[ebp +16]

.MESSAGELOOP:
	mov cl, byte[esi]

	cmp cl,0
	je .MESSAGEEND
	mov byte[edi+0xB8000],cl

	add esi,1
	add edi,2

	jmp .MESSAGELOOP

.MESSAGEEND:
	pop edx
	pop ecx
	pop eax
	pop edi
	pop esi
	pop ebp
	ret

;;;;;;;;;;;;;;;;;;;;;;
;DATA section
;;;;;;;;;;;;;;;;;;;;;;

align 8, db 0
dw 0x0000
GDTR:
	dw GDTEND - GDT -1
	dd (GDT -$$ + 0x10000)

GDT:
	NULLDescriptor:
		dw 0x0000
		dw 0x0000
		db 0x00
		db 0x00
		db 0x00
		db 0x00

	
	IA_32eCODEDESCRIPTOR:
		dw 0xFFFF					; Limit [15:0]
		dw 0x0000					; Base [15:0]
		db 0x00						; Base [23:16]
		db 0x9A						; P = 1, DPL = 0, Code Segment, Execute/Read
		db 0xAF						; G = 1, D = 0, L = 1, Limit [19:16]
		db 0x00						; Base [31:24]
	
	IA_32eDATADESCRIPTOR:
		dw 0xFFFF					; Limit [15:0]
		dw 0x0000					; Base [15:0]
		db 0x00						; Base [23:16]
		db 0x92						; P = 1, DPL = 0, Data Segment, Read/Write
		db 0xAF						; G = 1, D = 0, L = 1, Limit [19:16]
		db 0x00						; Base [31:24]
	

	CODEDESCRIPTOR:
		dw 0xffff
		dw 0x0000
		db 0x00
		db 0x9a 
		db 0xcf
		db 0x00

	DATADESCRIPTOR:
		dw 0xffff
		dw 0x0000
		db 0x00
		db 0x92
		db 0xcf
		db 0x00
GDTEND:
SWITCHSUCCESSMESSAGE: db 'Switch To Protected Mode Success~!!',0

times 512 -($ -$$) db 0x00
