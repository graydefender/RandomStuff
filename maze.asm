;** Gray Defender 11/04/2018
;** Draw Maze - Recursive backtracking algorithm
;** Adapted from:
;   "https://rosettacode.org/"
*=$1000
Const_Width         = #19                                  ; Valid values are 3 up to 20
Const_Height        = #12                                  ; Valid values are 3 up to 13
Const_Ch            = 160
                    
                    jsr               CHECK_VALID_X_Y    
                    beq               valid_xy         
                    rts
BEGIN
valid_xy            jsr               INIT_ALL_VARIABLES
                    jsr               DRAW_START_CHARS
                    jsr               DRAW_MAZE_BORDER
;*****************************************************
;** push the variables x, y onto the "stack"
;*****************************************************
PUSH_STACK          inc               index
                    ldx               index
                    lda               x
                    sta               STACK_X,x
                    lda               y
                    sta               STACK_Y,x
;*****************************************************
;** Represents lines 1270-1350 in maze1.bas
;*****************************************************
                    lda               #1
                    pokeVisitaxy      x,y               
                    
; ******* Set up x-1 , x+1 , y-1, y+1 *******
AFTER_POP
                    lda               x
                    sta               visit_right
                    inc               visit_right
                    lda               x
                    sta               visit_left
                    dec               visit_left
                    lda               y
                    sta               visit_down
                    inc               visit_down
                    lda               y
                    sta               visit_up
                    dec               visit_up
;*****************************************************
;** Have we aleady visited up/down/left and right?
;** if so POP the stack / back track
;*****************************************************
                    peekVisitaxy      visit_right,y
                    beq               RANDOM_DIR
                    peekVisitaxy      x,visit_down
                    beq               RANDOM_DIR
                    peekVisitaxy      visit_left,y
                    beq               RANDOM_DIR
                    peekVisitaxy      x,visit_up
                    beq               RANDOM_DIR
                    jmp               EXIT_and_POP_STACK
;*****************************************************
;** Randomly check all directions
;** If not visited, then VISIT that spot
;*****************************************************
RANDOM_DIR          lda               #4                ;** Pick random # 0-3
                    sta               RND_VALUE
@rnd_loop           jsr               RAND
                    sta               Z
                    cmp               #0
                    beq               @CK_UP_ONE        ;** Check up one
@cmp_1              cmp               #1
                    beq               @CK_DOWN_ONE      ;** Check down
@cmp_2              cmp               #2
                    beq               @CK_LEFT_ONE      ;** Check left
@cmp_3              cmp               #3
                    beq               @CK_RIGHT_ONE     ;** Check right
                    jmp               @rnd_loop
;*****************************************************
;* Has Up been visited?
@CK_UP_ONE
                    peekVisitaxy      x,visit_up
                    beq               @ok_To_Visit0
                    lda               Z
                    jmp               @cmp_1
@ok_To_Visit0
                    jsr               Set_Up_Visit
                    jmp               PUSH_STACK
;*****************************************************
;* Has Down been visited?
@CK_DOWN_ONE
                    peekVisitaxy      x,visit_down
                    beq               @ok_To_Visit1
                    lda               Z
                    jmp               @cmp_2
@ok_To_Visit1       jsr               Set_Down_Visit
                    jmp               PUSH_STACK
;*****************************************************
;* Has Left been visited?
@CK_LEFT_ONE
                    peekVisitaxy      visit_left,y
                    beq               @ok_To_Visit2
                    lda               Z
                    jmp               @cmp_3
@ok_To_Visit2       jsr               Set_Left_Visit
                    jmp               PUSH_STACK
;*****************************************************
;* Has Right been visited?
@CK_RIGHT_ONE
                    peekVisitaxy      visit_right,y
                    bne               @back_to_RND      ; Already visited, loop and pick another rnd
@ok_To_Visit3       jsr               Set_Right_Visit
                    jmp               PUSH_STACK        ;Push x,y on stack and do it all again
@back_to_RND        jmp RANDOM_DIR
;*****************************************************
; POP variables x, y off of stack
; If no more stack left, then exit program - maze done
;*****************************************************
EXIT_and_POP_STACK
                    ldx               index
                    lda               STACK_Y,x
                    sta               y
                    lda               STACK_X,x
                    sta               x
                    dec               index
                    lda               index
                    beq               @done
                    jmp               AFTER_POP
@done               rts

;*****************************************************
; RANDOM Number SUB
;*****************************************************
Init_Random
                    LDA               #$FF              ; maximum frequency value
                    STA               $D40E             ; voice 3 frequency low byte
                    STA               $D40F             ; voice 3 frequency high byte
                    LDA               #$80              ; noise SIRENform, gate bit off
                    STA               $D412             ; voice 3 control register
                    rts
