// Gray Defender
// 9/12/2021
//
// This is my entry for the Shallan50k
// September 2021 programming compo

* = $34
cols:     	.byte 0,WHITE,BLUE,RED,BLUE,5,BLUE,13,BLUE,RED,BLUE,9,BLUE,9,BLUE,BLUE,2	 
maxbytes: 	.byte 0,1,1,2,3,5,8,13,21,34,55,89,144,233,255,122,14
start:
toploop:	
	ldx.z maxbytes,y
loop:	
	 lda.zp #$51
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
	 cpy #$11
	 bne toploop
	rts	


//    dey            // Must be at $73 when compiled
//    beq start	
  	
