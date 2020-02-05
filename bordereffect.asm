;*********************
;* Gray Defender
;* 02/03/2020
;* Border Effect part 1
;*********************
*=$2000
RED       = 7
BLACK     = 0
          lda            #42
          ldx            #0
@clr_loop sta            $400,x
          sta            $500,x
          sta            $600,x
          sta            $700,x
          dex
          bne            @clr_loop

MAIN_PROGRAM
          
          ldx            #0
          ldy            #39
@loop     lda            #BLACK
          sta            $d800,x
          sta            $dbc0,y
          jsr            delay
          lda            #RED
          sta            $d800,x
          sta            $dbc0,y
          dey
          inx
          cpy            #0
          bne            @loop

          ldy            #0        
          sty            yvalue+1  
          sty            yyvalue+1 
          ldy            #25       
          sty            yvalue1+1 
          sty            yyvalue1+1
          

XXLOOP    ldx            #39       
yvalue    ldy            #0        
          lda            #BLACK    
          pokecoloraxy          
yvalue1   ldy            #25       
          ldx            #0                 
          pokecoloraxy

          jsr            delay     

          ldx            #39       
yyvalue   ldy            #0        
          lda            #RED
          pokecoloraxy          
yyvalue1  ldy            #25       
          ldx            #0                 
          pokecoloraxy

          inc            yvalue+1            
          inc            yyvalue+1           
          dec            yvalue1+1          
          dec            yyvalue1+1
          ldy            yvalue+1  
          cpy            #25       
          bne            XXLOOP    
          JMP            MAIN_PROGRAM
          
;*******************************************
delay     
          txa
          pha
          tya
          pha
          ldx             #50
@lp1      ldy             #40
@lp2      dey
          bne            @lp2
          dex
          bne            @lp1
          pla
          tay
          pla
          tax
          
          rts
;*******************************************
defm                pokecoloraxy
                    sta                 @char+1             ; Save character to poke
                    lda                 map_off_l,y         ; Load map low byte into $fb
                    sta                 @screen+1                 
                    lda                 map_off_hc,y         ; Load map high byte into $fc
                    sta                 @screen+2                 
@char               lda                 #$00                                    
@screen             sta                 $d800,x              ; Store result in screen memory
                    endm                                    ; at pos x,y

map_off_l           byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
map_off_h           byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
map_off_hc          byte                $D8,$D8,$D8,$D8,$D8,$D8,$D8,$D9,$D9,$D9,$D9,$D9,$D9,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DB,$DB,$DB,$DB,$DB
       
          