RAND                lda               RND_VALUE         ; These two lines
                    beq               @dont_crash       ; prevent program crash
                    LDA               $D41B             ; get random value from 0-255
                    CMP               RND_VALUE         ; narrow random result down
                                                        ; to between zero - RND_VALUE
                    BCC               @dont_crash
                    jmp               RAND
@dont_crash         rts

;*****************************************************
;** Zero out all important variables in program
;*****************************************************
INIT_ALL_VARIABLES
                    lda               #$0               
                    sta 53280
                    lda               #$93              ; shift clear dec 147
                    jsr               $FFD2             ; clear screen
                    jsr               Init_Random       ; Init random # generator
                    lda               #2                ; Inital value for 0 or 1
                    sta               RND_VALUE
                    ldy               #0
                    lda               #0
                    sta               index             ; Init Index
@_loop              sta               STACK_X,y         ; Init Stack X Index
                    sta               STACK_Y,y         ; Init Stack Y Index
                    sta               Visits,y          ; Init Visits Array
                    sta               Visits+256,y      ;
                    dey
                    bne               @_loop
                    rts
CHECK_VALID_X_Y
                    lda               Const_Width       
                    cmp               #3 
                    bcc               @invalid          
                    cmp               #21                
                    bcs               @invalid          
                    lda               Const_Height       
                    cmp               #3 
                    bcc               @invalid          
                    cmp               #14                
                    bcs               @invalid          
                    lda #0
                    rts
@invalid           
                    lda #1
                    rts                    
;*****************************************************
;** This SUB starts the maze drawing by
;** placing the first MAZE character on the screen
;** then randomly determines whether to draw the second
;** character on the screen when the program starts
;*****************************************************
DRAW_START_CHARS
                    ADD               x,x,screenx
                    ADD               y,y,screeny
                    lda               #Const_ch
                    pokeaxy           screenx,screeny   ; Draw char on screen
                    lda               #2                ; Skip this one randomly 50% OF THE TIME
                    sta               RND_VALUE
                    sty               tempy
                    jsr               RAND
                    CMP               #$00
                    beq               @rtn
                    ldy               tempy
                    dey
                    sty               screeny
                    lda               #Const_ch
                    pokeaxy           screenx,screeny   ; Draw in char on screen on below first one
@rtn                rts

#REGION DRAW BORDER AROUND THE MAZE

DRAW_MAZE_BORDER
;*****************************************************
;** DRAW BORDER AROUND THE MAZE
;** At the same time this SUB also marks the
;** entire border as having already been "visited"
;*****************************************************
;** This section draws the horizontal border lines
                    lda               #0
                    sta               screenx
                    ldx               #0
@loop               stx               screeny
                    lda               #1
                    pokeVisitaxy      screenx,screeny
                    ADD               screenx,Const_Width,Visit_left                    
                    lda               #1
                    pokeVisitaxy      visit_left,screeny
                    ADD               Const_Width,Const_Width,Visit_Right
                    ADD               Const_Height,screeny,border_x                    
                    lda               #Const_ch
                    pokeaxy           screenx,screeny                    
                    pokeaxy           visit_right,screeny
                    pokeaxy           screenx,border_x  
                    
                    lda               visit_right
                    cmp               #40               ; Fixes minor bug when width>20
                    bcs               @down
                    lda               #Const_ch
                    pokeaxy           visit_right,border_x
@down               ldx               screeny
                    inx
                    cpx               #Const_Height+1
                    beq               @cont
                    jmp               @loop             ; Ran out of 128 branch bytes had to jmp
;*****************************************************
;** Draw Horizontal lines and set border visits
;*****************************************************
@cont               ldx #0
loop2               stx               screenx
                    lda               #0
                    sta               screeny
                    lda               #1
                    pokeVisitaxy      screenx,screeny
                    lda               Const_Height
                    sta               screeny
                    lda               #1
                    pokeVisitaxy      screenx,screeny
                    lda               #0
                    sta               visit_right       
                    ADD               Const_Height,Const_Height,border_y
                    ADD               screenx,Const_Width,visit_left
                    lda               #Const_ch
                    pokeaxy           screenx,visit_right                                           
                    pokeaxy           screenx,border_y                   
                    pokeaxy           visit_left,visit_right
                    pokeaxy           visit_left,border_y
                    ldx               screenx
                    inx
                    cpx               #Const_Width
                    beq               @return
                    jmp               loop2
@return             rts
#ENDREGION

;*****************************************************
;** Set visit flag on top (up) side neighbor and poke
;** wall characters onto the screen display
;*****************************************************
Set_Up_Visit
                    lda               #1
                    pokeVisitaxy      x,visit_up
                    dec               y
                    jsr               Set_Visit_SUB
                    dec               screeny
                    lda               #Const_ch
                    pokeaxy           screenx,screeny
                    rts
