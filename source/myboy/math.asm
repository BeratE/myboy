;;; -------------------------------------------------------------------------------
;;; Math subroutines
;;; -------------------------------------------------------------------------------        
    IF      !DEF(MATH_ASM)
MATH_ASM SET     1

    INCLUDE "myboy/gbhw.inc"
    INCLUDE "myboy/math.inc"


;;; Variables
SECTION "Math Vars", WRAM0
_math_RandNum::  DS  1


        
SECTION "Math Code", ROM0
        
;;; *******************************************************************************
;;; 
;;; math_Mul8 - Multiplies two 8-bit numbers and stores the result in a 16-bit reg. 
;;; input:
;;;     D, E - 8-bit multipliers
;;; output:
;;;     HL   - 16-bit result of multiplication
;;; 
;;; *******************************************************************************                
math_Mul8::
    ld      hl, 0           ; result
    ld      b, 9            ; Maximum number of shift
    .shift1                         ; Shift E to right until first one is reached
        dec     b
        jr      z,  .end
        sla     e
        jr      nc, .shift1
        ld      l, d            ; Copy multiplier D to HL
    .shift2                         ; Shift E to right and HL to left
        dec     b
        jr      z, .end
        sla     h               ; Shift HL to left
        sla     l               
        ld      a, h            ; Add carry to H
        adc     a, 0
        ld      h, a
        sla     e               ; Shift E to right
        jr      nc, .shift2
        ld      a, l            ; Add D to L (if E shifted a one into carry)
        add     a, d
        ld      l, a
        ld      a, h            ; Add carry to H
        adc     a, 0
        ld      h, a
        jr      .shift2
    .end        
    ret     

        
;;; *******************************************************************************
;;; 
;;; math_Random8 - Generate a new random number using a linear congruent generater
;;;     of the form x[i+1] = (5*x[i] + 1) mod 256
;;; output:
;;;     A - 8 bit random value, period of 256
;;; 
;;; *******************************************************************************        
math_Random8::
    ld      a, [_math_RandNum]
    ld      b, a
    add     a, a
    add     a, a
    add     a, b
    inc     a
    ld      [_math_RandNum], a
    ret

        
    ENDC                    ; MATH_ASM
;;; -------------------------------------------------------------------------------        
