;*****************************************************
; WORM5
; draw in Random characters on the screen
; Add in border around the screen
;*****************************************************

*=$1000
Const_KBD_BUFFER    = $c5                                   ; Keyboard matrix
Const_UP            = $09                                   ;
Const_DOWN          = $0c                                   ;values
Const_LEFT          = $0a                                   ;for up down left right
Const_RIGHT         = $0d                                   ;
Const_WORM_INCR     = $16                                   ; "T" pressed = increase length of worm
                    
;*****************************************************
; Initialize worm memory areas
;*****************************************************
                    jsr Init_Random
                    ldx                 #00
                    lda                 #00                 
@init_loop          lda                 headx
                    sta                 worm1x,x
                    lda                 heady                                  
                    sta                 worm1y,x                    
                    dex
                    bne                 @init_loop          
                    
                    lda                 headx                                   
                    sta                 worm1x              
                    sta                 bodyx                                
                    lda                 heady               
                    sta                 worm1y              
                    sta                 bodyy
                    lda                 #$93                 ; Clear the screen
                    jsr                 $ffd2
                    jsr                 draw_border         
                    
main_loop             
                    lda                 offset              
                    tax
                    lda                 worm1x,x 

                    sta                 tempx               
                    lda                 worm1y,x            
                    sta                 tempy               
                    clc
                    lda                 offset              
                    adc                 length              
                    tax                    
                    lda                 worm1x,x            
                    sta                 bodyx               
                    lda                 worm1y,x            
                    sta                 bodyy               
                                        
                    lda                 #$20                ; Erase starting position
                    pokeaxy             tempx,tempy         
                    
                    jsr                 set_direction       ; Change position of head 
                    lda                 length              
                    beq                 @no_body            
                    
                    lda                 #31                ; Draw body 
                    pokeaxy             bodyx,bodyy
                    
@no_body            inc                 offset                                  
                    lda                 headx                          
                    clc
                    lda                 offset              
                    adc                 length              
                    tax
                    lda                 headx              
                    sta                 worm1x,x                                 
                    lda                 heady              
                    sta                 worm1y,x    

                
                    peekaxy             headx,heady         ; Hit detection
                    cmp                 #$20                
@self               bne  @self

                    lda                 #$32                ; Draw head
                    pokeaxy             headx,heady       
                    jsr                 DRAW_RANDOM_CHAR

                
;*****************************************************
; finish loop
;*****************************************************
                
                    jsr                 get_key                                 
                    jsr                 delay                                   
                    jmp                 main_loop                    
                    rts
                    
DRAW_RANDOM_CHAR

                    lda                 #38
                    sta                 RAND_MAX            
                    jsr                 RAND                                    
                    tax
                    inx
                    stx                 charx               

                    lda                 #23
                    sta                 RAND_MAX            
                    jsr                 RAND                                    
                    tax
                    inx
                    stx                 chary
                    
                    lda                 #01                ; RANDOM CHAR
                    pokeaxy             charx,chary
       
                    rts
                   
charx               byte 00
chary               byte 00

;*****************************************************
; set_direction
;*****************************************************
set_direction                   
                    lda                 startdir            
                    cmp                 #1                  
                    beq                 @down
                    cmp                 #2                                    
                    beq                 @left
                    cmp                 #3                  
                    beq                 @right

@up                 dec heady
                    jmp @cont
@down               inc heady
                    jmp @cont
@left               dec headx
                    jmp @cont
@right              inc headx
                    
@cont     
                    rts
;*****************************************************
; get input
;*****************************************************

get_key             lda                 Const_KBD_BUFFER    ; Input a key from Keyboard

_ck_pressed
                    cmp                 #Const_DOWN         ; down - z pressed
                    beq                 @down
                    cmp                 #Const_Right        ; up - w pressed
                    beq                 @right
                    cmp                 #Const_LEFT         ; left - a pressed
                    beq                 @left
                    cmp                 #Const_Up           ; right - s pressed
                    beq                 @up
                    cmp                 #Const_WORM_INCR    ;T - Pressed - advance a level - cheat
                    beq                 @make_bigger            
                    rts
@down               
                    lda                 #1                  
                    sta                 startdir            ; Down
                    rts
@right              
                    lda                 #3                  
                    sta                 startdir            ; Right
                    rts
@up               
                    lda                 #0                  
                    sta                 startdir            ; Up                    
                    rts
@left             
                    lda                 #2                  
                    sta                 startdir            ; left

                    rts
@make_bigger        
                    inc                 length              
                    lda                 length              
                    clc
                    adc                 offset              
                    tax
                    
                    lda headx
                    sta                 worm1x,x            
                    lda                 heady               
                    sta                 worm1y,x            
                    rts

;***DELAY ***
delay               txa
                    pha
                    ldx                 #60                
@loop1              ldy                 #0                  
@loop2              dey
                    bne                 @loop2
                    dex
                    bne                 @loop1              
                    pla
                    rts
                    
