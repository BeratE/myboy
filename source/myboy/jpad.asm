;;; -------------------------------------------------------------------------------
;;; Joypad 
;;; -------------------------------------------------------------------------------        
    IF      !DEF(JPAD_ASM)
JPAD_ASM SET  1

    INCLUDE "myboy/gbhw.inc"


;;; Variables
SECTION "Joypad Vars", WRAM0
_jpad_Data::      DS  1
_jpad_DataEdge::  DS  1


        
SECTION "Joypad Code", ROM0

;;; *******************************************************************************
;;; 
;;; jpad_GetKeys - Get currently pressed registers.
;;; output:
;;;     A, [_jpad_Data]     - JPad Matrix: Down, Up, Left, Right, Start, Select, B, A
;;;     B, [_jpad_DataEdge] - Previous byte of keys  
;;;
;;; *******************************************************************************            
jpad_GetKeys::
    ld	a, JOYPAD_BUTTONS  ; get action buttons
    ld	[rJOYPAD], a; write to joypad, telling it we'd like button info
    ld	a, [rJOYPAD]; gameboy will write (back in address) joypad info
    ld	a, [rJOYPAD]
    cpl
    and	$0f
    swap a
    ld	b, a

    ld	a, JOYPAD_ARROWS     ; get directional keys
    ld	[rJOYPAD], a ; write to joypad, selecting direction keys
    ld	a, [rJOYPAD]
    ld	a, [rJOYPAD]
    ld	a, [rJOYPAD]	; delay to reliablly read keys
    ld	a, [rJOYPAD]	; since we've just swapped from reading
    ld	a, [rJOYPAD]	; buttons to arrow keys
    ld	a, [rJOYPAD]
    cpl
    and	$0f
    or	b		; combine action & direction keys (result in a)
    ld  b, a

    ld  a, [_jpad_Data]
    xor a, b
    and a, b
    ld  [_jpad_DataEdge], a
    ld  a, b
    ld [_jpad_Data], a
    push af

    ld	a, JOYPAD_BUTTONS | JOYPAD_ARROWS
    ld	[rJOYPAD], a    ; reset joypad

    ld  a, [_jpad_DataEdge]
    ld  b, a
    pop af
    ret
       

    ENDC        ; JPAD_ASM
;;; -------------------------------------------------------------------------------             