;*****************************************************
;** Set visit flag on bottom (down) side neighbor and poke
;** wall characters onto the screen display
;*****************************************************
Set_Down_Visit
                    lda               #1
                    pokeVisitaxy      x,visit_down
                    inc               y
                    jsr               Set_Visit_SUB
                    inc               screeny
                    lda               #Const_ch
                    pokeaxy           screenx,screeny
                    rts
;*****************************************************
;** Set visit flag on left side neighbor and poke
;** wall characters onto the screen display
;*****************************************************
Set_Left_Visit
                    lda               #1
                    pokeVisitaxy      visit_left,y
                    dec               x
                    jsr               Set_Visit_SUB
                    lda               #Const_ch
                    dec               screenx
                    pokeaxy           screenx,screeny
                    rts
;*****************************************************
;** Set visit flag on right side neighbor and poke
;** wall characters onto the screen display
;*****************************************************
Set_Right_Visit
                    lda               #1
                    pokeVisitaxy      visit_right,y
                    inc               x
                    jsr               Set_Visit_SUB
                    inc               screenx
                    lda               #Const_Ch
                    pokeaxy           screenx,screeny
                    rts
;*****************************************************
;** Poke character on screen at new visit location
;** which is at x*2 and y*2
;*****************************************************
Set_Visit_SUB
                    ADD               x,x,screenx
                    ADD               y,y,screeny
                    lda               #Const_ch
                    pokeaxy           screenx,screeny
                    rts
                    
#REGION PROGRAM MACROS
;*****************************************************
;** Macro: Extract value in Array at pos x,y
;*****************************************************
defm                peekvisitaxy
                    ldx               /2                ; X value
                    ldy               /1                ; Y Value
                    lda               map_off_l,x       ; Load map low byte into $fb
                    sta               $fb
                    lda               map_vis_h,x       ; Load map hig byte into $fc
                    sta               $fc
                    lda               ($fb),y           ; Load result into acc
                    endm
defm                peekaxy
                    ldx               /2                ; X value
                    ldy               /1                ; Y Value
                    lda               map_off_l,x       ; Load map low byte into $fb
                    sta               $fb
                    lda               map_off_h,x       ; Load map hig byte into $fc
                    sta               $fc
                    lda               ($fb),y           ; Load result into acc
                    endm
;*****************************************************
;** Macro: Set value in Array at pos x,y
;*****************************************************
defm                pokeaxy
                    pha
                    ldx               /2                ; X value
                    ldy               /1                ; Y value
                    lda               map_off_l,x       ; Load map low byte into $fd
                    sta               $fd
                    lda               map_off_h,x       ; Load map high byte into $fd
                    sta               $fe
                    pla
                    sta               ($fd),y           ; Store result in screen memory
                    endm
defm                pokeVisitaxy
                    pha
                    ldx               /2                ; X value
                    ldy               /1                ; Y value
                    lda               map_off_l,x       ; Load map low byte into $fd
                    sta               $fd
                    lda               map_vis_h,x       ; Load map high byte into $fd
                    sta               $fe
                    pla
                    sta               ($fd),y           ; Store result in screen memory
                    endm                                ; at pos x,y
;*****************************************************
;** Macro: Add first two parameters and store in 3rd
;*****************************************************
defm                ADD                           
                    clc
                    lda               /1
                    adc               /2
                    sta               /3
                    endm
#ENDREGION

;*****************************************************
;                  VARIABLES
;*****************************************************

#region PROGRAM VARIABLES

RND_VALUE           byte              00
x                   byte              02
y                   byte              02
Z                   byte              00 ; Rand # result
tempy               byte              00
index               byte              00
screenx             byte              00
screeny             byte              00
visit_left          byte              00
visit_right         byte              00
visit_up            byte              00
visit_down          byte              00
border_x            byte              00
border_y            byte              00
;*****************************************************
;               VARIABLE ARRAYS
;*****************************************************
map_off_l           byte              $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
map_off_h           byte              $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07
map_vis_h           byte              >Visits,>Visits,>Visits,>Visits,>Visits,>Visits,>Visits,>Visits+1,>Visits+1,>Visits+1,>Visits+1,>Visits+1,>Visits+1,>Visits+2,>Visits+2,>Visits+2,>Visits+2,>Visits+2,>Visits+2,>Visits+2,>Visits+3,>Visits+3,>Visits+3,>Visits+3,>Visits+3
*=$2000
STACK_X             DCB               256,0
STACK_Y             DCB               256,0
*=$2200
Visits              DCB               512,0
#endregion                    