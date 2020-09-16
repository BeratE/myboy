;;; *******************************************************************************
;;;
;;;     MYBOY - Library of useful macros and definitions
;;; 
;;; *******************************************************************************
	IF      !DEF(MYBOY_INC)
MYBOY_INC       SET     1

;;; -------------------------------------------------------------------------------
;;; DMA Routines, Compy to HRAM and sync.
;;; -------------------------------------------------------------------------------     

;;; DMA Symbols
DMA_ROUTINE	EQU	_HRAM		  ; DMA Routine is copied to start of HRAM        
        
dma_CopyToHRAM: MACRO
	jr	.copy_dma_into_memory\@

.dmacode\@	
	push	af
	ld	a, OAMSHADOWBANK
	ldh	[rDMA], a
	ld	a, $28 	; countdown until DMA is finished, then exit ($28 = 40)
.dma_wait\@			;<-|
	dec	a		;  |	keep looping until DMA finishes
	jr	nz, .dma_wait\@ ; _|
	pop	af
	reti	; if this were jumped to by the v-blank interrupt, we'd
		; want to        reti (re-enable interrupts).
.dmaend\@

.copy_dma_into_memory\@
	ld	de, DMA_ROUTINE			; Destination address
	ld	hl, .dmacode\@			; Source address
	ld	bc, .dmaend\@ - .dmacode\@	; Size in bytes
	call	mem_Copy
	        ENDM
	
;;; -------------------------------------------------------------------------------

        
                
;;; -------------------------------------------------------------------------------
;;; Variables, define labeled consecutive sections in RAM
;;; -------------------------------------------------------------------------------

VARLOC          EQU     _RAM + $00A0    ; Beginning of RAM + 160 bytes offset

_var_RS         SET     VARLOC
        
;;; Allocate a new Variable in RAM
;;; arguments:
;;;     \1 Label, \2 Number of bytes to allocate
var_Def:        MACRO
                RSSET   _var_RS
\1              RB      \2
_var_RS         SET     _RS
                ENDM

;;; -------------------------------------------------------------------------------


        
;;; -------------------------------------------------------------------------------
;;; Sprite. Define macros and structs for handling of OAM shadow data.
;;; -------------------------------------------------------------------------------
        
;;; Symbols
OAMSHADOWLOC	EQU	_RAM              ; Shadow starts at beginning of RAM
OAMSHADOWBANK	EQU	OAMSHADOWLOC/$100 ; Shadow bank, must be 256 bytes aligned
OAMSHADOWLENGTH	EQU	$A0               ; 160 bytes of OAM data
        
_sprite_RS	SET 	OAMSHADOWLOC	; Keep track of RS

        
;;; Define Sprite Struct
spr_Struct:     MACRO
		RSSET	_sprite_RS
\1_LOC	        EQU	_sprite_RS	; Start Location
\1_YAddr	RB	1		; Y Address
\1_XAddr	RB	1		; X Address
\1_Tile	        RB	1		; Tile Number
\1_Flags	RB	1		; Flags
_sprite_RS	SET	_RS
	        ENDM

        
;;; Set Sprite Attribute.
;;; arguments:
;;;     \1 Spritename, \2 Attribute, \3 Value
spr_Put:        MACRO
        ld      a, \3
	ld      [\1_\2], a
	        ENDM

        
;;; Get Sprite Attribute
;;; arguments:
;;;     \1 Spritename, \2 Attribute
spr_Get:        MACRO
	ld      a, [\1_\2]
	        ENDM

        
;;; Move sprite to the left
;;; arguments:
;;;     \1 Spritename, \2 value (default 1)
spr_MoveLeft:   MACRO
	spr_Get \1, XAddr
    IF (_NARG >= 2)
	sub     \2
    ELSE
        dec     a
    ENDC
	spr_Put \1, XAddr, a
	        ENDM

;;; Move sprite to the left if left key is pressed
;;; arguments:
;;;     \1 Spritename, \2 value (default 1)       
spr_MoveIfLeft: MACRO
        push    af
        and     PADF_LEFT
        jr      z, .skip_left\@
    IF (_NARG >= 2)
        spr_MoveLeft \1, \2
    ELSE
        spr_MoveLeft \1
    ENDC
.skip_left\@
        pop     af
                ENDM

