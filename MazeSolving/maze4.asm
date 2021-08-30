// maze solving example
// for win2c64 by Aart Bik
// https://www.aartbik.com/
//** Gray Defender 08/29/2021
//** Added Macros
//** Integrated with random maze gen

BasicUpstart2(BEGIN)
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


maze:
       // .text "0000000000000000000000000000000000000000"
       // .text "0- 0                                   0"
       // .text "00 000000 00000000000 000000000000000000"
       // .text "0  000  0 0     0   0 0                0"
       // .text "0         0  0  0   0 0 0000000 00000000"
       // .text "0 000000000  0 00 0 0 0 0       0      0"
       // .text "0 0   0 0 0  0 0  0 0 0 0 0000000  000 0"
       // .text "0   0        0    0 0   0 0        0 0 0"
       // .text "0 0000000000000 000000000 0 00 000 0 0 0"
       // .text "0      0      0         0 0 0  0 0 0 0 0"
       // .text "0 0000 000 00000000 00000 0 00 0 0 0 0 0"
       // .text "0 0  0 0    0 0     0   0 0 0  0 0 0 0 0"
       // .text "0    0    0   00000 0 0 0 0 0+ 0   0 0 0"
       // .text "000000000000      0 0 0 0 0 0000 0 0 0 0"
       // .text "0            0000 0 0 0 0   0  0 0 0 0 0"
       // .text "0 0000 0000000  0 0 0 0 000 00 0 0 0 0 0"
       // .text "0 0  0 0     0 00 0   0 0   0    0 0   0"
       // .text "0    0    0  0    0 0 0 0000000 00000000"
       // .text "0 000000000  00000000 0 0       0      0"
       // .text "0 0  0    0         00000 000 0000 0 0 0"
       // .text "0 0     0    0  0   0   0   0 0    000 0"
       // .text "0000 0 00 0000 00 00000 0 0 0    0   0 0"
       // .text "0  0 0 0   0 0  0 0   0 000 000000000000"
       // .text "0    0 0   0    0   0                  0"
       // .text "0000000000000000000000000000000000000000"
       // .byte 0

//
// commodore 64 stuff
//
.label screenram = $0400
.label color  = $d800

//
// zero page vectors
//

.label mazel = $f7
.label mazeh   = mazel + 1
.label screenraml = mazel + 2
.label screenramh = screenraml + 1
.label colorl  = mazel + 4
.label colorh  = colorl + 1
.label stackl  = mazel + 6
.label stackh  = mazel + 7
.label maze_solved   = mazel + 9

//
// reset maze_solved and transfer maze into screenram
//
BEGIN:
 		jsr main
	
!: 		lda $c5
		cmp #$40
 		beq !-
 		jmp BEGIN

main:
		jsr DRAW_RAND_MAZE
		lda #'-'
		sta $429
		lda #'+'
		sta $7bd		

        lda #0
        sta maze_solved
        lda #<maze
        sta mazel
        lda #>maze
        sta mazeh
        lda #<screenram
        sta screenraml
        lda #>screenram
        sta screenramh
        lda #<color
        sta colorl
        lda #>color
        sta colorh
        lda #$00         // start
        sta stackl       // of
        lda #$c0         // free
        sta stackh       // RAM      
   //     ldy #0
// loop:   lda (mazel),y
//         beq find
//         sta (screenraml),y
//         lda #14
//         sta (colorl),y
//         iny
//         bne loop
//         inc mazeh
//         inc screenramh
//         inc colorh
//         jmp loop
//
// find - in the maze and start search from there
//
find:

        lda #<screenram
        sta screenraml
        lda #>screenram
        sta screenramh
        ldy #0
scan:   lda (screenraml),y
        cmp #'-'
        beq goeast
        inc screenraml
        bne scan
        inc screenramh
        jmp scan
search:
        ldy #0
        lda (screenraml), y
        cmp #'+'
        beq Set_Solved_Flag
        cmp #' '
        beq Mark_Visit
        jmp dorts      
Set_Solved_Flag:
        lda #1
        sta maze_solved        
        rts        
//
// empty path maze_solved, extend path
//
Mark_Visit:
        lda #'*'
        sta (screenraml), y
        lda screenraml
        sta colorl
        lda screenramh
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
        jsr dojsr// jsr search
        Move_West()       //Make it here then the east direction failed/ so move back west to fix

        lda maze_solved
        beq gosouth
        jmp dorts
//
// recursively search south
//
gosouth: Move_South()
        jsr dojsr// jsr search
         Move_North()

         lda maze_solved
         beq gowest
         jmp dorts
//
// recursively search west
//
gowest: 
       Move_West()
       jsr dojsr//jsr search
       Move_East()              //Make it here then the west direction failed/ so move back east to fix
      
       lda maze_solved
       beq gonorth
       jmp dorts
//
// recursively search north
//
gonorth:
        Move_North()
        jsr dojsr//jsr search
        Move_South()

        lda maze_solved
        beq deadend
        jmp dorts
//
// we could put a SPACE back and this position and explore the paths
// through here again later// although this will work, it is more efficient
// to mark this simply as a dead end
//
deadend:ldy #0
        lda #'.'
        sta (screenraml), y
        lda screenraml
        sta colorl
        lda screenramh
        clc
        adc #$d4
        sta colorh
        lda #0
        sta (colorl), y
        jmp dorts

.macro Move_East() {
        inc screenraml
        bne !+
        inc screenramh
!:        
}     

.macro Move_West() {
        lda screenraml
        bne !+
        dec screenramh
!:      dec screenraml        
}         

.macro Move_South() {
        clc
        lda screenraml
        adc #40
        sta screenraml
        lda screenramh
        adc #0
        sta screenramh
}         
.macro Move_North() {
        sec
        lda screenraml
        sbc #40
        sta screenraml
        lda screenramh
        sbc #0
        sta screenramh
}        

//
// Since the 6510 only supports 256 bytes of stack,
// using regular jsr/rts to implement recursive
// backtracking places a restriction on the maximum
// "path length". This restriction is removed by
// using free RAM to implement the stack as follows:
//     replace jsr search -> jsr dojsr
//             rts        -> jmp dorts
//
dojsr:  ldy #$00         // record rta
        pla              //
        sta (stackl),y   //
        inc stackl       //
        bne noincp1      //
        inc stackh       //
noincp1:pla              //
        sta (stackl),y   //
        inc stackl       //
        bne noincp2      //
        inc stackh       //
noincp2:jmp search       //
                         //
dorts:  ldy #0           // restore rta
        lda stackl       //
        bne nodecp1      //
        dec stackh       //
nodecp1:dec stackl       //
        lda (stackl),y   //
        pha              //
        lda stackl       //
        bne nodecp2      //
        dec stackh       //
nodecp2:dec stackl       //
        lda (stackl),y   //
        pha              //
        rts              //

#import "mazegenerate.asm"