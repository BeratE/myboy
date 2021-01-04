;;; -------------------------------------------------------------------------------
;;; Map
;;; -------------------------------------------------------------------------------
    IF      !DEF(MAP_ASM)
MAP_ASM SET  1        

    INCLUDE "myboy/gbhw.inc"
    INCLUDE "myboy/math.inc"
    INCLUDE "myboy/debug.inc"
    
        
MAP_WIDTH       SET     32      ; Total map width in bytes
MAP_HEIGHT      SET     32      ; Total map height in bytes
BSP_MAX_DEPTH   SET     3       ; Maximum depth of bsp tree (root at zero)
BSP_NUM_NODES   SET     7       ; 2^MAX_BSP_DEPTH - 1
BSP_NODE_SIZE   SET     4       ; Each node has 4 bytes
BSP_SIZE_BYTES  SET     BSP_NUM_NODES*BSP_NODE_SIZE


TILE_EMPTY      SET     $20
TILE_WALL       SET     $23        


cleanMap:       MACRO
    ld  a, TILE_EMPTY
    ld  hl, map_data
    ld  bc, MAP_WIDTH*MAP_HEIGHT
    call mem_Set
    ENDM

copyMap:        MACRO
    ld  hl, map_data
    ld  de, _SCRN0
    ld  bc, MAP_WIDTH*MAP_HEIGHT
    call mem_CopyVRAM
    ENDM
        

        
SECTION "Map Data", WRAM0
map_data:       
    DS  MAP_WIDTH*MAP_HEIGHT

SECTION UNION "Temp Data", WRAM0
;;; BSP Tree implemented in array format
;;; Childindex = 2*Parentindex + [If (LeftChild) 1 Else (RightChild) 2]
;;; Node : [Absolute Y 1 byte | Absolute X 1 byte | Height 1 byte | Width 1 byte]
map_bsp:
    DS  BSP_SIZE_BYTES

      
        
SECTION "Map Code", ROM0

;;; *******************************************************************************
;;; 
;;; map_GenMap - Procedual map generation. Save result in map_data and copy
;;;     map data to background map in VRAM.
;;; 
;;; *******************************************************************************        
map_GenMap::
    cleanMap
    call    genBSP
    call    fillMapBSP
    copyMap
    ret

;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;; 
;;; genBSP - Recursively Generate the BSP Tree for Map Generation
;;;     Reg B = Index   
;;;     Reg C = %CSDDDDDD,
;;;     C = 0- left child,       1-right child,
;;;     S = 0- horizontal split, 1-vertical split        
;;;     DDDDDD = Depth
;;; Note: Recursive generation can only manage up to 64 indices    
;;; 
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
genBSP:
    ;; Clear BSP
    ld      a, 0
    ld      hl, map_bsp        
    ld      bc, BSP_SIZE_BYTES
    call    mem_Set
    ;; Fill Root Node
    ld      hl, map_bsp
    inc     hl
    inc     hl
    ld      a, MAP_HEIGHT
    ld      [hl+], a
    ld      a, MAP_WIDTH
    ld      [hl], a
    ;; Child Nodes
    ld      bc, 1
    ld      hl, map_bsp
    call    genBSPChild     ; Generate left side of BSP tree
    set     7, c
    call    genBSPChild     ; Generate right side of BSP tree
    ret
        
genBSPChild:
    ;; Save parent context
    push    hl
    push    bc
    ;; Check if max depth is reached
    ld      a, c
    and     a, %00111111        
    cp      a, BSP_MAX_DEPTH
    jr      z, .endChild
    ;; Childindex = 2*Parentindex + 1(left)/2(right)
    sla     b
    inc     b
    bit     7, c
    jr      z, .skipIndexIncrement
        inc     b
    .skipIndexIncrement
    ;; Get Child Address
    ld      de, map_bsp     
    ld      a, b
    sla     a
    sla     a
    math_AddAToR16 D, E
    push    de              ; Save child address
    ;; Copy Parent to Child
    push    bc
    ld      bc, 4
    call    mem_Copy
    pop     bc
    ;; Modify Child
    pop     hl              ; new parent address
    push    hl
    bit     7, c
    jr      nz, .modifyIfRightChild        
    .modifyIfLeftChild
        inc     hl
        inc     hl
        bit     6, c
        jr      z, .leftChildHorizontalSplit
        .leftChildVerticalSplit        
                inc     hl              ; Half Width
        .leftChildHorizontalSplit        
                sra     [hl]            ; Half Height
        jr      .endModifyIfChild
    .modifyIfRightChild
        bit     6, c
        jr      z, .rightChildHorizontalSplit
        .rightChildVerticalSplit
                inc     hl
        .rightChildHorizontalSplit
                inc     hl
                inc     hl
                sra     [hl]
                ld      a, [hl]
                dec     hl
                dec     hl
                add     a, [hl]
                ld      [hl], a
    .endModifyIfChild        
    pop     hl
    ;; Goto Child Nodes
    ld      a, c
    xor     a, %01000000    ; Switch split direction
    and     a, %01111111    ; left child
    ld      c, a
    inc     c               ; Increase depth
    ;; Left Child
    call    genBSPChild
    ld      a, c
    or      a, %10000000
    ld      c, a
    ;; Right Child
    call    genBSPChild
    .endChild
    ;; Retrieve parent context
    pop     bc
    pop     hl
    ret

;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;;;     
;;; fillMapBsp - Use BSP Data to fill the Map.
;;; 
;;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
fillMapBSP:    
    ld      bc, $0101           ; B holds current index, C holds current depth
    call    fillMapBSPNode
    ld      b, 2
    call    fillMapBSPNode
    ret

    ;; Descend towards child nodes
fillMapBSPNode:
    ;; Save parent context
    push hl
    push bc
    ;; Check if max bsp depth is reached
    ld  a, c
    cp  a, BSP_MAX_DEPTH
    jr  z, .parentIsChildNode
    ;; Get Address of current node from index
    ld      hl, map_bsp     
    ld      a, b
    sla     a
    sla     a
    math_AddAToR16 H, L
    ;; Check if Height or Width of current node is zero
    ;; THhis means, that the node is invalid. Therefore parent is a child node.
    inc hl
    inc hl
    ld  a, [hl]
    or  a
    jr  z, .parentIsChildNode
    inc hl
    ld  a, [hl]
    or  a
    jr  z, .parentIsChildNode
    dec hl
    dec hl
    dec hl
    ;; Descend to child nodes
    inc c
    sla b
    inc b
    call fillMapBSPNode         ; goto left child
    bit 0, d
    jr  nz, .isChildNode
    inc b                       
    call fillMapBSPNode         ; goto right child
    dec b       
    bit 0, d
    jr  z, .end
    ;; Current Node is a Child Node
    .isChildNode
        dec b                       ; Retrieve original Index
        sra b
        ;; 
        ;; ld      d, MAP_WIDTH
        ;; ld      a, [hl+]            ; Y 
        ;; ld      e, a
        ;; ld      a, [hl+]            ; X
        ;; push    bc
        ;; push    af
        ;; call    math_Mul8           ; Offset = Y*Map_Width+X
        ;; pop     af
        ;; math_AddAToR16 H,L
        ;; pop     bc        
        ;; ld      de, map_data
        ;; add     hl, de
        ;; ld      [hl], TILE_WALL    
    
        res 0, d
        jr  .end
    .parentIsChildNode
        set 0, d                ; Set Bit 0 of Reg D. Parent Node is a Child Node.
    .end
    ;; Restore parent context
    pop bc
    pop hl
    ret
        
        
    ENDC                    ; MAP_INC
;;; -------------------------------------------------------------------------------
