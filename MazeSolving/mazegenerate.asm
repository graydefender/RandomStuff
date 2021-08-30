//************************************************
//** Gray Defender 8/29/2021
//** from code extracted from Amazingrace project
//** Draw Maze - Recursive backtracking algorithm
//** Adapted from:
//   "https://rosettacode.org/"
//************************************************
.const MAZE_VISIT_BIT           = %00000001             // Visits buffer was combined with $400 using this bit flip
.const Const_Space              = 32
.const Const_WALL               = 160
.const ScreenRam                = $400
.const ColorRam                 = $d800
.const Visits                   = ScreenRam
.const Const_MAZE_WIDTH         = 19                    //  Valid values are 3 up to 20
.const Const_MAZE_HEIGHT        = 12                    //  Default maze size

*=$2000
DRAW_RAND_MAZE:
                    jsr       INIT_ALL_VARIABLES   
                    jsr       DRAW_MAZE
                    rts
DRAW_MAZE: {
//*****************************************************
//** This section starts the maze drawing by
//** placing the first MAZE character on the screen
//** then randomly determines whether to draw the second
//** character on the screen when the program starts
//*****************************************************                  

                    ADD(x,x,screenx)
                    ADD(y,y,screeny)
                    PokeWallaxy(screenx,screeny) // Draw char on screen
                    lda            #2             // Skip this one randomly 50% OF THE TIME
                    sta            RND_VALUE
                    jsr            RAND
                    beq            !+
                    dey
                    sty            screeny                                             
                    PokeWallaxy(screenx,screeny) // Draw in char on screen on below first one
!:
//*****************************************************
//** DRAW_MAZE_BORDER
//** DRAW BORDER AROUND THE MAZE
//** At the same time this SUB also marks the
//** entire border as having already been "visited"
//*****************************************************
//** This section draws the vert border lines
*=* "MAZE HEIGHT"
                    lda            #0
                    sta            screenx
                    ldx            MAZE_HEIGHT
bloop:              stx            screeny
                    ldy            screenx
                    jsr            Opt_Poke_Visit
                    ADD(screenx,MAZE_WIDTH,visit_left)
                    ldx            screeny
                    ldy            visit_left
                    jsr            Opt_Poke_Visit
                    ADD(MAZE_WIDTH,MAZE_WIDTH,visit_right)                    
                    ADD(MAZE_HEIGHT,screeny,border_x)
                    PokeWallaxy(screenx,screeny)
                    PokeWallaxy(visit_right,screeny)
                    PokeWallaxy(screenx,border_x)
                    PokeWallaxy(visit_right,border_x)

bdown:              ldx            screeny                   
                    dex
                    bpl            bloop     
//*****************************************************
//** Draw Horizontal lines and set border visits
//*****************************************************
                    ldx            MAZE_WIDTH 
                    dex
loop2:              stx            screenx
                    lda            #0
                    sta            screeny
                    ldx            screeny
                    ldy            screenx
                    jsr            Opt_Poke_Visit
                    lda            MAZE_HEIGHT
                    sta            screeny
                    ldx            screeny
                    ldy            screenx
                    jsr            Opt_Poke_Visit
                    lda            #0
                    sta            visit_right
                    ADD(MAZE_HEIGHT,MAZE_HEIGHT,border_y)
                    ADD(screenx,MAZE_WIDTH,visit_left)
                    PokeWallaxy(screenx,visit_right)
                    PokeWallaxy(screenx,border_y)
                    PokeWallaxy(visit_left,visit_right)
                    PokeWallaxy(visit_left,border_y)
                    ldx            screenx
                    dex
                    bpl            loop2                                     
//*****************************************************
//** push the variables x, y onto the "stack"
//*****************************************************
PUSH_STACK:         inc            visit_index
                    ldx            visit_index
                    lda            x
                    sta            STACK_X,x
                    lda            y
                    sta            STACK_Y,x
//*****************************************************
//** Represents lines 1270-1350 in maze1.bas
//*****************************************************
                    ldx            y
                    ldy            x
                    jsr            Opt_Poke_Visit
// ******* Set up x-1 , x+1 , y-1, y+1 *******
AFTER_POP:
                    lda            x
                    sta            visit_right
                    inc            visit_right
                    lda            x
                    sta            visit_left
                    dec            visit_left
                    lda            y
                    sta            visit_down
                    inc            visit_down
                    lda            y
                    sta            visit_up
                    dec            visit_up
//*****************************************************
//** Have we aleady visited up/down/left and right?
//** if so POP the stack / back track
//*****************************************************
                    ldx            y
                    ldy            visit_right
                    jsr            Optimized_Peek
                    beq            RANDOM_DIR
                    ldx            visit_down
                    ldy            x
                    jsr            Optimized_Peek
                    beq            RANDOM_DIR
                    ldx            y
                    ldy            visit_left
                    jsr            Optimized_Peek
                    beq            RANDOM_DIR
                    ldx            visit_up
                    ldy            x
                    jsr            Optimized_Peek
                    beq            RANDOM_DIR
                    bne            EXIT_and_POP_STACK
 Optimized_Peek:    jsr            peekxy                    // only want value of bit 0
                    and            #MAZE_VISIT_BIT 
                    rts
//*****************************************************
// POP variables x, y off of stack
// If no more stack left, then exit program - maze done
//*****************************************************
EXIT_and_POP_STACK:
                    ldx            visit_index
                    lda            STACK_Y,x
                    sta            y
                    lda            STACK_X,x
                    sta            x
                    dec            visit_index
                    lda            visit_index
                    bne            AFTER_POP            
                    beq            @done                      
@done:              jmp            Remove_Visits  

//*****************************************************
//** Randomly check all directions
//** If not visited, then VISIT that spot
//*****************************************************
RANDOM_DIR:         lda            #4        //** Pick random # 0-3
                    sta            RND_VALUE
rnd_loop:           jsr            RAND
                    sta            Z
                    cmp            #0        // STA above does not set zero flag so need this cmp#0
                    beq            CK_UP_ONE //** Check up one
cmp_1:              cmp            #1
                    beq            CK_DOWN_ONE//** Check down
cmp_2:              cmp            #2
                    beq            CK_LEFT_ONE//** Check left
cmp_3:              cmp            #3
                    bne            rnd_loop
//*****************************************************
//* Has Right been visited?
CK_RIGHT_ONE:
                    ldx            y
                    ldy            visit_right
                    jsr            Optimized_Peek
                    beq            Set_Right_Visit
                    bne            RANDOM_DIR

//*****************************************************
//* Has Up been visited?
CK_UP_ONE:
                    ldx            visit_up
                    ldy            x
                    jsr            Optimized_Peek
                    beq            Set_Up_Visit
                    lda            Z
                    jmp            cmp_1
//*****************************************************
//** Set visit flag on right side neighbor and poke
//** wall characters onto the screen display
//*****************************************************
Set_Right_Visit:
                    ldx            y
                    ldy            visit_right
                    jsr            Opt_Poke_Visit
                    inc            x
                    jsr            Set_Visit_SUB
                    inc            screenx
                    lda            #Const_WALL
                    jsr            samecode_visitsub
                    jmp            PUSH_STACK                    
//*****************************************************
//** Set visit flag on top (up) side neighbor and poke
//** wall characters onto the screen display
//*****************************************************
Set_Up_Visit:
                    ldx            visit_up
                    ldy            x
                    jsr            Opt_Poke_Visit
                    dec            y
                    jsr            Set_Visit_SUB
                    dec            screeny
                    lda            #Const_WALL
                    PokeWallaxy(screenx,screeny)
                    jmp            PUSH_STACK
//*****************************************************
//* Has Down been visited?
CK_DOWN_ONE:
                    ldx            visit_down
                    ldy            x
                    jsr            Optimized_Peek
                    beq            Set_Down_Visit
                    lda            Z
                    jmp            cmp_2
//*****************************************************
//* Has Left been visited?
CK_LEFT_ONE:
                    ldx            y
                    ldy            visit_left
                    jsr            Optimized_Peek
                    beq            Set_Left_Visit
                    lda            Z
                    jmp            cmp_3
//*****************************************************
//** Set visit flag on bottom (down) side neighbor and poke
//** wall characters onto the screen display
//*****************************************************
Set_Down_Visit:
                    ldx            visit_down
                    ldy            x
                    jsr            Opt_Poke_Visit
                    inc            y
                    jsr            Set_Visit_SUB
                    inc            screeny
                    PokeWallaxy(screenx,screeny)
                    jmp            PUSH_STACK

//*****************************************************
//** Set visit flag on left side neighbor and poke
//** wall characters onto the screen display
//*****************************************************
Set_Left_Visit:
                    ldx            y
                    ldy            visit_left
                    jsr            Opt_Poke_Visit
                    dec            x
                    jsr            Set_Visit_SUB
                    lda            #Const_WALL
                    dec            screenx
                    jsr            samecode_visitsub
                    jmp            PUSH_STACK

}

