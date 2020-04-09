;;;; dma.inc
;;;; DMA copy to hram and sync

	IF !DEF(DMA_INC)
DMA_INC = 1

	
dma_CopyToHRAM: MACRO
	jr	.copy_dma_into_memory\@
; -------------------- DMA CODE BEGIN --------------------------------------------	
.dmacode\@	
	push	af
	ld	a, OAMSHADOWBANK
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
	
	ENDC	; DMA_INC
