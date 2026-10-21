

nmi:

	; lets update sprite positions
	ldy #$00
.move_loop
	sty temp
	; x pos
	tya
	clc
	adc $2200,y
	sta $2201,y ; x pos lo 
	lda $2300,y
	adc #$00
	sta $2301,y ; x pos hi
	; y pos
	tya
	eor #$ff
	clc
	adc $2200,y
	sta $2200,y ; y pos lo
	lda $2300,y
	adc #$00
	sta $2300,y ; y pos hi
	iny
	iny
	iny
	iny
	bne .move_loop
	; copy them to vram
	lda #$00
	sta $0000
	sta $0002
	lda #$7f
	sta $0003
	lda #$02
	sta $0000
.copy_loop
	lda $2200,y
	sta $0002
	lda $2300,y
	sta $0003
	iny
	bne .copy_loop
	rti
