//*** Base64 Decode text
//*** April 2022 Monthly Coding Challenge
//*** Can't wait to see the top entries!
//*** Gray Defender
//*** 04/22/2022

.label SCREEN=$400

* = $64 "Temp" virtual
Decode_Counter:		.byte  00
blank_line_count:   .byte  00

puzzle:        .byte 00,00,00,00
Print_Screen:  .byte 00,00
Data_Source:   .byte 00,00

*=$c000
start:		
//* Variable initiailzation
		lda #>SCREEN
		sta Data_Source+1
		sta Print_Screen+1
		lda #<SCREEN
		sta Data_Source
		sta Print_Screen	

		lda #7                    // Used to clear garbage on screen at the end
		sta blank_line_count
		lda #241		    	  // 1000/4  tweaked a little ..for performance
		sta Decode_Counter		  // Loop counter, just need to do as many times to finish decode screen
main_loop:
		dec Decode_Counter
		bne decode

Finished:	
		dec blank_line_count      // Now blank out 7 lines DOWN below the decoded text
		beq done

		lda #>blankline	         
		sta Data_Source+1
		lda #<blankline
		sta Data_Source
		lda #15                   // 15 ACROSS
		sta Decode_Counter
		jmp main_loop
done:   rts

//*******************************		
decode:
		
//******************************
adjust_ascii:
// before decode:
//******************************
		ldy #3
loop:
		lda (Data_Source),y
		
		cmp #43
		beq Fix1
		cmp #47
		beq Fix2


		cmp #65      // 65
		bcs sub65     // Subtract acsii letter 'a'
		cmp #48      // 48..
		bcs number    // Adjust if character is a number
		cmp #27      // 26 ..Adjust if character is lower case
		bcs skip
		clc
		adc #25
	    //sta puzzle,y
	    jmp skip
Fix1:   
        lda #62
        jmp skip
Fix2:   
        lda #63
        jmp skip

number:		
		clc
		adc #4
		//sta puzzle,y
		jmp skip
sub65:		
		sec
		sbc #65
		//sta puzzle,y
skip:	
        sta puzzle,y	
		dey		
		bpl loop	
//******************************		
//******************************		
		asl puzzle+3
		asl puzzle+3
		rol puzzle+3 
		rol puzzle+2
		rol puzzle+3
		rol puzzle+2
		asl puzzle+3
		rol puzzle+2
		rol puzzle+1
		asl puzzle+3
		rol puzzle+2
		rol puzzle+1
		asl puzzle+3
		rol puzzle+2
		rol puzzle+1
		rol puzzle
		asl puzzle+3
		rol puzzle+2
		rol puzzle+1
		rol puzzle
//*******************************
		ldy #2 						// This was a loop, but unrolled to save cycles
		lda puzzle,y
		sta (Print_Screen),y
		dey
		lda puzzle,y
		sta (Print_Screen),y			
		dey
    	lda puzzle,y
		sta (Print_Screen),y
	
		clc
		lda Print_Screen
		adc #$3
		sta Print_Screen
		bcc part2
		inc Print_Screen+1
part2:
		clc
		lda Data_Source
		adc #$4
		sta Data_Source
		bcc more	
		inc Data_Source+1		
more:
		jmp main_loop

blankline:
.text   "ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg"

