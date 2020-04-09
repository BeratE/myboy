;;;; symbols.inc
;;;; Common and shared symbol definitions

       IF !DEF(SYMBOLS_INC)
SYMBOLS_INC = 1


;;; OAM 
OAMSHADOWLOC	EQU	_RAM		  ; Shadow starts of beginning of RAM
OAMSHADOWBANK	EQU	OAMSHADOWLOC/$100 ; Shadow bank, must be 256 bytes aligned
OAMSHADOWLENGTH	EQU	$A0               ; 160 bytes of OAM data

;;; DMA 
DMA_ROUTINE	=	$FF80		; Internal (HI)RAM

; Export Symbols
EXPORT OAMSHADOWLOC, OAMSHADOWBANK, OAMDATALENGTH
EXPORT DMA_ROUTINE


       ENDC	; SYMBOLS_INC

