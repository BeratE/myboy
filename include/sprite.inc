;;;;	sprite.inc
;;;;	Define macros and structs for handling of OAM shadow data.

	IF      !DEF(SPRITE_INC)
SPRITE_INC  SET  1

		RSSET	OAMSHADOWLOC
_sprite_RS	SET 	OAMSHADOWLOC	; Keep track of RS

;; Define Sprite Struct
spr_Struct: MACRO
		RSSET	_sprite_RS
\1_LOC		EQU	_sprite_RS	; Start Location
\1_YAddr	RB	1		; Y Address
\1_XAddr	RB	1		; X Address
\1_Tile		RB	1		; Tile Number
\1_Flags	RB	1		; Flags
_sprite_RS	SET	_RS
	ENDM

;;;
;;; Setter and Getter

;; Set Sprite Attribute
;; \1 Spritename \2 Attribute \3 Value
spr_Put: MACRO
        ld  a, \3
	ld  [\1_\2], a
	ENDM

;; Get Sprite Attribute
;; \1 Spritename \2 Attribute
spr_Get: MACRO
	ld  a, [\1_\2]
	ENDM


;;;
;;; Misc 

; Move sprite to the left
;; /1 Spritename /2 X value
spr_MoveLeft: MACRO
	spr_Get \1, XAddr
	sub \2
	spr_Put \1, XAddr, a
	ENDM

; Move sprite to the right
;; /1 Spritename /2 X value
spr_MoveRight: MACRO
	spr_Get \1, XAddr
	add \2
	spr_Put \1, XAddr, a
	ENDM

; Move sprite to upwards
;; /1 Spritename /2 Y value
spr_MoveUp: MACRO
	spr_Get \1, YAddr
	sub \2
	spr_Put \1, YAddr, a
	ENDM

; Move sprite to upwards
;; /1 Spritename /2 Y value
spr_MoveDown: MACRO
	spr_Get \1, YAddr
	add \2
	spr_Put \1, YAddr, a
	ENDM

ENDC ; sprite.inc
