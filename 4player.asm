;*****************************************************
; 03/27/2018
; Gray Defender
;
; 4-Port Player Interface Demo source code
;*****************************************************
*=$1000
CONST_UP            = #$1e
CONST_DOWN          = #$1d
CONST_LEFT          = #$1b
CONST_RIGHT         = #$17
CONST_FIRE          = #$0f

BEGIN
                    lda                 #$93                                    
                    jsr                 $ffd2                                   
                    jsr                 INIT                                                   
LOOP                
                    jsr                 READ

                    ldx                 #0                                      
                    lda                 PORT                                    
                    jsr                 MOVE_DIR
                    ldx                 #1                                      
                    lda                 PORT+1                                    
                    jsr                 MOVE_DIR
                    ldx                 #2                                  
                    lda                 PORT+2                                    
                    jsr                 MOVE_DIR
                    ldx                 #3                                  
                    lda                 PORT+3                                    
                    jsr                 MOVE_DIR            
                    
                    lda                 PLAYERS_X
                    tax
                    lda                 PLAYERS_Y           
                    tay
                    lda Player_Char                
                    pokeaxy  Players_C

                    lda                 PLAYERS_X+1
                    tax
                    lda                 PLAYERS_Y+1         
                    tay
                    lda Player_Char+1                
                    pokeaxy Players_C+1
                    lda                 PLAYERS_X+2
                    tax
                    lda                 PLAYERS_Y+2         
                    tay
                    lda Player_Char+2                
                    pokeaxy Players_C+2
                    lda                 PLAYERS_X+3
                    tax
                    lda                 PLAYERS_Y+3         
                    tay
                    lda Player_Char+3                
                    pokeaxy Players_C+3

                    jsr delay
                    jmp LOOP
                    
MOVE_DIR
                    cmp                 CONST_UP            
                    beq                 @up
                    cmp                 CONST_DOWN          
                    beq                 @down
                    CMP                 CONST_LEFT          
                    beq                 @left
                    cmp                 CONST_RIGHT         
                    beq                 @right
                    cmp                 CONST_FIRE          
                    beq                 @fire               
                    rts                    
@up                 
                    lda Players_Y,x
                    cmp #00
                    beq @exit
                    dec Players_Y,x
                    rts
@down               lda Players_Y,x
                    cmp #24
                    beq @exit
                    inc Players_Y,x
                    rts
@left   
                    lda Players_X,x
                    cmp #00
                    beq @exit
                    dec Players_X,x
                    rts
@right              
                    lda Players_X,x
                    cmp #39
                    beq @exit
                    inc Players_X,x
                    rts
@fire               inc Players_C,x                    
@exit               rts


delay               ldy #50
@loop2              ldx                 #0
@loop               dex
                    bne                 @loop               
                    dey
                    bne @loop2
                    rts                  

;*****************************************************
; Store acc at position on screen located at x,y
;*****************************************************
defm                pokeaxy
                    sta                 @char+1             ; Save character to poke
                    lda                 map_off_l,y         ; Load map low byte into $fb
                    sta                 @screen+1           
                    sta                 @colpos+1
                    clc
                    lda                 map_off_h,y         ; Load map high byte into $fc
                    sta                 @screen+2           
                    adc                 #$d4                
                    sta                 @colpos+2
@char               lda                 #$00                                    
@screen             sta                 $400,x              ; Store result in screen memory
@color              lda /1                                  ; at pos x,y
@colpos             sta                 $d800,x
                    endm                                    

map_off_l           byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
map_off_h           byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07


Players_X           byte                10,10,10,10                    
Players_Y           byte                00,01,02,03                    
Players_C           byte                01,02,03,04     ; colors              
Player_Char         byte                $31,$32,$33,$34
PORT                byte                00,00,00,00
                    
INIT

    LDA #$80
    STA $DD03 ; CIA2 PortB Bit7 as OUT
    LDA $DD01 ; force Clock-Stretching (SuperCPU)
    STA $DD01 ; and release Port
    RTS

READ

    LDA $DC01 ; read Port1
    AND #$1F
    STA PORT+$00

    LDA $DC00 ; read Port2
    AND #$1F
    STA PORT+$01

    LDA $DD01 ; CIA2 PortB Bit7 = 1
    ORA #$80
    STA $DD01

    LDA $DD01 ; read Port3
    AND #$1F
    STA PORT+$02

    LDA $DD01 ; CIA2 PortB Bit7 = 0
    AND #$7F
    STA $DD01

    LDA $DD01 ; read Port4
    PHA ; Attention: FIRE for Port4 on Bit5, NOT 4!
    AND #$0F
    STA PORT+$03
    PLA
    AND #$20
    LSR
    ORA PORT+$03
    STA PORT+$03
    RTS