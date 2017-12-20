*=$0801

        BYTE    $0E,$08,$0A,$00,$9E,$20,$28,$32,$30,$36,$34,$29,$00,$00,$00

; [CODE START] ----------------------------------------------------------------

*=$0810
Const_StartLine     = $7c0
                    
;http://dustlayer.com/vic-ii/2013/4/23/vic-ii-for-beginners-part-2-to-have-or-to-not-have-character

; ***********************************************************************************
; Step 1 Redefine char set    
; ***********************************************************************************
Character_Set
                    
                    sei                                     ; disable interrupts while we copy
                    ldx                 #$08                ; we loop 8 times (8x255 = 2Kb)
                    lda                 #$33                ; make the CPU see the Character Generator ROM...
                    sta                 $01                 ; ...at $D000 by storing %00110011 into location $01
                    lda                 #$d0                ; load high byte of $D000
                    sta                 $fc                 ; store it in a free location we use as vector
                    LDA                 #$30                ;
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
; Step 2 - Initialize the redefined characters in charset used for scrolling, they
;          start at index charset index 64 which equate to 64*8 = $200 + $3000=$3200 
; ***********************************************************************************
                    ldy                 #$00                  
@inner              lda #0
                    sta                 $3200,y                                 
                    iny
                    cpy                 #255                  
                    bne                 @inner
                    ldy                 #00                
@inner2             sta                 $32ff,y             
                    iny
                    cpy #66
                    bne                 @inner2             


; ***********************************************************************************
; Step 3 - put redefined characters on a row on the screen
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
; Step 4 - MAIN PROGRAM LOOP - start the shifting 
; ***********************************************************************************

                    ldx                 #0                  
@keepgoing          
                                      
                    lda                 newmessage,x        
                    beq                 @done               

                    jsr                 grab_next_char                           
                    stx xsave
                    jsr                 shiftchar           
                    jsr                 shiftchar           
                    jsr                 shiftchar           
                    jsr                 shiftchar                               
                    jsr                 shiftchar           
                    jsr                 shiftchar           
                    jsr                 shiftchar           
                    jsr                 shiftchar
                    ldx xsave
                    inx
                    jmp                 @keepgoing          
@done               rts
                   
                    
; ***********************************************************************************
; Subroutines Grab next char
; ***********************************************************************************
grab_next_char                  
                    tay
                    lda                 charhi,y            
                    sbc #2
                    sta                 $fc                 
                    lda                 charlow,y            
                    sta                 $fb                 
                    ldy                 #40                                 
                    lda                 charhi,y            
                    sta                 $fe                 
                    lda                 charlow,y           
                    sta                 $fd 
                    ldy                 #0                                      
@inner              lda                 ($fb),y
                    sta                 ($fd),y   
                    iny
                    cpy                 #8                                      
                    bne                 @inner              
@end_loop           rts

; ***********************************************************************************
; Subroutine  Shift char
; ***********************************************************************************
                   
shiftchar     
                    jsr Smooth_Scroll      
                    ldx                 #00                
@loop
                    txa
                    tay                    
                    lda                 charhi,y
                    sta                 $fc                 
                    lda                 charlow,y            
                    sta                 $fb                 
                    iny
                    lda                 charhi,y
                    sta                 $fe                 
                    lda                 charlow,y            
                    sta                 $fd                 
                    ldy                 #7                                    
@loopab                    
                    lda                 ($fd),y             
                    and                 #%10000000          
                    bne                 @sec                    
@clc                clc
                    jmp @cont              
@sec                sec
@cont               lda                 ($fb),y                  
                    rol
                    sta                 ($fb),y            
                    dey
                    cpy #$ff
                    bne                 @loopab             
                    inx
                    bne @keepgoing
@keepgoing          cpx                 #41
                    bne @loop
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
                    cmp #100
                    bcc                 @loop
                    rts

xsave               byte 00                   
newmessage          null 'hello this is a message from gray defender this is my message will it repeat            it might!                           '                    
charlow             byte $00,$08,$10,$18,$20,$28,$30,$38,$40,$48,$50,$58,$60,$68,$70,$78,$80,$88,$90,$98,$a0,$a8,$b0,$b8,$c0,$c8,$d0,$d8,$e0,$e8,$f0,$f8,$00,$08,$10,$18,$20,$28,$30,$38,$40,$48
charhi              byte $32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$32,$33,$33,$33,$33,$33,$33,$33,$33,$33,$33
