;;; -------------------------------------------------------------------------------
;;;
;;;     Sprite manipulation and OAM Data management
;;; 
;;; -------------------------------------------------------------------------------
    IF      !DEF(SPRITE_ASM)
SPRITE_ASM      SET     1

    INCLUDE "myboy/gbhw.inc"
    INCLUDE "myboy/sprite.inc"

;;; Reserve RAM for OAM Shadow
SECTION "OAM Shadow Data", WRAM0[OAM_SHADOW_LOC]
_sprite_shadowOAM::  DS 40*4
_spr_shadowOAMend::

    ENDC                    ; SPRITE_ASM
;;; -------------------------------------------------------------------------------
