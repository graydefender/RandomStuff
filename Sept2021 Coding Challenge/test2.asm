* = $1000

start:
	
toploop:	
    lda maxbytes,y
  	sta max
	ldx max:#0
loop:	
	 lda #$51
!:	 sta sc:$400
     lda cols,y     
     sta col:$d800	
	 inc col
     inc sc
     bne !+
     inc sc+1
     inc col+1
!:        
	 dex 
	 bne loop
	
	 iny
	 cpy #$10
	 bne toploop
	 beq *
//chars:
//	.byte $51,32,$51,32,$51,32,$51,32,$51,32,$51,32,$51,32,32,$51

cols:
  	.byte WHITE,BLUE,RED,BLUE,5,BLUE,13,BLUE,RED,BLUE,9,BLUE,9,BLUE,BLUE,2

maxbytes: 	.byte 1,1,2,3,5,8,13,21,34,55,89,144,233,255,122,14
	 