height              byte 25  
width               byte 40
Const_BOX_X         byte                0
Const_Box_Y         byte                0
Const_Box_Color     byte 2   

draw_border
                    lda                 #0                  
                    sta                 Const_Box_X         
                    sta                 Const_Box_Y         
                    lda                 #40                 
                    sta                 width               
                    lda                 #25                 
                    sta                 height              
                    
                    ldy                 Const_BOX_Y                  
                    lda                 map_off_l,y    
                    sta                 @left_top_edge+1
                    sta                 @left_top_edgec+1
                    lda                 map_off_h,y    
                    sta                 @left_top_edge+2  
                    lda                 Const_Screen_C,y    
                    sta                 @left_top_edgec+2
                    clc
                    dey
                    tya
                    adc                 height              
                    tay                   
                    lda                 map_off_l,y    
                    sta                 @left_bot_edge+1         
                    sta                 @left_bot_edgec+1         
                    lda                 map_off_h,y    
                    sta                 @left_bot_edge+2     
                    lda                 Const_Screen_C,y                        
                    sta                 @left_bot_edgec+2         
                    ldx                 Const_BOX_X                 
                    ldy #0
                    lda                 #$2                 
@left_top_edge      sta                 $400,x                    
@left_bot_edge      sta                 $450,x
                    lda                 Const_Box_Color    
@left_top_edgec     sta                 $d800,x                                 
@left_bot_edgec     sta                 $d800,x

                    inx
                    iny
@box_width          cpy                 width
                    bne                 @left_top_edge-2                         
                    ldx #2                                ; Accounts for top and bottom of box => just draw middle 
                    ldy                 Const_BOX_Y        
                    iny
@loop2              lda                 map_off_l,y    
                    sta                 @box_top_left+1         
                    sta                 @box_top_right+1         
                    sta                 @box_top_leftc+1         
                    sta                 @box_top_rightc+1         
                    lda                 map_off_h,y    
                    sta                 @box_top_left+2         
                    sta                 @box_top_right+2  
                    lda                 Const_Screen_C,y       
                    sta                 @box_top_leftc+2         
                    sta                 @box_top_rightc+2                             

                    txa
                    pha
                    ldx                 Const_Box_X 
                    lda                 #$1                 
@box_top_left       sta                 $400,x
                    lda                 Const_Box_Color   
@box_top_leftc      sta                 $d800,x

                    dex                 
                    txa
                    clc
                    adc                 width                                   
                    tax
                    lda #1
@box_top_right      sta                 $400,x                    
                    lda                 Const_Box_Color   
@box_top_rightc     sta                 $d800,x  
                    pla
                    tax
                    inx
                    iny
                    cpx                 height                
                    bne                 @loop2              
                    rts
Init_Random
                    LDA                 #$FF                ; maximum frequency value
                    STA                 $D40E               ; voice 3 frequency low byte
                    STA                 $D40F               ; voice 3 frequency high byte
                    LDA                 #$80                ; noise SIRENform, gate bit off
                    STA                 $D412               ; voice 3 control register
                    rts

RAND              
                    LDA                 $D41B               ; get random value from 0-255
                    CMP                 RAND_MAX               ; narrow random result down
                                                            ; to between zero - g$len
                    BCC                 @dont_crash         ; ~ to 0-3
                    jmp                 RAND                
@dont_crash         rts    

tempx               byte 00
tempy               byte 00
bodyx               byte 00
bodyy               byte 00
RAND_MAX            byte                00
headx               byte                06
heady               byte                10
startdir            byte                01,00
offset              byte                00,00
length              byte                10,00
map_off_l           byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
map_off_h           byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
Const_Screen_C      byte                $d8,$d8,$d8,$d8,$d8,$d8,$d8,$d9,$d9,$d9,$d9,$d9,$d9,$da,$da,$da,$da,$da,$da,$da,$db,$db,$db,$db,$db
;*****************************************************
; Grab value of screen position located at x,y
; Store result in accumulator
;*****************************************************
defm                peekaxy
                    ldx                 /2                  ; X value
                    ldy                 /1                  ; Y Value
                    lda                 map_off_l,x         ; Load map low byte into $fb
                    sta                 $fb
                    lda                 map_off_h,x         ; Load map hig byte into $fc
                    sta                 $fc
                    lda                 ($fb),y             ; Load result into acc
                    endm
;*****************************************************
; Store value of accumulator in screen memory at position
; x, y
;*****************************************************
defm                pokeaxy
                    pha
                    ldx                 /2                  ; X value
                    ldy                 /1                  ; Y value
                    lda                 map_off_l,x         ; Load map low byte into $fb
                    sta                 $fb
                    lda                 map_off_h,x         ; Load map high byte into $fc
                    sta                 $fc
                    pla
                    sta                 ($fb),y             ; Store result in screen memory
                    endm
                    
*=$2000
worm1x
*=$2100
worm1y
