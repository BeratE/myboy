;;; -------------------------------------------------------------------------------
;;; Player Code
;;; -------------------------------------------------------------------------------
    IF      !DEF(PLAYER_ASM)
PLAYER_ASM      SET     1

    INCLUDE "myboy/gbhw.inc"
    INCLUDE "myboy/sprite.inc"
    

SECTION "Player Data", WRAM0        
player_prev_keys:
    DS  1

    spr_Def     player_spr              
        
        
SECTION "Player Code", ROM0

player_init::
    spr_Put     player_spr, XAddr, 8
    spr_Put	player_spr, YAddr, 16
    spr_Put	player_spr, Tile,  $40
    spr_Put	player_spr, Flags, $00
    ret

player_move::
    ld      a, [player_prev_keys]
    or      0
    jr      nz, .skip_move        
        call    jpad_GetKeys
        spr_MoveIfLeft  player_spr, 8
        spr_MoveIfRight player_spr, 8
        spr_MoveIfDown  player_spr, 8
        spr_MoveIfUp    player_spr, 8        
    .skip_move
    call    jpad_GetKeys
    ld      [player_prev_keys], a
    ret

    
    ENDC                    ; PLAYER_ASM
;;; -------------------------------------------------------------------------------        
