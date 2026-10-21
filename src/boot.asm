
start_up:
	; disable interrupts
	sei      
	; select the 7.16 MHz clock
	csh
	; clear decimal flag
	cld
	; initialize SP to $ff
	lda #$ff
	txs
	; map hardware bank to MPR0
	; $0000 - $1fff
	lda #$ff 
	tam #$00
	; map ram bank to MPR1
	; $2000 - $3fff
	lda #$f8     
	tam #$01

	; map rom banks to memory map
	; $4000 - $5fff chr rom
	lda #$01
	tam #$02
	; $e000 - $ffff prg rom
	lda #$00
	tam #$07
	;lda #$02
	;tam #$03
	;lda #$03
	;tam #$04

	; clear all of RAM
	; set 1st byte of ram to desired default value
	stz $2000
	; propogate 1st byte value to all of ram
	tii $2000, $2001, $1fff

	; reset timer?
	stz timer_ctrl
	; set timer
	lda #$00
	sta timer_cnt
	lda #$01
	sta timer_ctrl

	; init VDC
	lda #$05  ; CR
	sta $0000
	lda #$00
	sta $0002
	sta $0003
	lda #$06  ; RCR
	sta $0000
	lda #$00
	sta $0002
	sta $0003
	lda #$07  ; BXR
	sta $0000
	lda #$00
	sta $0002
	sta $0003
	lda #$08  ; BYR
	sta $0000
	lda #$00
	sta $0002
	sta $0003
	lda #$09  ; MWR
	sta $0000
	lda #$00  ; bits 4-6 set bg virtual size
	sta $0002
	lda #$00
	sta $0003
	lda #$0a  ; HSR
	sta $0000
	lda #$02
	sta $0002
	lda #$02
	sta $0003
	lda #$0b  ; HDR
	sta $0000
	lda #$1f
	sta $0002
	lda #$04
	sta $0003
	lda #$0c  ; VPR (video sync register)
	sta $0000
	lda #$02
	sta $0002
	lda #$10
	sta $0003
	lda #$0d  ; VDW
	sta $0000
	lda #$e7
	sta $0002
	lda #$00
	sta $0003
	lda #$0e  ; VCR
	sta $0000
	lda #$0c
	sta $0002
	lda #$00
	sta $0003
	lda #$0f  ; DCR
	sta $0000
	lda #$10
	sta $0002
	lda #$00
	sta $0003
	lda #$13  ; SATB
	sta $0000
	lda #$00
	sta $0002
	lda #$7f
	sta $0003



	; enable background and sprites
	lda #$05   ; select the control register
	sta $0000
	lda #$cc   ; enable bits 3, 4, 6 and 7
	sta $0002
	lda #$00
	sta $0003

	; setup hblank interrupt at scanline 4
	lda #$06   ; select the RCR register
	sta $0000
	; first scanline is #$40 or #64
	lda #$80
	sta $0002  ; write lo byte
	lda #$00
	sta $0003  ; write hi byte


	; fill palette data
	ldy #$00
	lda #$00
	sta $0402
	sta $0403
.palfill:
	tya
	sta $0404
	lda #$00
	sta $0405
	iny
	bne .palfill
.palfill2:
	tya
	sta $0404
	lda #$01
	sta $0405
	iny
	bne .palfill2


	lda #$ff
	jsr bat_fill
	jsr chr_load
	


	; enable interrupts
	cli



; INIT PSG
init_psg:
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


loop:
	jmp loop                    ;do our infinite wait loop



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

interrupt_rti:
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

