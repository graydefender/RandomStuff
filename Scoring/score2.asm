BasicUpstart2(start)
.label Screen = $400

Digit:
*=* "digits"    
	.byte $30,$30,$30,$30,$30,$35,$39,$39
_Digit:

.label Num_Digits = [_Digit - Digit]

start:
			ldx #[Num_Digits-1]
!Loop:		lda Digit,x
 			sta Screen,x
 			dex
 			bpl !Loop-

 			ldx #7       // Index into Digit array
 			lda #$01     // Amount to add 
 			clc
 			adc Digit,x
 			jmp !Check+
!InnerLoop: 
			lda Digit,x
			adc #$00
!Check:  	cmp #$3a
			bcc !Skip+
			sbc #10
			sec
!Skip:   	sta Screen,x
			dex
			bpl !InnerLoop-
			rts



