;===================================
; draw_overlay
; ARGS:
; DESTR: 	fuck
;===================================
draw_overlay proc
	cld

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

	push kVideoMemAdr
	pop es

	call draw_frame
	call draw_regs

	ret
endp
;===================================
; draw_frame
; ARGS:
; 		es = vmem adr
; DESTR:	ax cx di si
;===================================
draw_frame proc
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
;===================================
; draw_regs
; ARGS:
; 		es = vmem adr
; DESTR:	di si cx ax
;===================================
draw_regs proc
	mov di, kFrameOffset
	add di, 164

	mov cx, 13
	mov si, offset kRegSymbls
	loop_draw_regs:
		push si

		mov ax, ss:[bp];
		inc bp
		inc bp
		call draw_reg
		add di, kScreenWidth * 2 - 11 * 2

		pop si
		inc si
		inc si
	loop loop_draw_regs

	ret
endp
;===================================
; draw_reg
; ARGS: 	di = dest offset
;		si = source offset
; 		ds = source segment
; 		es = vmem adr
;		ax = reg value
; DESTR:	di si cx ax
;===================================
draw_reg proc
	push bp
	push ax
	push cx
	mov bp, sp

	movsb
	inc di
	movsb
	inc di

	mov al, ' '
	stosb
	inc di

	mov al, '='
	stosb
	inc di

	mov al, ' '
	stosb
	inc di

	mov al, '0'
	stosb
	inc di

	mov al, 'x'
	stosb
	inc di


	; 0xf___
	mov ax, ss:[bp + 2]
	shr ah, 4
	xor al, al
	xchg ah, al
	mov cx, offset kNumTable
	add cx, ax
	mov si, cx
	movsb
	inc di

	; 0x_f__
	mov ax, ss:[bp + 2]
	and ah, 0fh
	xor al, al
	xchg ah, al
	mov cx, offset kNumTable
	add cx, ax
	mov si, cx
	movsb
	inc di

	; 0x__f_
	mov ax, ss:[bp + 2]
	shr al, 4
	xor ah, ah
	;
	mov cx, offset kNumTable
	add cx, ax
	mov si, cx
	movsb
	inc di

	; 0x___f
	mov ax, ss:[bp + 2]
	and al, 0fh
	xor ah, ah
	;
	mov cx, offset kNumTable
	add cx, ax
	mov si, cx
	movsb
	inc di

	pop cx
	pop ax
	pop bp
	ret
endp

;0xffff
nop
kFrameHight 	db 0fh
kFrameWidth 	db 0fh
kStartPosXY	dw 0000h

kFrameOffset 	dw 0000h

kStyleDef	db 0c9h, ' ', 0cdh, ' ', 0bbh, ' '
		db 0bah, ' ', ' ' , ' ', 0bah, ' '
		db 0c8h, ' ', 0cdh, ' ', 0bch, ' '

kRegSymbls	db 'csipaxbxcxdxsidibpspdssses'
kNumTable	db '0123456789ABCDEF'
nop