//***********************************************
// Random subs & variables placed here
// when trying to maximize memory below $400
//***********************************************

check_left_right:    // 23 bytes
                    ldy       Players_X,x  
                    lda       Players_Y,x  
                    tax
                    iny                            // Check for open space right side of plr
                    jsr       peekxy        // Load in character from screen   
                    cmp       #Const_Space    // is it a blank space?                
                    beq       @retback         // if so return back
                    dey                           // Check for open space left side of plr                    
                    dey
@Shared:            jsr       peekxy          // Grab character at pos x,y
                    cmp       #Const_Space  // Is it a space?
                    bne       @retback                  
@retback:           rts  

//********************************************
// After Maze drawn swap out visit characters
// To desired char. visit chars are in
// this case either $a1 or $21. The visits
// show up on the top half of screen
// No Inputs/Outputs
//********************************************
Remove_Visits:  {
                         ldy       #0             
!:
                         lda       ScreenRam,y       
                         jsr       RM_Vis_SUB     
                         sta       ScreenRam,y    
                         lda       ScreenRam+250,y
                         jsr       RM_Vis_SUB 
                         sta       ScreenRam+250,y
                         iny                                             // Cannot do this backwards with bpl :(
                         cpy       #250           
                         bne       !-
!:                       rts
RM_Vis_SUB:
                         cmp       #[Const_WALL+1]  // if visit set wall could be 160+1
                         beq       @iswall        
                         cmp       #[Const_Space+1] // if visit was set then bit 0 could be set 32+1
                         bne       !+
                         lda       #Const_Space            
                         rts
@iswall:           
                         lda       #Const_WALL
!:                       rts
}

