include "gbhw.inc"	 ; wealth of gameboy hardware & addresses info
include "dma.inc"

SECTION "ROM_entry_point", ROM0[$0100]	
	nop
	jp	code_begins


SECTION "rom header", ROM0[$0104]
	NINTENDO_LOGO	; add nintendo logo. Required to run on real hardware
	ROM_HEADER	"SCROLLS DUNGEON"

;-------------------- CODE -------------------------------------------------------
code_begins:
	di	; disable interrupts
	ld	SP, $FFFF	; set stack to top of HRAM
	
	dma_Copy2HRAM

	ld	a,  IEF_VBLANK ; enable vblank
	ld 	[rIE], a
	ei

	ld	a, [rLCDC]	; fetch LCD Config. (Each bit is a flag)	
	or	LCDCF_OBJON	; enable sprites through "OBJects ON" flag
	or	LCDCF_OBJ8	; enable 8bit wide sprites (vs. 16-bit wide)
	ld	[rLCDC], a	; save LCD Config. Sprites are now visible. 

	ld	hl, _RAM	; point to 1st sprite's 1st property: X
	ld	[hl], 20	; set X to 20
	inc	hl		; HL points to sprite's Y
	ld	[hl], 10	; set Y to 10
	inc	hl		; HL points to sprite's tile (from BG map)
	ld	[hl], $19	; set Tile to the (R) graphic
	inc	hl		; HL points to sprite's flags
	ld	[hl], 0		; set all flags to 0. X,Y-flip, palette, etc.

.loop
	halt
	nop

	ld	hl, _RAM	; HL points to X coordinate
	ld	a, [hl]
	inc	a		; X += 1
	ld	[hl], a		; save new X coordinates
	inc	hl		; HL points to Y coordinate
	inc	[hl]		; set Y += 1

	jp	.loop
