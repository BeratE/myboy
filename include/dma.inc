
	IF !DEF(DMA_INC)
	; don't re-include this file if it's already been INCLUDE'd
DMA_INC = 1

DMA_ROUTINE	= $FF80	; Internal (HI)RAM
OAMDATALOC	= _RAM ; set first 160 bytes of RAM to hold OAM variables
OAMDATALOCBANK	= OAMDATALOC / $100 ; used by DMA_ROUTINE to point to _RAM

; Export Symbols
EXPORT DMA_ROUTINE, OAMDATALOC, OAMDATALOCBANK

	
dma_Copy2HRAM: MACRO
	
; Copies the DMAcode to HIRAM. DMAcode will get run each Vblank,
; and it is resposible for copying sprite data from RAM to VRAM.

	jr	.copy_dma_into_memory\@
; -------------------- DMA CODE BEGIN --------------------------------------------	
.dmacode\@	
	push	af
	ld	a, OAMDATALOCBANK
	ldh	[rDMA], a
	ld	a, $28 	; countdown until DMA is finished, then exit
.dma_wait\@			;<-|
	dec	a		;  |	keep looping until DMA finishes
	jr	nz, .dma_wait\@ ; _|
	pop	af
	reti	; if this were jumped to by the v-blank interrupt, we'd
		; want to reti (re-enable interrupts).
.dmaend\@
; -------------------- DMA CODE END ----------------------------------------------
.copy_dma_into_memory\@
	ld	de, DMA_ROUTINE			; Destination address
	ld	hl, .dmacode\@			; Source address
	ld	bc, .dmaend\@ - .dmacode\@	; Size in bytes
	call	mem_Copy
	ENDM
	
	ENDC	; end definition of DMA.inc file
