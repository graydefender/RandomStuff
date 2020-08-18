BasicUpstart2(start)

Digit:
*=* "digits"    
	.byte $00,$00,$00,$00,$95,$95,$95,$99

start:
			ldx #7          // Index of digit to add to
			sed
			clc
			lda #$1  		// Amount to add
			adc Digit,x
			jmp !skip+
!Loop:
			lda Digit,x
			adc #$00
!skip:			
			sta Digit,x
			dex
			bpl !Loop-
			cld
			rts

