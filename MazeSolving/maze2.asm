// maze solving example
// for win2c64 by Aart Bik
// https://www.aartbik.com/
//
//** Gray Defender 08/29/2021
//** Added Macros
BasicUpstart2(main)
//
// define the maze
//   place - at start
//   place + at goal
//   place 0 at walls
// program will find path - -> + (if it exists)
//
// NOTE: the recursive backtracking implementation used in
//       this example combined with the relatively small stack
//       of the Commodore 64 places a restriction on the maximum
//       "path length"// removing this restriction is left as
//       an exercise for the reader :-)
//
*=* "maze begin"

// maze:  
//        .text "0000000000000000000000000000000000000000"
//        .text "0- 0                                   0"
//        .text "00 000000000000000000 000000000000000000"
//        .text "0  0    0 0     0   0 0                0"
//        .text "0    0    0  0  0   0 0 0000000 00000000"
//        .text "0 000000000  0 00 0 0 0 0       0      0"
//        .text "0 0   0 0 0  0 0  0 0 0 0 0000000  000 0"
//        .text "0   0        0    0 0   0 0        0 0 0"
//        .text "0 0000000000000 000000000 0 00 000 0 0 0"
//        .text "0      0      0         0 0 0  0 0 0 0 0"
//        .text "0 0000 000 00000000 00000 0 00 0 0 0 0 0"
//        .text "0 0  0 0    0 0     0   0 0 0  0 0 0 0 0"
//        .text "0    0    0   00000 0 0 0 0 0  0   0 0 0"
//        .text "000000000000      0 0 0 0 0 0000 0 0 0 0"
//        .text "0            0000 0 0 0 0   0  0 0 0 0 0"
//        .text "0 0000 0000000  0 0 0 0 000 00 0 0 0 0 0"
//        .text "0 0  0 0     0 00 0   0 0   0    0+0   0"
//        .text "0    0    0  0    0 0 0 0000000 00000000"
//        .text "0 000000000  00000000 0 0       0      0"
//        .text "0 0  0    0         00000 000 0000 0 0 0"
//        .text "0 0     0    0  0   0   0   0 0    000 0"
//        .text "0000 0 00 0000 00 00000 0 0 0    0   0 0"
//        .text "0  0 0 0   0 0  0 0   0 00000000000000 0"
//        .text "0    0 0   0    0   0                  0"
//        .text "0000000000000000000000000000000000000000"
//        .byte 00
//Broken
maze:
       .text "0000000000000000000000000000000000000000"
       .text "0- 0                                   0"
       .text "00 000000 00000000000 000000000000000000"
       .text "0  000  0 0     0   0 0                0"
       .text "0         0  0  0   0 0 0000000 00000000"
       .text "0 000000000  0 00 0 0 0 0       0      0"
       .text "0 0   0 0 0  0 0  0 0 0 0 0000000  000 0"
       .text "0   0        0    0 0   0 0        0 0 0"
       .text "0 0000000000000 000000000 0 00 000 0 0 0"
       .text "0      0      0         0 0 0  0 0 0 0 0"
       .text "0 0000 000 00000000 00000 0 00 0 0 0 0 0"
       .text "0 0  0 0    0 0     0   0 0 0  0 0 0 0 0"
       .text "0    0    0   00000 0 0 0 0 0+ 0   0 0 0"
       .text "000000000000      0 0 0 0 0 0000 0 0 0 0"
       .text "0            0000 0 0 0 0   0  0 0 0 0 0"
       .text "0 0000 0000000  0 0 0 0 000 00 0 0 0 0 0"
       .text "0 0  0 0     0 00 0   0 0   0    0 0   0"
       .text "0    0    0  0    0 0 0 0000000 00000000"
       .text "0 000000000  00000000 0 0       0      0"
       .text "0 0  0    0         00000 000 0000 0 0 0"
       .text "0 0     0    0  0   0   0   0 0    000 0"
       .text "0000 0 00 0000 00 00000 0 0 0    0   0 0"
       .text "0  0 0 0   0 0  0 0   0 000 000000000000"
       .text "0    0 0   0    0   0                  0"
       .text "0000000000000000000000000000000000000000"
       .byte 0

//
// commodore 64 stuff
//
.label screen = $0400
.label color  = $d800

//
// zero page vectors
//

.label mazel = $fb
.label mazeh   = mazel + 1
.label screenl = $fd
.label screenh = screenl + 1
.label colorl  = $8b
.label colorh  = colorl + 1
.label maze_solved   = $8d


//
// reset maze_solved and transfer maze into screen
//
main:
        lda #0
        sta maze_solved
        lda #<maze
        sta mazel
        lda #>maze
        sta mazeh
        lda #<screen
        sta screenl
        lda #>screen
        sta screenh
        lda #<color
        sta colorl
        lda #>color
        sta colorh
        ldy #0
loop:   lda (mazel),y
        beq find
        sta (screenl),y
        lda #14
        sta (colorl),y
        iny
        bne loop
        inc mazeh
        inc screenh
        inc colorh
        jmp loop
//
// find - in the maze and start search from there
//
find:
        lda #<screen
        sta screenl
        lda #>screen
        sta screenh
        ldy #0
scan:   lda (screenl),y
        cmp #'-'
        beq goeast
        inc screenl
        bne scan
        inc screenh
        jmp scan

search:
        ldy #0
        lda (screenl), y
        cmp #'+'
        beq Set_Solved_Flag
        cmp #' '
        beq Mark_Visit
        rts                             // Return back==search fail or not valid move 
Set_Solved_Flag:
        lda #1
        sta maze_solved        
        rts                             // Set maze completion flag
//
// empty path maze_solved, extend path
//
Mark_Visit:
        lda #'*'
        sta (screenl), y
        lda screenl
        sta colorl
        lda screenh
        clc
        adc #$d4
        sta colorh
        lda #1
        sta (colorl), y
//
// the following introduces an artificial delay to follow the recursion//
// remove it to get an appreciation of the speed of machine code!
//
        ldy #10
        ldx #0
delay:  inx
        bne delay
        dey
        bne delay
//
// recursively search east
//

goeast: Move_East()
        jsr search
        Move_West()       //Make it here then the east direction failed/ so move back west to fix

        lda maze_solved
        beq gosouth
        rts
//
// recursively search south
//
gosouth: Move_South()
        jsr search
        Move_North()

        lda maze_solved
        beq gowest
        rts
//
// recursively search west
//
gowest: 
        Move_West()
        jsr search
        Move_East()              //Make it here then the west direction failed/ so move back east to fix
      
        lda maze_solved
        beq gonorth
        rts
//
// recursively search north
//
gonorth:
        Move_North()
        jsr search
        Move_South()

        lda maze_solved
        beq deadend
        rts
//
// we could put a SPACE back and this position and explore the paths
// through here again later// although this will work, it is more efficient
// to mark this simply as a dead end
//
deadend:ldy #0
        lda #'.'
        sta (screenl), y
        lda screenl
        sta colorl
        lda screenh
        clc
        adc #$d4
        sta colorh
        lda #0
        sta (colorl), y
        rts

.macro Move_East() {
        inc screenl
        bne !+
        inc screenh
!:        
}     

.macro Move_West() {
        lda screenl
        bne !+
        dec screenh
!:      dec screenl        
}         

.macro Move_South() {
        clc
        lda screenl
        adc #40
        sta screenl
        lda screenh
        adc #0
        sta screenh
}         
.macro Move_North() {
        sec
        lda screenl
        sbc #40
        sta screenl
        lda screenh
        sbc #0
        sta screenh
}        