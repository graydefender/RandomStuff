// Gray Defender
// 9/12/2021
//
// This is my entry for the Shallan50k
// September 2021 programming compo

* = $34
start:
toploop:	
	ldx.z maxbytes,y  	// Load count of # of bytes to draw
inner:	 			// Loop through all of these
	lda.zp #$51
 	sta sc:$400	       // Output character
       lda.zp cols,y        
       sta col:$d800	       // Output color
	inc col  		// Increment screen and color positions
       inc sc 		// 
       bne no_MSB           // check if crossed 255 boundary
       inc sc+1   	       // if so then increment upper bytes
       inc col+1            //
no_MSB:        
	dex 
	bne inner	
	iny                  
	cpy #$10             // Have we hit the maximum number of loops required?
	bne toploop
		
cols:     .byte WHITE,BLUE,RED,BLUE,GREEN,BLUE,LIGHT_GREEN,BLUE,RED,BLUE,BROWN,BLUE,BROWN,BLUE,BLUE,RED	 
maxbytes: .byte 1,1,2,3,5,8,13,21,34,55,89,144,233,255,122,14
       dey            	// This code must start at $73 when compiled
       beq start	    	// otherwise cahpewie...
  	
