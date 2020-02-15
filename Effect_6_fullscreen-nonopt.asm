;**********************
;* Gray Defender
;* 02/12/2020
;* BORDER EFFECTS Demo
;* Full screen colors everywhere 
;* non-optimized version
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
@master_loop   jsr MOVE_ALL
               jmp            @master_loop
MOVE_ALL
               inc            Current_Effect; Loop through all effects
               lda            Current_Effect;
               cmp            Total_Effects;
               bne            MOVE_ONCE ;
               lda            #0        ;
               sta            Current_Effect; Start Over
;*******************************************
MOVE_ONCE

               ldx            Current_Effect
               inc            effect_bgcol,x
;*** Limit Colors
               lda            effect_bgcol,x
               cmp            #7        
               bcc            @cont
               lda            #3       
               sta            effect_bgcol,x             
;*****************
@cont                  
               lda            effect_bgcol,x
               jsr            Place_Color1
               jsr            CHECK_XY  ; Adjust XY Coordinates
               rts
;*******************************************
delay
               txa
               pha
               tya
               pha
               ldx            #5
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
pokecoloraxy               
               sta            @char+1   ; Save character to poke
               lda            map_off_l,y; Load map low byte into $fb
               sta            @screen+1
               lda            map_off_h,y; Load map high byte into $fc
               sta            @screen+2
@char          lda            #$00               
@screen        sta            $d800,x              ; Store result in screen memory
               rts
;*******************************************
Place_Color1
               sta            @ch_color1+1    ; Store chacter to poke
               ldx            Current_Effect  ; Load Y position into
               lda            effect_cury,x   ; Y Register
               tay                            ; 
               ldx            Current_Effect  ; Load X Position into
               lda            effect_curx,x   ; X Register
               tax                            ; 
@ch_color1     lda            #3              ;
               jsr            pokecoloraxy    ; Poke A into pos x,y
               rts
;*******************************************
CHECK_XY
               ldx            Current_Effect
               lda            horizontal,x
               beq            @horizontal
;*******************************************
@vertical
               lda            effect_updown,x
               bne            @up
@down        
               inc            effect_cury,x
               lda            effect_cury,x
               cmp            start_ymax,x
               bne            @exit       
               lda            #0
               sta            horizontal,x; Switch to horizontal
               lda            #1
               sta            effect_updown,x; Switch to up
               rts

@up          
               dec            effect_cury,x
               lda            effect_cury,x
               cmp            start_ymin,x
               bne            @exit
               lda            #0
               sta            horizontal,x; Switch to horizontal
               sta            effect_updown,x; Switch to down
@exit          rts
;*******************************************
@horizontal  
               lda            effect_dir,x
               bne            @right    
               
@left        
               dec            effect_curx,x
               lda            effect_curx,x
               cmp            start_xmin,x
               bne            @exit1
               lda            #1
               sta            horizontal,x; Switch to vertical
               sta            effect_dir,x; Right for when horiz
@exit1         rts
;*******************************************
@right       
               inc            effect_curx,x
               lda            effect_curx,x
               cmp            start_xmax,x
               bne            @rts
               lda            #1
               sta            horizontal,x; Switch to vertical
               lda            #0        ; left for when horiz
               sta            effect_dir,x
@rts           rts
;*******************************************
;              VARIABLES
;*******************************************
start_xmin     byte           00,01,02,03,04,05,06,07,08,09,10,11,10
start_ymin     byte           00,01,02,03,04,05,06,07,08,09,10,11,10
start_xmax     byte           39,38,37,36,35,34,33,32,31,30,29,28,27
start_ymax     byte           24,23,22,21,20,19,18,17,16,15,14,13,12
horizontal     byte           00,00,00,00,00,00,00,00,00,00,00,00,00  ; 00= Horiz 01= Vertical
effect_dir     byte           00,01,01,00,01,00,01,00,01,00,01,00,01  ; 00 = left  01 = Right
effect_updown  byte           00,00,00,00,00,00,00,00,00,00,00,00,00  ; 00=Down 01=Up
effect_curx    byte           15,15,20,20,15,16,17,18,15,16,17,12,10  ; Current xmin of effect
effect_cury    byte           00,01,02,03,04,05,06,07,08,09,10,11,11  ; Current ymin of effect
effect_fgcol   byte           00,00,00,02,08,00,10,11,01,03,04,05,05  ; effect one front color
effect_bgcol   byte           00,00,00,00,05,01,07,08,14,07,16,08,08  ; effect one back color
Total_Effects  byte           13            ; Maximum effects in play
Current_Effect byte           00            ; Current effect being worked on
map_off_l      byte           $00,$28,$50,$78,$A0,$C8,$F0,$18,$40,$68,$90,$b8,$E0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
map_off_h      byte           $D8,$D8,$D8,$D8,$D8,$D8,$D8,$D9,$D9,$D9,$D9,$D9,$D9,$DA,$DA,$DA,$DA,$DA,$DA,$DA,$DB,$DB,$DB,$DB,$DB