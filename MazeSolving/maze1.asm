// maze solving example
// for win2c64 by Aart Bik
// https://www.aartbik.com/

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
maze:  
       .text "0000000000000000000000000000000000000000"
       .text "0- 0                                   0"
       .text "00 000000000000000000 000000000000000000"
       .text "0  0    0 0     0   0 0                0"
       .text "0    0    0  0  0   0 0 0000000 00000000"
       .text "0 000000000  0 00 0 0 0 0       0      0"
       .text "0 0   0 0 0  0 0  0 0 0 0 0000000  000 0"
       .text "0   0        0    0 0   0 0        0 0 0"
       .text "0 0000000000000 000000000 0 00 000 0 0 0"
       .text "0      0      0         0 0 0  0 0 0 0 0"
       .text "0 0000 000 00000000 00000 0 00 0 0 0 0 0"
       .text "0 0  0 0    0 0     0   0 0 0  0 0 0 0 0"
       .text "0    0    0   00000 0 0 0 0 0  0   0 0 0"
       .text "000000000000      0 0 0 0 0 0000 0 0 0 0"
       .text "0            0000 0 0 0 0   0  0 0 0 0 0"
       .text "0 0000 0000000  0 0 0 0 000 00 0 0 0 0 0"
       .text "0 0  0 0     0 00 0   0 0   0    0+0   0"
       .text "0    0    0  0    0 0 0 0000000 00000000"
       .text "0 000000000  00000000 0 0       0      0"
       .text "0 0  0    0         00000 000 0000 0 0 0"
       .text "0 0     0    0  0   0   0   0 0    000 0"
       .text "0000 0 00 0000 00 00000 0 0 0    0   0 0"
       .text "0  0 0 0   0 0  0 0   0 00000000000000 0"
       .text "0    0 0   0    0   0                  0"
       .text "0000000000000000000000000000000000000000"
       .byte 00

//
// zero page vectors
//
.label mazel   = $fb
.label mazeh   = mazel + 1
.label screenl = $fd
.label screenh = screenl + 1
.label colorl  = $8b
.label colorh  = colorl + 1
.label found   = $8d

//
// commodore 64 stuff
//
.label screen = $0400
.label color  = $d800

//
// reset found and transfer maze into screen
//
main: lda #0
      sta found
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
loop: lda (mazel),y
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
find: lda #<screen
      sta screenl
      lda #>screen
      sta screenh
      ldy #0
scan: lda (screenl),y
      cmp #'-'
      beq goeast
      inc screenl
      bne scan
      inc screenh
      jmp scan
//
// the search method
//
search:ldy #0
       lda (screenl), y
       cmp #'+'
       bne nogoal
       lda #1
       sta found
       rts        // found
//
// still not at goal
//
nogoal:cmp #' '
       beq empty
       rts           // dead end
//
// empty path found, extend path
//
empty: lda #'*'
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
goeast: inc screenl
       bne noinc1
       inc screenh
noinc1: jsr search
       lda screenl
       bne nodec1
       dec screenh
nodec1: dec screenl
       lda found
       beq gosouth
       rts
//
// recursively search south
//
gosouth: clc
        lda screenl
        adc #40
        sta screenl
        lda screenh
        adc #0
        sta screenh
        jsr search
        sec
        lda screenl
        sbc #40
        sta screenl
        lda screenh
        sbc #0
        sta screenh
        lda found
        beq gowest
        rts
//
// recursively search west
//
gowest: lda screenl
       bne nodec2
       dec screenh
nodec2: dec screenl
       jsr search
       inc screenl
       bne noinc2
       inc screenh
noinc2: lda found
       beq gonorth
       rts
//
// recursively search north
//
gonorth: sec
        lda screenl
        sbc #40
        sta screenl
        lda screenh
        sbc #0
        sta screenh
        jsr search
        clc
        lda screenl
        adc #40
        sta screenl
        lda screenh
        adc #0
        sta screenh
        lda found
        beq deadend
        rts
//
// we could put a SPACE back and this position and explore the paths
// through here again later// although this will work, it is more efficient
// to mark this simply as a dead end
//
deadend: ldy #0
        lda #'.'
        sta (screenl), y
        lda screenl
        sta colorl
        lda screenh
        clc
        adc #$d4
        sta colorh
        lda #14
        sta (colorl), y
        rts