;;; Move left if left is pressed but wasnt previously pressed
;;; arguments:
;;;     \1 Spritename, \2 value        
spr_MoveOnceIfLeft: MACRO
        push    af
        ld      a, [jpad_keys]
        and     PADF_LEFT
        jr      nz, .skip_once_left\@
        pop     af              
        push    af
        and     PADF_LEFT
        jr      z,  .skip_once_left\@
        spr_MoveLeft \1, \2
.skip_once_left\@
        pop     af
                ENDM
        
;;; Move sprite to the right
;;; arguments:
;;;     \1 Spritename, \2 value (default 1)
spr_MoveRight:  MACRO
	spr_Get \1, XAddr
    IF (_NARG >= 2)
	add     \2
    ELSE
        inc     a
    ENDC
	spr_Put \1, XAddr, a
	        ENDM
        
;;; Move sprite to right if right key is pressed
;;; arguments:
;;;     \1 Spritename, \2 value (default 1)
spr_MoveIfRight: MACRO
        push    af
        and     PADF_RIGHT
        jr      z, .skip_right\@
    IF (_NARG >= 2)
        spr_MoveRight \1, \2
    ELSE
        spr_MoveRight \1
    ENDC
.skip_right\@
        pop     af
                ENDM

;;; Move right if right is pressed but wasnt previously pressed
;;; arguments:
;;;     \1 Spritename, \2 value
spr_MoveOnceIfRight: MACRO
        push    af
        ld      a, [jpad_keys]
        and     PADF_RIGHT
        jr      nz, .skip_once_right\@
        pop     af              
        push    af
        and     PADF_RIGHT
        jr      z,  .skip_once_right\@
        spr_MoveRight \1, \2
.skip_once_right\@
        pop     af
                ENDM
        
;;; Move sprite upwards
;;; arguments:
;;;     \1 Spritename, \2 value (default 1)        
spr_MoveUp:     MACRO
	spr_Get \1, YAddr
    IF (_NARG >= 2)
	sub \2
    ELSE
        dec a
    ENDC
	spr_Put \1, YAddr, a
	        ENDM

;;; Move sprite updwards if up key is pressed
;;; arguments:
;;;     \1 Spritename, \2 value (default 1)        
spr_MoveIfUp:   MACRO
        push    af
        and     PADF_UP
        jr      z, .skip_up\@
    IF (_NARG >= 2)
        spr_MoveUp \1, \2
    ELSE
        spr_MoveUp \1
    ENDC
.skip_up\@
        pop     af
                ENDM

;;; Move up if up is pressed but wasnt previously pressed
;;; arguments:
;;;     \1 Spritename, \2 value        
spr_MoveOnceIfUp: MACRO
        push    af
        ld      a, [jpad_keys]
        and     PADF_UP
        jr      nz, .skip_once_up\@
        pop     af              
        push    af
        and     PADF_UP
        jr      z,  .skip_once_up\@
        spr_MoveUp \1, \2
.skip_once_up\@
        pop     af
                ENDM

;;; Move sprite downwards
;;; arguments:
;;;     \1 Spritename, \2 value (default 1)
spr_MoveDown:   MACRO
	spr_Get \1, YAddr
    IF (_NARG >= 2)
	add \2
    ELSE
        inc a
    ENDC
	spr_Put \1, YAddr, a
	        ENDM
        
;;; Move sprite downwards if down key is pressed
;;; arguments:
;;;     \1 Spritename, \2 value (default 1)        
spr_MoveIfDown: MACRO
        push    af
        and     PADF_DOWN
        jr      z, .skip_down\@
    IF (_NARG >= 2)
        spr_MoveDown \1, \2
    ELSE
        spr_MoveDown \1
    ENDC
.skip_down\@
        pop     af
                ENDM

;;; Move down if down is pressed but wasnt previously pressed
;;; arguments:
;;;     \1 Spritename, \2 value        
spr_MoveOnceIfDown: MACRO
        push    af
        ld      a, [jpad_keys]
        and     PADF_DOWN
        jr      nz, .skip_once_down\@
        pop     af              
        push    af
        and     PADF_DOWN
        jr      z,  .skip_once_down\@
        spr_MoveDown \1, \2
.skip_once_down\@
        pop     af
                ENDM


        
;;; -------------------------------------------------------------------------------
                
                ENDC  ; MYBOY_INC
;;; *******************************************************************************

