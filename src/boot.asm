
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
	; set timer
	lda #$00
	sta timer_cnt
	lda #$01
	sta timer_ctrl

	; disable irq?
	;lda %00000111
	;sta $1402

	jsr vdc_init

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
	jsr sprites_clear
	
	;jsr psg_init

	;lda <#nmi
	;sta $0022
	;lda >#nmi
	;sta $0023

	;lda %00000111
	;sta $1402

	; enable interrupts
	cli




loop:
	jmp loop                    ;do our infinite wait loop



