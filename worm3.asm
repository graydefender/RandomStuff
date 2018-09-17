*=$1000
Const_KBD_BUFFER    = $c5                                   ; Keyboard matrix
Const_UP            = $09                                   ;
Const_DOWN          = $0c                                   ;values
Const_LEFT          = $0a                                   ;for up down left right
Const_RIGHT         = $0d                                   ;
Const_LEVELUP_KEY   = $16                                   ; "T" pressed = increase length of worm
;*****************************************************
; Initialize worm memory areas
;*****************************************************
                    ldx                 #0
                    lda                 #0
loop                sta                 worm1x,x
                    sta                 worm1y,x
                    inx
                    dex
                    bne                 loop                
                    lda                 #$93                 ; Clear the screen
                    jsr                 $ffd2
               
main_loop             

                    lda                 offset              
                    tax
                    lda                 worm1x,x            
                    sta                 tempx               
                    
                    lda                 worm1y,x            
                    sta                 tempy               
                                
                    lda                 #0                                          
                    sta                 worm1x,x                                 
                    sta                 worm1y,x  

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
                    lda                 #31                 
                    pokeaxy             bodyx,bodyy       
                    
                    jsr                 set_direction       ; Change position of head 
                    inc                 offset                                  
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


                
;*****************************************************
; finish loop
;*****************************************************
                
                    jsr                 get_key                                 
                    jsr                 delay                                   
                    jmp                 main_loop                    
                    rts
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
                    sta $400

_ck_pressed
                    cmp                 #Const_DOWN         ; down - z pressed
                    beq                 @down
                    cmp                 #Const_Right        ; up - w pressed
                    beq                 @right
                    cmp                 #Const_LEFT         ; left - a pressed
                    beq                 @left
                    cmp                 #Const_Up           ; right - s pressed
                    beq                 @up
                    cmp                 #Const_LEVELUP_KEY  ; T - Pressed - advance a level - cheat
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
                    ldx                 length              
                    stx                 $403                
                    rts

;***DELAY ***
delay               txa
                    pha
                    ldx                 #$80                
@loop1              ldy                 #0                  
@loop2              dey
                    bne                 @loop2
                    dex
                    bne                 @loop1              
                    pla
                    rts
tempx               byte 00
tempy               byte 00
bodyx               byte 00
bodyy               byte 00

headx               byte                06
heady               byte                10
startdir            byte                01,00
offset              byte                00,00
length              byte                20,00
map_off_l           byte                $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
map_off_h           byte                $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
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
