*=$0801

        BYTE    $0E,$08,$0A,$00,$9E,$20,$28,$32,$30,$36,$34,$29,$00,$00,$00

; [CODE START] ----------------------------------------------------------------

*=$0810
Const_StartLine     = $400
CS                  = $3000
                    
Const_Char1      = CS+$200
Const_Char2      = CS+$201
Const_Char3      = CS+$202
Const_Char4      = CS+$203
Const_Char5      = CS+$204
Const_Char6      = CS+$205
Const_Char7      = CS+$206
Const_Char8      = CS+$207                    

;http://dustlayer.com/vic-ii/2013/4/23/vic-ii-for-beginners-part-2-to-have-or-to-not-have-character

; ***********************************************************************************
; Step 1 Redefine char set    
; ***********************************************************************************

Character_Set        
                    lda                 #$93                
                    jsr                 $ffd2               
                  
                    sei                                     ; disable interrupts while we copy
                    ldx                 #$08                ; we loop 8 times (8x255 = 2Kb)
                    lda                 #$33                ; make the CPU see the Character Generator ROM...
                    sta                 $01                 ; ...at $D000 by storing %00110011 into location $01
                    lda                 #$d0                ; load high byte of $D000
                    sta                 $fc                 ; store it in a free location we use as vector
                    LDA                 #>CS                ;
                    STA                 $fe                 ;
                    LDA                 #0                  ;
                    STA                 $fd
                    ldy                 #$00                ; init counter with 0
                    sty                 $fb                 ; store it as low byte in the $FB/$FC vector
loop                lda                 ($fb),y             ; read byte from vector stored in $fb/$fc
                    sta                 ($fd),y             ; write to the RAM under ROM at same position
                    iny                                     ; do this 255 times...
                    bne                 loop                ; ..for low byte $00 to $FF
                    inc                 $fc                 ; when we passed $FF increase high byte...
                    inc                 $fe
                    dex                                     ; ... and decrease X by one before restart
                    bne                 loop                ; We repeat this until X becomes Zero
                    lda                 #$37                ; switch in I/O mapped registers again...
                    sta                 $01                 ; ... with %00110111 so CPU can see them
                    cli                                    ; turn off interrupt disable flag
                    LDA                 #28    
                    STA                 $d018               ;

; ***********************************************************************************
; Step 2 Initialize the redefined characters in charset used for scrolling, they
;        -start at index charset index 64 which equate to 64*8 = $200 + $3000=$3200 
; ***********************************************************************************

                    
                    ldy                 #$00                  
@inner              lda #0
                    sta                 CS+$200,y                                 
                    iny
                    cpy                 #255                  
                    bne                 @inner
                    ldy                 #00                
@inner2             sta                 $32ff,y             
                    iny
                    cpy #66
                    bne                 @inner2    
                   
; ***********************************************************************************
; Step 3 - Display the redefined characters on screen
;        - In this case in one lines across the entire screen
; ***********************************************************************************

                    ldy                 #0                  
                    ldx                 #64    ; character set offset            
@loop1              txa
                    sta                 Const_StartLine,y              
                    iny
                    inx
                    cpy                 #40             
                    bne                 @loop1              
                    
; ***********************************************************************************
; Step 4 - start shifting the redefined characters
; ***********************************************************************************

                    ldx                 #0                  
@keepgoing                             
                    lda                 newmessage,x
                    beq                 @done               
                    jsr                 grab_next_char                      
                    jsr                 shift_all_chars                    
                    inx
                    jmp                 @keepgoing          
@done               rts
                   
; ***********************************************************************************
; Subroutines Grab next char
; ***********************************************************************************
grab_next_char                  
                    tay
                    lda                 charhi,y            
                    sec
                    sbc                 #2                  
                    sta                 $fc                 
                    lda                 charlow,y            
                    sta                 $fb        
         
                    ldy                 #40            ; # chars index into charset                                
                    lda                 charhi,y            
                    sta                 $fe                 
                    lda                 charlow,y           
                    sta                 $fd                 
                    
                    ldy                 #0                                      
@inner              lda                 ($fb),y       ; Source character set
                    sta                 ($fd),y       ; Dest in redefined area
                    iny
                    cpy                 #8                                      
                    bne                 @inner                
@end_loop           rts
                    
; ***********************************************************************************
; Subroutine  Shift char
; ***********************************************************************************
                   
shift_all_chars                         
                    jsr                 Shift_Once          
                    jsr                 Shift_Once          
                    jsr                 Shift_Once          
                    jsr                 Shift_Once          
                    jsr                 Shift_Once          
                    jsr                 Shift_Once          
                    jsr                 Shift_Once          
                    jsr                 Shift_Once          
                    rts
