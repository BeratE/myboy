;;;;	main.asm
;;;;	Program main assembly file

include "gbhw.inc"	 ; Gameboy hardware & addresses info
include "symbols.inc"	 ; Export common symbols
include "dma.inc"	 ; DMA Routine
include "sprite.inc"	 ; Sprite handling


SECTION "ROM_ENTRY", ROM0[$0100]	
	nop
	jp	code


SECTION "ROM_HEADER", ROM0[$0104]
	NINTENDO_LOGO	; add nintendo logo. Required to run on real hardware
	ROM_HEADER	"SCROLLS DUNGEON"

	
;-------------------- CODE -------------------------------------------------------
;; Declarations
	spr_Struct copyright
	
code:
	di			; Disable interrupts
	ld	SP, $FFFF	; Set stack to top of HRAM
	
	dma_CopyToHRAM		; Copy DMA Routine to HRAM

	;; Enable VBlank
	ld	a,  IEF_VBLANK 
	ld 	[rIE], a
	ei

	;; Enable Objects
	ld	a, [rLCDC]	
	or	LCDCF_OBJON	
	or	LCDCF_OBJ8	
	ld	[rLCDC], a


	spr_Put	copyright, XAddr, 20
	spr_Put	copyright, YAddr, 10
	spr_Put	copyright, Tile,  $19
	spr_Put	copyright, Flags, $00
	
.mainloop
	halt
	nop

	spr_MoveRight copyright, 1
	spr_MoveDown  copyright, 1


	jp	.mainloop
;-------------------- CODE -------------------------------------------------------
