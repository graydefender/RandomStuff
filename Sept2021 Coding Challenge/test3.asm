
* = $34

maxbytes: 	.byte 1,1,2,3,5,8,13,21,34,55,89,144,233,255,122,14

start:
    lda #$51   // Fix memory overwrite / dumb bug
    sta $7a
    lda #$20
    sta $7b
toploop:	
    lda maxbytes,y
  	sta.zp max
	ldx max:#0
loop:	
	 lda.zp chars,y
 	 sta sc:$400
     lda.zp cols,y     
     sta col:$d800	
	 inc col
     inc sc
     bne no_MSB
     inc sc+1
     inc col+1
no_MSB:        
	 dex 
	 bne loop
	
	 iny
	 cpy #$10
	 bne toploop
	 beq *
*=* "Jump"
	 dey
     beq start	
  	
chars:
	.byte $51,32,$51,32,$51,32,$51,32,$51,32,$51,32,$51,32,32,$51

cols:
  	.byte WHITE,0,RED,0,5,0,13,0,RED,0,9,0,9,0,0,2

	 


