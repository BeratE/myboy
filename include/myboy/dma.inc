;;; -------------------------------------------------------------------------------
;;; DMA Routine. 
;;; Copy DMA Code from ROM to HRAM
;;; -------------------------------------------------------------------------------     
	IF      !DEF(DMA_INC)
DMA_INC       SET     1

DMA_ROUTINE	EQU	_HRAM		  ; DMA Routine is copied to start of HRAM      
EXPORT DMA_ROUTINE  
        
dma_CopyToHRAM: MACRO
	jr	.copy_dma_into_memory\@

.dmacode\@	
	push	af
	ld	a, OAM_SHADOW_BANK
	ldh	[rDMA], a
	ld	a, $28 	; countdown until DMA is finished, then exit ($28 = 40)
.dma_wait\@			;<-|
	dec	a		;  |	keep looping until DMA finishes
	jr	nz, .dma_wait\@ ; _|
	pop	af
	reti	; if this were jumped to by the v-blank interrupt, we'd
		; want to        reti (re-enable interrupts).
.dmaend\@

.copy_dma_into_memory\@
	ld	de, DMA_ROUTINE			; Destination address
	ld	hl, .dmacode\@			; Source address
	ld	bc, .dmaend\@ - .dmacode\@	; Size in bytes
	call	mem_Copy
	        ENDM


    ENDC                    ; DMA_INC
;;; -------------------------------------------------------------------------------
