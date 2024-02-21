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
	; push 0		;
	; pop es		;

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
	; add bx, 4 * 09h	; start of int 09h ref

	; push cs				;
	; pop ax				;
	; cli				; rewrite int 09h
	; mov es:[bx], offset my_int09h_kb;
	; mov es:[bx + 2], ax		;
	; sti				;

	mov dx, offset end_of_program	;
	shr dx, 4			;
	inc dx				; terminate program
	mov ax, 3100h			; and stay in mem
	int 21h				;
ret

my_int09h_kb proc
	pusha 	; doesnt save segment
	push ds
	push es

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
		call draw_frame
	skip_lbl_int09:

	pop es
	pop ds
	popa

	db 0eah			; far jump
	Old09offset	dw 00h	;
	Old09Seg	dw 00h	;

	; mov al, 20h	; EOI
	; out 20h, al	; //NOTE: what does??

	; iret
endp
;===================================
; draw_frame
; ARGS: 	NONE
; DESTR:	ax cx di si es
;===================================
draw_frame proc
	; cld
	mov si, offset kStartPosXY
	inc si
	xor ax, ax
	mov al, [si]
	xor cx, cx
	mov cl, 160
	mul cl
	add al, byte ptr kStartPosXY ; what?
	add al, byte ptr kStartPosXY

	mov kFrameOffset, ax
	;------------
	push kVideoMemAdr
	pop es

	mov di, kFrameOffset
	mov si, offset kStyleDef

	call draw_line

	xor ax, ax
	mov al, kFrameWidth
	sub di, ax
	sub di, ax
	add di, kScreenWidth * 2

	xor cx, cx
	mov cl, kFrameHight
	sub cx, 2

loop_draw_frame:
	push cx
	call draw_line
	pop cx
	sub si, 6
	xor ax, ax
	mov al, kFrameWidth
	sub di, ax
	sub di, ax
	add di, kScreenWidth * 2

	loop loop_draw_frame
	add si, 6

	call draw_line

	ret
endp

;===================================
; draw_line
; ARGS: 	di = offset
; 		si = source
; 		ds = source segment
; 		es = vmem adr
; DESTR:	di si cx ax
;===================================
draw_line proc
	movsw

	xor cx, cx
	mov cl, kFrameWidth
	sub cx, 2
	lodsw
	rep stosw

	movsw

	ret
endp

nop

kFrameHight 	db 08h
kFrameWidth 	db 10h

kFrameOffset 	dw 0000h
kStartPosXY	dw 0606h

kStyleDef	db '+ - + |   | + - + '

nop

end_of_program:

end Start