Shift_Once          
                    jsr Smooth_Scroll 
                    ;jsr delay                                   
                    RotateLine          Const_Char8
                    RotateLine          Const_Char7
                    RotateLine          Const_Char6
                    RotateLine          Const_Char5
                    RotateLine          Const_Char4
                    RotateLine          Const_Char3          
                    RotateLine          Const_Char2          
                    RotateLine          Const_Char1          
                    rts



; ***********************************************************************************
; Subroutine  Smooth_Scroll
; ***********************************************************************************

Smooth_Scroll
;@w1                 bit $d011                       ; Wait for Raster to be off screen 
;                    bpl @w1 
;@w2                 bit $d011 
;                    bmi                 @w2                 

@loop
                    lda                 $D012               
                    cmp #200
                    bcc                 @loop
                    rts

delay
                    txa
                    pha
                    ldy #5
@loop2              ldx                 #0
@loop               dex
                    bne                 @loop               
                    dey
                    bne                 @loop2              
                    pla
                    tax
                    rts

; ***********************************************************************************
; Macro: Rotateline  
;        Shift an entire row 40 characters over one bit
;        starting from the right then advancing left
; ***********************************************************************************
defm                RotateLine
  
                    rol                 /1+320           
                    rol                 /1+312           
                    rol                 /1+304           
                    rol                 /1+296      
                    rol                 /1+288                               
                    rol                 /1+280              
                    rol                 /1+272              
                    rol                 /1+264                               
                    rol                 /1+256              
                    rol                 /1+248          
                    rol                 /1+240                               
                    rol                 /1+232           
                    rol                 /1+224              
                    rol                 /1+216                             
                    rol                 /1+208          
                    rol                 /1+200              
                    rol                 /1+192                              
                    rol                 /1+184         
                    rol                 /1+176          
                    rol                 /1+168          
                    rol                 /1+160          
                    rol                 /1+152           
                    rol                 /1+144           
                    rol                 /1+136         
                    rol                 /1+128          
                    rol                 /1+120          
                    rol                 /1+112           
                    rol                 /1+104           
                    rol                 /1+96           
                    rol                 /1+88           
                    rol                 /1+80           
                    rol                 /1+72           
                    rol                 /1+64           
                    rol                 /1+56           
                    rol                 /1+48           
                    rol                 /1+40           
                    rol                 /1+32           
                    rol                 /1+24           
                    rol                 /1+16           
                    rol                 /1+8
                    rol                 /1

;                    rol                 /1
;                    rol                 /1+8
;                    rol                 /1+16           
;                    rol                 /1+24           
;                    rol                 /1+32           
;                    rol                 /1+40           
;                    rol                 /1+48           
;                    rol                 /1+56           
;                    rol                 /1+64           
;                    rol                 /1+72           
;                    rol                 /1+80           
;                    rol                 /1+88           
;                    rol                 /1+96           
;                    rol                 /1+104           
;                    rol                 /1+112           
;                    rol                 /1+120          
;                    rol                 /1+128          
;                    rol                 /1+136         
;                    rol                 /1+144           
;                    rol                 /1+152           
;                    rol                 /1+160          
;                    rol                 /1+168          
;                    rol                 /1+176          
;                    rol                 /1+184         
;                    rol                 /1+192          
;                    rol                 /1+200           
;                    rol                 /1+208          
;                    rol                 /1+216         
;                    rol                 /1+224          
;                    rol                 /1+232           
;                    rol                 /1+240           
;                    rol                 /1+248          
;                    rol                 /1+256           
;                    rol                 /1+264           
;                    rol                 /1+272      
;                    rol                 /1+280          
;                    rol                 /1+288                               
;                    rol                 /1+296      
;                    rol                 /1+304           
;                    rol                 /1+312           
;                    rol                 /1+320           

                    endm
                 
newmessage          null 'hello this is a message from gray defender this is my message will it repeat            it might!                           '                    
charlow             byte $00,$08,$10,$18,$20,$28,$30,$38,$40,$48,$50,$58,$60,$68,$70,$78,$80,$88,$90,$98,$a0,$a8,$b0,$b8,$c0,$c8,$d0,$d8,$e0,$e8,$f0,$f8,$00,$08,$10,$18,$20,$28,$30,$38,$40,$48
charhi              byte >CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+2,>CS+3,>CS+3,>CS+3,>CS+3,>CS+3,>CS+3,>CS+3,>CS+3,>CS+3,>CS+3













