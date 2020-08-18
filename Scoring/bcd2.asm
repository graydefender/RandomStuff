BasicUpstart2(start)

.label Num_Digits = 8 
Digit:
*=* "digits"    
	.byte $00,$00,$00,$00,$95,$95,$95,$99
Reverse:
	.for (var i=[Num_Digits-1]; i>=0; i--) {
		.byte i
	}

start:
			ldy #00        //Index of digit to add
			ldx Reverse,y

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

