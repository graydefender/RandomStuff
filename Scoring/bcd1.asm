BasicUpstart2(start)
 

//     Bit No.       7   6   5   4   3   2   1   0
//                   S   V       B   D   I   Z   C


Digit:
*=* "digits"    
	.byte $00,$00,$00,$00,$95,$95,$95,$99

start:
			sec
			lda #7
			sbc #$00       // Index from the right
			tax

			sed
			clc
			lda #$1  		// Amount to add
			adc Digit,x
			sta Digit,x
			dex
!Loop:
			lda Digit,x
			adc #$00
			sta Digit,x
			dex
			bpl !Loop-
			cld
			rts

