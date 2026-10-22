
start_up:
	; disable interrupts
	sei      
	; select the 7.16 MHz clock
	csh
	; clear decimal flag
	cld
	; initialize SP to $ff
	ldx #$ff
	txs

	; MPR0 $0000 - $1fff
	; Hardware Access
	lda #$ff 
	tam #$00
	; MPR1 $2000 - $3fff
	; 8kb of RAM
	lda #$f8     
	tam #$01
	; MPR2 $4000 - $5fff 
	; CHR ROM
	lda #$01
	tam #$02
	; MPR7 $e000 - $ffff
	; PRG ROM w/ Vectors
	lda #$00
	tam #$07

	; clear all of RAM
	stz $2000
	tii $2000, $2001, $1fff

	; reset timer?
	stz timer_ctrl
	; keep timer configured but disabled for now
	lda #$00
	sta timer_cnt
	stz timer_ctrl

	; disable irq?
	;lda %00000111
	;sta $1402

	jsr vdc_init

	; enable background and sprites
	lda #$05   ; select the control register
	sta $0000
	lda #$c8   ; BG+SPR + VBlank IRQ only (Raster IRQ disabled)
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

	; SPRITES
	jsr sprites_clear
	ldx #$00
	ldy #$00
.sprite_priority
	txa
	lsr a
	lsr a
	lsr a
	lsr a
	ora #$80
	sta $2203,x
	txa
	sta $2200,x
	; pattern code
	lda #$01
	sta $2302,x
	txa
	lsr a
	lsr a
	lsr a
	lsr a
	sta $2202,x
	inx
	inx
	inx
	inx
	bne .sprite_priority
	
	;jsr psg_init

	;lda <#nmi
	;sta $0022
	;lda >#nmi
	;sta $0023

	; enable only IRQ1 (VDC), keep IRQ2 and TIMER masked
	lda #$05
	sta $1402
	; clear any pending VDC IRQ before enabling CPU interrupts
	lda $0000

	; enable interrupts
	cli




loop:
	jmp loop                    ;do our infinite wait loop



