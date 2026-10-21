
timerport    .equ $0C00
timer_cnt    .equ timerport
timer_ctrl   .equ timerport+1        

	.zp
ptr_lo: .ds 1
ptr_hi: .ds 1
snare_counter: .ds 1
snare_page: .ds 1
snare_lo: .ds 1
snare_hi: .ds 1
	.org $010
fine_tune: .ds 1
temp .ds 1

	.bss
 	.org $2680
vsync_cnt:	.ds 1	; counter for 'wait_vsync' routine 
    
	.code

	.bank $00
	.org $e000
	.include "src/boot.asm"
	.include "src/nmi.asm"
	.include "src/vdc.asm"
	; VECTORS
	.org $fff6
	; irq2
	.dw interrupt_rti
	; irq1
	.dw irq1
	; timer
	.dw timer_snare
	; nmi
	.dw nmi
	; reset
	.org $fffe     
	.dw start_up
      
	.bank $01
	.incbin "guntner.chr"
