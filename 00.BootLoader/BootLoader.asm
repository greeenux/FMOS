[ORG 0x00]  						;set code's starting address to 0x00
[BITS 16]   						;set following code as 16bits.

SECTION .text   					;define section(segment)

jmp 0x07c0:START					;copy 0x07c0 to CS segment and move to START label
START:
	mov ax, 0x07c0					;set ax general register's value to BootLoader's starting address(0x7c00).
	mov ds, ax						;set DS segment register value to BootLoader's address.
	mov ax,0xb800					;set ax general register's value to video memory starting address(0xb800).
	mov es, ax						;set ES segment register value to video memory starting address.

mov si, 0							;initiate si register(related to character string index) to 0
.SCREENCLEARLOOP:					;LOOP which erase monitor screen empty
	mov byte [es:si], 0				;set video memory starting address to 0(character)
	mov byte [es:si+1],0x0B			;set video memory starting address+1 to 0x0b(background color 'blue')
	add si, 2						;equals to si=si+2
	cmp si, 80*25*2					;compare si value to 80*25*2
	jl .SCREENCLEARLOOP				;if si register is less than 80*25*2 goto .SCREENCLEARLOOP label

mov si,0							;initiate si register to 0
mov di,0							;initiate di register(related to char string_object index) to 0
.MESSAGELOOP:
	mov cl,byte [si +MESSAGE1]		;set cl(half of the CX register) register to MESSAGE1's address+ si value -> 1byte(1 character)
	cmp cl,0						;compare cl to 0
	je .MESSAGEEND					;if copied character value is equal to 0 goto .MESSAGEEND label
	mov byte[es:di],cl				;if it is not zero, that character should go to memory starting address(es+di) it means display
	add si,1						;si = si+1 => goto next character
	add di,2						;di = di+2 => goto next dot of monitor
	jmp .MESSAGELOOP				;goto messageLOOP and print next character
.MESSAGEEND:

MESSAGE1:	db 'NOW FMOS BOOTLOADER START!!!!',0			;define printed message.;the last is set to 0 to allow processing by MESSAGELOOP

jmp $								;do the infinite loop in current stage

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
