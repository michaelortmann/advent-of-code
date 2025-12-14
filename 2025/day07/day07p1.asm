; SPDX-License-Identifier: MIT
; Copyright (c) 2025 Michael Ortmann

; Description:
;
; https://adventofcode.com/2025/day/7 - part 1
;
;   input via file
;
; Usage / Example:
;
;   $ vasmm68k_mot -Fhunkexe -kick1hunks day07p1.asm -o day07p1 -opt-speed -nosym
; xdftool day07p1.adf format day07p1 + boot install + makedir s + write startup-sequence s + write day07p1 + protect day07p1 +er + write input
;   $ amiberry -r kick13.rom -0 day07p1.adf.gz -G
;   $ fs-uae --floppy-drive-0=day07p1.adf.gz
;   $ cp day07p1.adf /mnt/ROMS/
;
; Enjoy,
; Michael

_AbsExecBase		equ	4
; exec.library
_LVOAllocMem		equ	-198
_LVOCloseLibrary	equ	-414
_LVOOpenLibrary		equ	-552
; dos.library
_LVOOpen		equ	-30
_LVOClose		equ	-36
_LVORead		equ	-42
_LVOWrite		equ	-48
_LVOOutput		equ	-60
_LVOLock		equ	-84
_LVOUnLock		equ	-90
_LVOExamine		equ	-102
MEMF_PUBLIC		equ	1
ACCESS_READ		equ	-2
MODE_OLDFILE		equ	1005
RETURN_OK		equ	0
RETURN_FAIL		equ	20
; DOS_FIB offsets
fib_Size		equ	124	; Number of bytes in file
fib_SIZEOF		equ	260	; FileInfoBlock

; read file

	move.l	_AbsExecBase,a6		; get ExecBase
	lea	DosName(pc),a1		; libName
	moveq	#0,d0			; version
	jsr	_LVOOpenLibrary(a6)	; open dos.library
	beq	return_fail		; error

	move.l	d0,a6			; get DosBase
	move.l	#FileName,d1		; file name
	move.l	d1,d4			; save file name
	moveq	#ACCESS_READ,d2		; accessMode
	jsr	_LVOLock(a6)
	beq	return_fail		; error

	move.l	d0,d3			; save lock
	move.l	sp,d5			; save stack
	move.l	d0,d1			; lock
	; i decline to heap allocate when stack can be aligned
	move.l	sp,d2
	sub.l	#fib_SIZEOF,d2		; infoBlock - pointer to a
					; FileInfoBlock (MUST be longword
					; aligned)
	and.b	#$fc,d2			; align 4
	move.l	d2,sp
	jsr	_LVOExamine(a6)
	beq	return_fail_sp		; error

	move.l	d3,d1			; lock
	jsr	_LVOUnLock(a6)

	move.l	a6,a2			; save DosBase
	move.l	_AbsExecBase,a6		; get ExecBase
	move.l	fib_Size(sp),d0		; len
	move.l	d0,d3			; len
	moveq	#MEMF_PUBLIC,d1		; attributes
	jsr	_LVOAllocMem(a6)
	move.l	d5,sp			; restore sp
	beq	return_fail		; error

	move.l  d0,d5			; save buf
	move.l	a2,a6			; get DosBase
	move.l	d4,d1			; file name
	move.l	#MODE_OLDFILE,d2	; accessMode
	jsr	_LVOOpen(a6)
	beq	return_fail		; error

	move.l	d0,d1			; file handle
	move.l	d5,d2			; buf
	move.l	d0,d5			; save file handle
	jsr	_LVORead(a6)
	cmp.l	d0,d3			; read() == file size ?
	bne	return_fail		; error

	move.l	d5,d1			; file handle
	jsr	_LVOClose(a6)
	beq	return_fail		; error

; solution

; input  d2 buf
;        d3 buf len
; output a0 len(line)

	; get line len

	move.l	d2,a1			; next_line = buf
loop0:
	cmp.b	#$0a,(a1)+		; *(line_len     ) == '\n' ?
	beq	fini0
	bra	loop0
fini0:

	; make d3 point to last line: d2 + d3 - (a1 - d2) = d2 + d3 - a1 + d2
	add.l	d2,d3			; end of buf
	sub.l	a1,d3
	add.l	d2,d3

	; mainloop

	move.l	d2,a0			; buf
	moveq	#'S',d0
	moveq	#'^',d1
	moveq	#0,d4			; result
loop1:
	cmp.b	(a0),d0			; buf[x] == 'S' ?
	bne	label1
	cmp.b	(a1),d1			; *(next_line    ) == '^' ?
	bne	label0
	addq	#1,d4			; result++
	move.b	d0,-1(a1)		; *(next_line - 1) = 'S'
	move.b	d1,(a1)			; *(next_line    ) = '^'
	move.b	d0,1(a1)		; *(next_line + 1) = 'S'
	bra	label1
label0:
	move.b 	d0,(a1)			; *(next_line    ) = S
label1:
	addq	#1,a0			; buf++;
	addq	#1,a1			; next_line++
	cmp.l	a0,d3			; last line ?
	bne	loop1

; output

	move.l	d2,a5			; buf - reuse buf as output for bin2dec
	move.l	d2,d3			; save buf 
	bsr	bin2dec

	move.l	d3,d2			; buf
	move.b	#$0a,(a5)+		; add '\n'
	sub.l	d2,a5
	move.l	a5,d3			; len

	jsr	_LVOOutput(a6)		; identify initial output file handle

	move.l	d0,d1			; file
	jsr	_LVOWrite(a6)

	move.l	a6,a1			; library
	move.l	_AbsExecBase,a6		; get ExecBase
	jsr	_LVOCloseLibrary(a6)	; close dos.library

	moveq	#RETURN_OK,d0
	rts				; exit

return_fail_sp:
	move.l	d5,sp			; restore sp

return_fail:
	moveq	#RETURN_FAIL,d0
	rts				; exit

bin2dec:
	; u32 -> decimal []u8
	; input
	;   d4: u32
	;   a5: []u8 buf
	; output
	;   a5: []u8 buf
	; destroys
	;   d0, d1, d2, d4, a0
	moveq	#'0',d0
	lea	bin2dec_pow10(pc),a0
bin2dec_loop0:
	move.l	(a0)+,d1
	beq	bin2dec_fini
	moveq	#'0'-1,d2
bin2dec_loop1
	addq	#1,d2
	sub.l	d1,d4
	bcc	bin2dec_loop1
	add.l	d1,d4
	cmp.l	d0,d2
	beq	bin2dec_loop0
	moveq	#0,d0
	move.b	d2,(a5)+
	bra	bin2dec_loop0
bin2dec_fini:
	moveq	#'0',d0
	add.b	d0,d4
	move.b	d4,(a5)+
	rts
bin2dec_pow10:
	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	0

DosName
	dc.b	"dos.library",0

FileName
	; no need to null-terminate when next byte in binary will be 0 because
	; HUNK_RELOC32
	dc.b	"input"
