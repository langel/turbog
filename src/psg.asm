

psg_init:
	lda #$ff  ; global volume full
	sta $0801

; SQAURE WAVE channel 0 (wavetable)
	lda #$00  ; select channel 0
	sta $0800
	lda #$4e  ; fine tune
	sta $0802
	sta fine_tune
	lda #$05  ; coarse tune
	sta $0803
	lda #$40  ; reset wavetable position
	sta $0804
	lda #$00  ; turn off to enable wave write
	sta $0804
	ldy #$00  ; write wave table loop
.loading_square:
	lda square,y
	sta $0806
	iny
	cpy #$20
	bne .loading_square
	lda #$ff  ; set L/R volume full
	sta $0805 
	lda #$9f  ; enable channel and full volume
	sta $0804
; TURN OFF channel 0
; so we can hear channel 5
	lda #$00
	sta $0804

; SNARE counters
	stz snare_counter
	stz snare_page
	stz snare_lo
	lda #$60
	sta snare_hi
; SNARE WAVE channel 5 (pcm / DDA)
	lda #$05
	sta $0800 ; set channel
	lda #$40
	sta $0804 ; set ch off and dda on
	lda #$00
	sta $0804 ; disable sound
	sta $0806
	lda #$ff ; set Channel and DDA to on / Volume full
	sta $0804
	sta $0805 ; set L/R volume full 

	lda #$03
	sta $0800
	lda #$40
	sta $0804
	lda #$00
	sta $0804
	sta $0806
	lda #$ff  ; set L/R volume full
	sta $0805 
	lda #$df ; set Channel and DDA to on / Volume full
	sta $0804

	lda #$04
	sta $0800
	lda #$40
	sta $0804
	lda #$00
	sta $0804
	sta $0806
	lda #$ff  ; set L/R volume full
	sta $0805 
	lda #$df ; set Channel and DDA to on / Volume full
	sta $0804


	rts



; XXX DEFINITELY NEED REFACTORS HERE

irq1:
	rti
	pha
	phx
	phy
	; READ THE STATUS REGISTER TO
	; RESET THE VDC IRQ FLAG
	lda $0000
	; increment fine tune
	lda #$00 ; use channel 0
	sta $0800
	inc fine_tune
	lda fine_tune
	sta $0802
	; check loop counter position
	inc $2020
	lda $2020
	cmp #$08
	bne .cleanup
	; rotate bg color
	lda #$00
	sta $0402
	sta $0403
	inc $2021
	lda $2021
	sta $0404
	; reset loop
	lda #$00
	sta $2020
.cleanup:
	ply
	plx
	pla
	rti


timer_snare:
	rti
	pha
	phx
	phy
	stz $1403 ; reset timer
	; load next sample
	lda [snare_lo]
	tax

	lda #$05 ; use channel 5
	sta $0800
	txa
	sta $0806 ; stash into DDA
	; do it on channel 4
	lda #$04
	sta $0800
	txa
	sta $0806
	; do it on channel 3
	lda #$03
	sta $0800
	txa
	sta $0806
	; increment sample counter
	inc snare_lo
	bne .skip_hi_ops
	inc snare_hi
	lda snare_hi
	cmp #$a0
	bne .skip_hi_ops
	lda #$40
	sta snare_hi
.skip_hi_ops:

	lda #$01
	sta timer_ctrl ; reset timer?
	ply
	plx
	pla
	rti


square:
	.db $1b,$1d,$1e,$1e,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1f,$1e,$1e,$1d,$1b,$04,$02,$01
	.db $01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$02,$04

