BasicUpstart2(start)

Digit:
*=* "digits"    
	.byte $00,$00,$00,$00,$99,$99,$99,$99
_Digit:

.label Num_Digits = [_Digit - Digit]


start:
			ldx #7          // Index of digit to add to
			lda #$1  		// Amount to add
            jsr AddToScore
            jsr Display_Score

            rts

AddToScore:			
			sed
			clc			
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

Display_Score:
			ldy #[Num_Digits*2]-1
			ldx #Num_Digits-1
!Loop:			
			lda Digit,x
			pha 
			and #$0f
			clc
			adc #$30
			sta $400,y
			dey
			pla 
			and #$f0
			lsr
			lsr
			lsr
			lsr
			adc #$30
			sta $400,y
			dey
			dex 
			bpl !Loop-
			rts