//*****************************************************
// Grab value of screen position located at x,y
// Store result in accumulator
// Inputs :  X, Y  : X is horiz pos, y is vert pos
// returns:  Acc   = Character at pos x,y
//*****************************************************
peekxy:            // 13 bytes
                                        lda       scr_off_l,x    // Load scr low .byte into $fb
                                        sta       $fb            
                                        lda       scr_off_h,x    // Load scr hig .byte into $fc
                                        sta       $fc            
                                        lda       ($fb),y        // Load result into acc
                                        rts   
scr_off_h:          .fill      25,>ScreenRam+[i*40]   
scr_off_l:          .fill      25,<ScreenRam+[i*40]     
//*****************************************************
// RANDOM Number SUB
// Inputs: RND_VALUE ZP variable | RND_VALUE is high
// range to select rand number from
// Outputs: Acc - Random value stored there
//*****************************************************
RAND:               // 8 bytes                    
                    lda            $D41B            // get random value from 0-255
                    cmp            RND_VALUE        // narrow random result down                                                       
                    bcs            RAND             // BCS more likely in this program so first
                    rts 
//*****************************************************
// Set a visit sub
// No Inputs / Outputs
//*****************************************************                    
Set_Visit_SUB:       // 22 bytes
                    ADD(x,x,screenx)
                    ADD(y,y,screeny)
samecode_visitsub:  PokeWallaxy(screenx,screeny)
                    rts 
//***************************************************
// Saves a visit at x,y in screen memory
// Inputs : X,Y
// Outputs: none
//***************************************************
Opt_Poke_Visit:    
                    jsr peekxy
                    ora            #MAZE_VISIT_BIT
                    sta            ($fb),y   // Store result in screen memory
                    rts

