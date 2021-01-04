;;; -------------------------------------------------------------------------------
;;; 
;;; Macros for sprite definitions and manipulation
;;; 
;;; -------------------------------------------------------------------------------        
    IF      !DEF(SPRITE_INC)
SPRITE_INC       SET     1
        
OAM_SHADOW_LOC  EQU     _RAM
OAM_SHADOW_BANK EQU     OAM_SHADOW_LOC/$100
__SPRITE_RS     SET     OAM_SHADOW_LOC        


;;; Define Sprite Struct
spr_Def:        MACRO
                RSSET	__SPRITE_RS
\1_LOC	        EQU	__SPRITE_RS	; Start Location
\1_YAddr	RB	1		; Y Address
\1_XAddr	RB	1		; X Address
\1_Tile	        RB	1		; Tile Number
\1_Flags	RB	1		; Flags
__SPRITE_RS	SET	_RS
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


    ENDC  ; SPRITE_INC
;;; -------------------------------------------------------------------------------
