.model tiny
.286
.code
org 100h

kScreenWidth   	equ 80d
kScreenHight   	equ 25d
kSlashN        	equ 0dh
kVideoMemAdr   	equ 0b800h
kExitMagic     	equ 4ch
kExitOk		equ 00h
kCliArgsOffset 	equ 80h

Start:
	mov ax, 3509h	; int 21h(35h)(09h)
	int 21h		; get adr of 09h -> es:bx

	mov Old09Offset, bx	;
	mov bx, es		; generate jump
	mov Old09Seg, bx	;

	push ds				; load
	push cs				; new
	pop ds				; 09h
	mov dx, offset my_int09h_kb	; to
	mov ax, 2509h			; int
	int 21h				; table
	pop ds				;

	mov dx, offset end_of_program	;
	shr dx, 4			;
	inc dx				; terminate program
	mov ax, 3100h			; and stay in mem
	int 21h				;
ret

my_int09h_kb proc
	push ax bx cx dx si di bp sp ds ss es
	mov bp, sp
	sub bp, 24
	;================
	in al, 61h 	; listens 61h port
	or al, 80h 	; turn on left bit == dis kb
	out 61h, al	; tell 61h port to desable kb

	in al, 60h	; read from kb
	mov ah, al	;

	in al, 61h
	and al, not 80h ; 01..1 turn off left bit == enb kb
	out 61h, al	; tells 61h port to enable kb
	;================

	cmp ah, 2
	jne skip_lbl_int09
		push cs
		pop ds
		call draw_overlay
	skip_lbl_int09:

	pop es ss ds sp bp di si dx cx bx ax

	db 0eah			; far jump
	Old09offset	dw 00h	;
	Old09Seg	dw 00h	;
endp

include draw.asm

end_of_program:

end Start
