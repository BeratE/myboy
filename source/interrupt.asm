; Vertical-blank triggers each time the screen finishes drawing. Draw-To-Screen
; routines happen here because Video-RAM is only available during vblank*
SECTION "Vblank", ROM0[$0040]
	jp	DMA_ROUTINE

	
; LCDC interrupts are LCD-specific interrupts (not including vblank) such as
; interrupting when the gameboy draws a specific horizontal line on-screen
SECTION "LCDC", ROM0[$0048]
	reti

; Timer interrupt is triggered when the timer, rTIMA, ($FF05) overflows.
; rDIV, rTIMA, rTMA, rTAC all control the timer.
SECTION "Timer", ROM0[$0050]
	reti

; Serial interrupt occurs after the gameboy transfers a byte through the
; gameboy link cable.
SECTION "Serial", ROM0[$0058]
	reti

; Joypad interrupt occurs after a button has been pressed. Usually we don't
; enable this, and instead poll the joypad state each vblank
SECTION "Joypad", ROM0[$0060]
	reti
