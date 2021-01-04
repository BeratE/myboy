;;;;	main.asm
;;;;	Program main assembly file

    INCLUDE "myboy/gbhw.inc"
    INCLUDE "myboy/sprite.inc"     
    INCLUDE "myboy/ibmpc1.inc"
    INCLUDE "myboy/debug.inc"
    INCLUDE "myboy/dma.inc"

SECTION "ROM_ENTRY", ROM0[$0100]	
    nop
    jp	init

SECTION "ROM_HEADER", ROM0[$0104]
    NINTENDO_LOGO	; add nintendo logo. Required to run on real hardware
    ROM_HEADER	"DUNGEON SCROLLS"
        


EMPTY_TILE      SET     $20        

        
SECTION "Main Code", ROM0
init:                          
    di			; Disable interrupts
    ld	SP, $E000	; Set stack to top of RAM
	
    dma_CopyToHRAM      ; Copy DMA Routine to HRAM
    
    call lcd_Off
    
    ;; Copy Tiles to VRAM
    ld      hl, ascii_tiles
    ld      de, _VRAM
    ld      bc, ascii_tiles_end - ascii_tiles
    call    mem_CopyMono

    ;; Clear Screen
    ld      a, EMPTY_TILE
    ld      hl, _SCRN0
    ld      bc, SCRN_VX_B * SCRN_VY_B
    call    mem_SetVRAM

    ld      hl, text1
    ld      de, _SCRN0 + (6 * SCRN_VX_B) + 2
    ld      bc, text2 - text1
    call    mem_CopyVRAM
    ld      hl, text2
    ld      de, _SCRN0 + (7 * SCRN_VX_B) + 4
    ld      bc, text3 - text2
    call    mem_CopyVRAM
    ld      hl, text3
    ld      de, _SCRN0 + (9 * SCRN_VX_B) + 8
    ld      bc, text_end - text3
    call    mem_CopyVRAM
        
    call    lcd_On

    ;; Clear OAM Shadow
    ld      a, 0
    ld      hl, OAM_SHADOW_LOC
    ld      bc, 40*4
    call    mem_Set

    ;; Enable Objects and Window
    ld	a, [rLCDC]
    or	LCDCF_OBJON | LCDCF_OBJ8
    ld      [rLCDC], a

    call    player_init

    ;; Set palette
    ld      a, %11100100
    ld      [rBGP], a
    ld      [rOBP0],a
    ld      [rOBP1],a

    ;; call    map_GenMap      
        
    ;; Enable VBlank
    ld	a, IEF_VBLANK 
    ld 	[rIE], a
    ei
        
mainloop:       
    halt
    nop

    ;; ld      a, [rSCX]
    ;; inc     a
    ;; ld      [rSCX], a
    
    call    player_move
       
    jr      mainloop

        
        
SECTION "Data", ROM0

text1:
    DB  "Christina ist"
text2:  
    DB  "die beste!"
text3:
    DB  "( ^w^)"
text_end:       
        
ascii_tiles:
    chr_IBMPC1  1, 8
ascii_tiles_end:
;-------------------- DATA -------------------------------------------------------
