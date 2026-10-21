
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
	; set SAT address to $7f00
	lda #$13  ; SATB
	sta $0000
	lda #$00
	sta $0002
	lda #$7f
	sta $0003
	; clears VRAM $7f00 page
	lda #$00
	sta $0000
	sta $0002
	lda #$7f
	sta $0003
	lda #$02
	sta $0000
	lda #$00
	tax
.loop
	sta $0002
	sta $0003
	inx
	bne .loop
	rts


vdc_init:
	; needs better comments?
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

	rts
