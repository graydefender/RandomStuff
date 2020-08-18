BasicUpstart2(start)

Digit:
*=* "digits"    
	.byte $00,$00,$00,$00,$07,$55,$00,$00
_Digit:

.label Num_Digits = [_Digit - Digit]


start:
			ldx #5          // Index of digit to add to
			lda #$56 		// Amount to add
            jsr SubFromScore
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
	// .byte $00,$00,$00,$00,$05,$00,$00,$00			
SubFromScore:			
		    sta Subvalue
			sed
			sec			
			lda Digit,x			
			sbc Subvalue: #$FF
			jmp !skip+
!Loop:
			lda Digit,x
			sbc #$00
!skip:	    sta Digit,x
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


