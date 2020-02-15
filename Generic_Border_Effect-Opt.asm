;**********************
;* Gray Defender
;* 02/12/2020
;* Box color display 
;* engine - Optimized a little
;* Bug - Does not work right if box is one character wide
;**********************
*=$2000
;******************************************************
; CLEAR SCREEN
;******************************************************
               lda            #42
               ldx            #0
@clr_loop      sta            $400,x
               sta            $500,x
               sta            $600,x
               sta            $700,x
               dex
               bne            @clr_loop
;*******************************************
master_loop  
               inc            Current_Effect; Loop through all effects
               lda            Current_Effect;
               cmp            Total_Effects;
               bne            @MOVE_EFFECT
               lda            #0        ;
               sta            Current_Effect; Start Over
;*******************************************
@MOVE_EFFECT
               
               ldx            Current_Effect
               lda            effect_fgcol,x              
               Place_Color1  
               jsr            delay
               ldx            Current_Effect
               lda            effect_bgcol,x
               Place_Color1        
              
;*******************************************
               ldx            Current_Effect
               lda            horizontal,x
               beq            HORIZ
;*******************************************
Vertical
               lda            effect_updown,x
               bne            UP
DOWN           inc            effect_cury,x
               ChkDirection   effect_cury,start_ymax,#0,#1,effect_updown
UP
               dec            effect_cury,x
               ChkDirection   effect_cury,start_ymin,#0,#0,effect_updown

HORIZ
               lda            effect_dir,x
               bne            RIGHT
LEFT
               inc    effect_fgcol,x        
               dec            effect_curx,x
               
               ChkDirection   effect_curx,start_xmin,#1,#1,effect_dir 

RIGHT
               inc            effect_curx,x
               
               ChkDirection   effect_curx,start_xmax,#1,#0,effect_dir                

defm           ChkDirection     
               lda            /1,x
               cmp            /2,x
               bne            @exit
               lda            /3
               sta            horizontal,x; Switch to horizontal
               lda            /4
               sta            /5,x      ; Switch to down
               
@exit          jmp            master_loop
               endm               
;*******************************************
delay
               txa
               pha
               tya
               pha
               ldx            #50
@lp1           ldy             #10
@lp2           dey
               bne            @lp2
               dex
               bne            @lp1
               pla
               tay
               pla
               tax
               rts
;*******************************************
defm           Place_Color1
               sta            @ch_color1+1     ; Grab Y value
               ldx            Current_Effect   ;
               lda            effect_cury,x    ;
               tay
               ldx            Current_Effect   ; Grab X value
               lda            effect_curx,x    ;
               tax                             ;
               lda            map_off_l,y      ; Load low byte pos of color 
               sta            @screen+1        ; on the screen
               lda            map_off_h,y      ; Load high byte pos of color
               sta            @screen+2        ; on the screen
@ch_color1     lda            #$00             ; Load color to store
@screen        sta            $d800,x          ; Store color on screen
               endm

;*******************************************
;              VARIABLES
;*******************************************
start_xmin     byte           10,05,20,10
start_ymin     byte           01,03,05,02
start_xmax     byte           30,10,30,38
start_ymax     byte           14,10,15,23
horizontal     byte           00,00,00,00   ; 00= Horiz 01= Vertical
effect_dir     byte           00,01,01,00   ; 00 = left  01 = Right
effect_updown  byte           00,00,00,00   ; 00=Down 01=Up
effect_curx    byte           15,05,20,20   ; Current xmin of effect
effect_cury    byte           01,03,05,02   ; Current ymin of effect
effect_fgcol   byte           00,03,15,07   ; effect one front color
effect_bgcol   byte           01,02,04,00   ; effect one back color
Total_Effects  byte           04            ; Maximum effects in play
Current_Effect byte           00            ; Current effect being worked on
map_off_l      byte           $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
map_off_h      byte           $D8,$D8,$D8,$D8,$D8,$D8,$D8,$D9,$D9,$D9,$D9,$D9,$D9,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DB,$DB,$DB,$DB,$DB