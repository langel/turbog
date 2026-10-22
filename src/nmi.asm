
irq_status  .equ $1403

IRQ2_PENDING  .equ $01
IRQ1_PENDING  .equ $02
TIMER_PENDING .equ $04

VDC_RASTER_FLAG .equ $20

nmi_handler:
	rti

irq2_handler:
	rti

irq_dispatch:
	pha
	phx
	phy

	lda irq_status
	and #IRQ1_PENDING
	beq .check_timer
	jsr irq1_handler

.check_timer:
	lda irq_status
	and #TIMER_PENDING
	beq .check_irq2
	jsr timer_irq_handler

.check_irq2:
	lda irq_status
	and #IRQ2_PENDING
	beq .done
	jsr irq2_stub_handler

.done:
	ply
	plx
	pla
	rti

irq1_handler:
	; Reading VDC status both acknowledges IRQ1 and tells us the source.
	lda $0000
	and #VDC_RASTER_FLAG
	beq .done
	jsr frame_hblank
.done:
	rts

timer_irq_handler:
	; Timer IRQs are acknowledged by writing any value to $1403.
	stz irq_status
	rts

irq2_stub_handler:
	rts

frame_hblank:
	; copy them to vram
	ldy #$00
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
	; lets update sprite positions
	ldy #$00
.move_loop
	sty temp
	; x pos
	tya
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	adc $2200,y
	sta $2201,y ; x pos lo
	lda $2300,y
	adc #$00
	sta $2301,y ; x pos hi
	; y pos
	tya
	eor #$ff
	lsr a
	lsr a
	lsr a
	lsr a
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
	rts