pokeColsxy:        
                    lda       scr_off_l,x    // Load scr low .byte into $fb
                    sta       screen+1       
                    sta       colpos+1       
                    clc
                    lda       scr_off_h,x    // Load scr high .byte into $fc
                    sta       screen+2       
                    adc       #[>ColorRam]-4 // Make it $d4
                    sta       colpos+2       
                    lda       Char: #$00
screen:             sta       $fff,y         // Store result in screen memory
                    lda       CH_Color: #$FF // at pos x,y
colpos:             sta       $beef,y        // sel mod     
                    rts
// *********************************************************
// This function, for the vertical moving player will
// check for spaces to the left or right hand side 
// of current player and stop the auto movement at the gap
// Inputs : X,Y
// Outputs: none
// *********************************************************                    
PokeWall_Sub:     
                    lda            scr_off_l,x // Load scr low byte into $fd
                    sta            $fd
                    lda            scr_off_h,x // Load scr high byte into $fd
                    sta            $fe
                    lda            ($fd),y
                    and            #MAZE_VISIT_BIT
                    ora            #Const_WALL
                    sta            ($fd),y   // Store result in screen memory
                    rts  
//*****************************************************
// Init random generator 
// No Inputs / Outputs
//*****************************************************
Init_Random: 
                    lda            #$FF      // maximum frequency value
                    sta            $D40E     // voice 3 frequency low byte
                    sta            $D40F     // voice 3 frequency high byte
                    lda            #$80      // noise SIRENform, gate bit off
                    sta            $D412     // voice 3 control register
                    rts
//*****************************************************
//Macro: Add first two parameters and store in 3rd
//Inputs:  Param1, Param 2
//Outputs: result stored in third param 
//*****************************************************
.macro ADD(value1,value2,result) {
                                
                    clc
                    lda            value1
                    adc            value2
                    sta            result

}
//*****************************************************
// Poke a Wall character on the screen at position
// x,y taking into consideration, that space on the
// screen may also have a visit stored there.. since
// screen and visits are sharing the same memory space
//Inputs:  x,y
//Outputs: none
//*****************************************************
.macro PokeWallaxy(xpos,ypos) {
                    ldx          ypos             // X value
                    ldy          xpos             // Y value
                    jsr          PokeWall_Sub
}

INIT_ALL_VARIABLES:
                    jsr       Init_Random                    // Need to reinit due to sound routine breaking random
                    lda       #Const_MAZE_WIDTH
                    sta       MAZE_WIDTH     
                    lda       #Const_MAZE_HEIGHT
                    sta       MAZE_HEIGHT  
                    ldy       #2
                    sty       RND_VALUE           // 2 stored
                    sty       x              
                    sty       y              
                    ldy       #0                                    
@topofloop:         lda       #3               // Clear the screen
                    sta       ColorRam,y          // Set char color
                    sta       [ColorRam+250],y 
                    sta       [ColorRam+500],y 
                    sta       [ColorRam+750],y 
                    lda       #Const_Space           
                    sta       ScreenRam,y    
                    sta       [ScreenRam+250],y
                    sta       [ScreenRam+500],y
                    sta       [ScreenRam+750],y
                    iny
                    cpy       #250         
                    bne       @topofloop                            
                    rts

RND_VALUE:              .byte 00
visit_up:               .byte 00
visit_down:             .byte 00
visit_index:            .byte 00                                                            // Used while drawing maze
text_index:             .byte 00                    // text_index only used on Title screen
Z:                      .byte 00
y:                      .byte 00
x:                      .byte 00
MAZE_WIDTH:             .byte 00                    //  Valid values are 3 up to 20
MAZE_HEIGHT:            .byte 00                    //  Default maze size
ON_Title_Screen:        .byte 00                    // Only used to draw in GRD in title scr
visit_left:             .byte 00
ORIG_X:                 .byte 00
visit_right:            .byte 00
ORIG_Y:                 .byte 00
TEMPY:                  .byte 00
Players_X:              .byte 00,00,00,00           // 4 bytes
Players_Y:              .byte 00,00,00,00           // 4 bytes

screenx:                .byte 00
screeny:                .byte 00
border_x:               .byte 00
border_y:               .byte 00
.align $100
STACK_X:           .fill     165,0   // These need to be aligned on $100
STACK_Y:           .fill     165,0   // to save space coding and otherwise
