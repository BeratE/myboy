;;; -------------------------------------------------------------------------------
;;; Joypad 
;;; -------------------------------------------------------------------------------        
        IF      !DEF(JPAD_ASM)
JPAD_ASM SET  1

        INCLUDE "gbhw.inc"
        INCLUDE "myboy.inc"
        
SECTION "Joypad Code", ROM0

;;; *******************************************************************************
;;; 
;;; jpad_GetKeys - Get currently pressed registers.
;;; output:
;;;     A, [jpad_keys] - Down, Up, Left, Right, Start, Select, B, A
;;;
;;; *******************************************************************************     
        
jpad_GetKeys::
	; get action buttons: A, B, Start / Select
	ld	a, JOYPAD_BUTTONS; choose bit that'll give us action button info
	ld	[rJOYPAD], a; write to joypad, telling it we'd like button info
	ld	a, [rJOYPAD]; gameboy will write (back in address) joypad info
	ld	a, [rJOYPAD]
	cpl		; take compliment
	and	$0f	; look at first 4 bits only  (lower nibble)
	swap	a	; place lower nibble into upper nibble
	ld	b, a	; store keys in b
	; get directional keys
	ld	a, JOYPAD_ARROWS
	ld	[rJOYPAD], a ; write to joypad, selecting direction keys
	ld	a, [rJOYPAD]
	ld	a, [rJOYPAD]
	ld	a, [rJOYPAD]	; delay to reliablly read keys
	ld	a, [rJOYPAD]	; since we've just swapped from reading
	ld	a, [rJOYPAD]	; buttons to arrow keys
	ld	a, [rJOYPAD]
	cpl			; take compliment
	and	$0f		; keep lower nibble
	or	b		; combine action & direction keys (result in a)
        ld      b, a
	ld	a, JOYPAD_BUTTONS | JOYPAD_ARROWS
	ld	[rJOYPAD], a	; reset joypad
	ld	a, b	        ; register A holds result. Each bit represents a key
	ret
       


        ENDC ; JPAD_ASM
;;; -------------------------------------------------------------------------------             
