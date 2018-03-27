[ORG 0x00]								;set code's starting address to 0x00
[BITS 16]   							;set following code as 16bits.

SECTION .text   						;define section(segment)

jmp 0x07c0:START						;copy 0x07c0 to CS segment and move to START label

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FMOS Configuration Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TOTALSECTORCOUNT: dw 2				;size of fmos image excluding BootLoader up to 1152 secotrs (0x90000bytes) available.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;code area;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
START:
	mov ax, 0x07c0						;set ax general register's value to BootLoader's starting address(0x7c00).
	mov ds, ax							;set DS segment register value to BootLoader's address.
	mov ax,0xb800						;set ax general register's value to video memory starting address(0xb800).
	mov es, ax							;set ES segment register value to video memory starting address.

	;generate a stack at 0x0000:0000~0x0000:ffff with 64kb size.
	mov ax, 0x0000						;to set the stack segment register value
	mov ss, ax							;ax value(0x0000) to ss(stack segment)
	mov sp, 0xfffe						;set sp(stack point register) address to 0xfffe
	mov bp, 0xfffe						;set bp(base point register) address to 0xfffe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;erase monitor screen, set character color to blue wtih black backbround.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov si, 0								;initiate si register(related to character string index) to 0
.SCREENCLEARLOOP:						;LOOP which erase monitor screen empty
	mov byte [es:si], 0					;set video memory starting address to 0(character)
	mov byte [es:si+1],0x0B				;set video memory starting address+1 to 0x0b(character color 'blue')
	add si, 2							;equals to si=si+2
	cmp si, 80*25*2						;compare si value to 80*25*2
	jl .SCREENCLEARLOOP					;if si register is less than 80*25*2 goto .SCREENCLEARLOOP label

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;print starting message at the top of the screen
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push MESSAGE1						;insert the address of the message to be output into the stack
	push 0								;insert y-coordinate(0) into the stack
	push 0								;insert x-coordinate(0) into the stack
	call PRINTMESSAGE					;call PRINTMESSAGE function
	add sp,6							;add sp to 6 to remove the inserted parameter.

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;print message to load os image
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push IMAGELOADINGMESSAGE			;insert the IMAGELOADINGMESSAGE to be output into the stack
	push 1								;insert y-coordinate(1) into the stack
	push 0								;insert x-coordinate(0)	into the stack
	call PRINTMESSAGE					;call PRINTMESSAGE function
	add sp,6							;add sp 6 to remove the inserted parameter.

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;load OS image from disk. but the disk bust be reset before reading
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RESETDISK:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;call BIOS Reset Function(service number 0, drive number 0=floppy)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax,0
	mov dl, 0
	int 0x13
	jc HANDLEDISKERROR					;if error occour then go to HANDLEDISKERROR

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;read sector from disk
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;set the address(ES:BX) to 0x10000 to copy the contents of the disk to memory.
	mov si, 0x1000						;set the si general register value to address of 0x100000.
	mov es, si							;set es segment register value to si.
	mov bx,0x0000						;by setting 0x0000 in the bx register, the address to be copied is finally determined as 0x1000:0000(0x10000).

	mov di, word[TOTALSECTORCOUNT]		;set the number of sectors of OS image to be copied to DI register.

READDATA:
	;make sure that all sectors have been read
	cmp di, 0							;compare the number of sectors in the os image to be copied to 0
	je READEND							;if sector is zero,go to REAdEND
	sub di, 0x1							;subtract one to the number of sectors to be copied.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;call the BIOS REad Function
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ah, 0x02						;bios service number2 (read sector)
	mov al, 0x1							;sector to be read is one
	mov ch, byte[TRACKNUMBER]			;set the track number to be read
	mov cl, byte [SECTORNUMBER]			;set the sector number to be read
	mov dh, byte [HEADNUMBER]			;set the head number to be read
	mov dl, 0x00						;set the drive number(0=floopy) to be read
	int 0x13							;software interrupt service routine
	jc HANDLEDISKERROR					;if error occour,go to HANDLEDISKERROR

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;calculate the copied address,track,sector,head
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	add si, 0x0020						;since it has been read by 512(0x200)bytes, it is converted into a segment register value.
	mov es,si
	mov al, byte[SECTORNUMBER]			;set the al register to the SECTORNUMBER
	add al, 0x01						;add 1 to the sector number.
	mov byte[SECTORNUMBER], al			;set the increased setor number to the SECTORNUMBER.
	cmp al,19
	jl READDATA							;if SECTOR NUMBER is less than 19 go to READDATA

	xor byte[HEADNUMBER], 0x01			;xor the HEADNUMBER with 0x01 and toggle
	mov byte[SECTORNUMBER], 0x01		;set the sectornumber to 1.

	cmp byte[HEADNUMBER],0x00
	jne READDATA						;if HEADNUMBER is not equal to 9 go to READDATA

	add byte[TRACKNUMBER],0x01
	jmp READDATA

READEND:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;print OS image Loading is completed
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	push LOADINGCOMPLETEMESSAGE
	push 1
	push 20
	call PRINTMESSAGE
	add sp,6

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;execute loaded OS image
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp 0x1000:0x0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;function code area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HANDLEDISKERROR:
	push DISKERRORMESSAGE
	push 1
	push 20
	call PRINTMESSAGE

	jmp $

PRINTMESSAGE:
	push bp
	mov bp,sp

	push es
	push si
	push di
	push ax
	push cx
	push dx
	mov ax, 0xb800

	mov es,ax

	mov ax, word[bp+6]
	mov si, 160
	mul si
	mov di,ax

	mov ax, word[bp+4]
	mov si,2
	mul si
	add di, ax

	mov si, word[bp+8]


.MESSAGELOOP:
	mov cl,byte [si]		;set cl(half of the CX register) register to MESSAGE1's address+ si value -> 1byte(1 character)
	cmp cl,0						;compare cl to 0
	je .MESSAGEEND					;if copied character value is equal to 0 goto .MESSAGEEND label
	mov byte[es:di],cl				;if it is not zero, that character should go to memory starting address(es+di) it means display
	add si,1						;si = si+1 => goto next character
	add di,2						;di = di+2 => goto next dot of monitor
	jmp .MESSAGELOOP				;goto messageLOOP and print next character

.MESSAGEEND:
	pop dx
	pop cx
	pop ax
	pop di
	pop si
	pop es
	pop bp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;data area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MESSAGE1:				db 'NOW FMOS BOOTLOADER START!!!!',0			;define printed message.;the last is set to 0 to allow processing by MESSAGELOOP

DISKERRORMESSAGE:		db 'DISK Error~!!',0
IMAGELOADINGMESSAGE:	db 'OS Image Loading...',0
LOADINGCOMPLETEMESSAGE: db 'Complete~!!',0

SECTORNUMBER:			db 0x02
HEADNUMBER:				db 0x00
TRACKNUMBER:			db 0x00

times 510 - ($-$$)	db	0x00		; $:address of current line
									;$$:start address of current section(.text)
									;$-$$:offset based on current section.
									;510-($-$$): current address to 510 address
									;db 0x00 : declare 1byte and value is 0x00
									;time : repeat again and again
									;in other words, in current address location to address 510, fill 0x00

db 0x55								;declare 1byte and value is 0x55
db 0xAA								;declare 1byte and value is 00xAA
									;it means that address 511 and 512 should be filled with 0x55,0xAA.Because it is BootLoader.
