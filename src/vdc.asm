
bat_fill: 
	; currently clears 64x32
	; a = tile id
	sta temp
	lda #$00
	sta $0000
	sta $0002
	sta $0003
	lda #$02
	sta $0000
	ldx #$07
	ldy #$00
	lda temp
.loop
	sta $0002
	stz $0003
	iny
	bne .loop
	dex
	bpl .loop
	rts


chr_load:
	lda #$00
	sta $0000
	sta $0002
	lda #$10
	sta $0003
	lda #$02
	sta $0000
	; setup vram pointer
	st0 #0
	st1 #$00
	st2 #$10
	st0 #2
	; setup zp pointer
	lda #$40
	sta ptr_hi
	lda #$00
	sta ptr_lo
	; copy chr data
	ldx #$00
	ldy #$00
.chr_load_loop
	lda [ptr_lo],y
	sta $0002
	stx $0003
	iny
	bne .chr_load_loop
	inc ptr_hi
	lda ptr_hi
	cmp #$60
	beq .chr_load_done
	bne .chr_load_loop
.chr_load_done
	rts


sprites_clear:
	rts
