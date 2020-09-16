;;;;	main.asm
;;;;	Program main assembly file

include "gbhw.inc"	 
include "myboy.inc"     
include "ibmpc1.inc"	 

SECTION "ROM_ENTRY", ROM0[$0100]	
	nop
	jp	code

SECTION "ROM_HEADER", ROM0[$0104]
	NINTENDO_LOGO	; add nintendo logo. Required to run on real hardware
	ROM_HEADER	"DUNGEON SCROLLS"
        

SECTION "Main Code", ROM0
;; Declarations
        var_Def         jpad_keys, 1
	spr_Struct      copyright        
        
code:                           ;
	di			; Disable interrupts
	ld	SP, $FFFF	; Set stack to top of HRAM
	
	dma_CopyToHRAM		; Copy DMA Routine to HRAM
        
        call    lcd_Stop

        ;; Copy Tiles to VRAM
        ld      hl, ascii_tiles
        ld      de, _VRAM
        ld      bc, ascii_tiles_end - ascii_tiles
        call    mem_CopyMono

        ;; Clear Screen
        ld      a, $20
        ld      hl, _SCRN0
        ld      bc, SCRN_VX_B * SCRN_VY_B
        call    mem_SetVRAM

        ld      hl, text
        ld      de, _SCRN0 + (8 * SCRN_VX_B + 6)
        ld      bc, text_end - text
        call    mem_CopyVRAM
        
        call    lcd_On

        ;; Clear OAM Shadow
        ld      a, 0
        ld      hl, OAMSHADOWLOC
        ld      bc, 40*4
        call    mem_Set

        ;; Enable Objects
	ld	a, [rLCDC]	
	or	LCDCF_OBJON | LCDCF_OBJ8
	ld      [rLCDC], a
        
        ;; Write to OAM
        spr_Put copyright, XAddr, 8
	spr_Put	copyright, YAddr, 16
        spr_Put	copyright, Tile,  $40
	spr_Put	copyright, Flags, $00

        ;; Enable VBlank
	ld	a, IEF_VBLANK 
	ld 	[rIE], a
	ei
 
.mainloop
	halt
	nop

        ld      a,      [jpad_keys]
        or      0
        jr      nz, .skip_move
        
        call    jpad_GetKeys
        spr_MoveIfLeft  copyright, 8
        spr_MoveIfRight copyright, 8
        spr_MoveIfDown  copyright, 8
        spr_MoveIfUp    copyright, 8
        
.skip_move
        call    jpad_GetKeys
        ld      [jpad_keys], a  
       
        jr      .mainloop
        

SECTION "Data", ROM0

text:
        DB      "Hello World"
text_end:       
        
ascii_tiles:
        chr_IBMPC1      1, 8
ascii_tiles_end:
;-------------------- DATA -------------------------------------------------------
