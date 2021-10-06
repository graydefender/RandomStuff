.label f1 = $18            // Holds fib[n] ; $18 is initially zero. $18 is also the CLC opcode
* = $4e                    // Start address for the program
main:
    lax.z f1               // Load fib[n-1] into X and A
    adc.z f0: #1           // Calculate fib[n]=fib[n-2]+fib[n-1]. Immediate value holds fib[n-2]. Carry holds bit 9.
    stx.z f0               // Set fib[n-2] to fib[n-1] for the next round
    tax                    // X is fib[n]
    sta.z clear_carry: f1  // Set fib[n-1] to fib[n] for the next round. The operand is a hidden CLC instruction.
render:
    lda.z f1               // Load fib[n].
    sta colors: $d7ff,y    // Store in color ram (initial Y-value is $01)
    lda symbol: #$51       // Char-value to store on screen. Modified on for each round. 
    sta screen: $03ff,y    // Store on screen (initial Y-value is $01)
    iny                    // Increase cursor lo-byte
    bne !+                 // Do we need to increase cursor hi-byte?
    inc.z screen+1         // Increase screen cursor hi-byte
    inc.z colors+1         // Increase color cursor hi-byte. The render loop partially overwrites itself when the color cursor crosses $0000. These modifications are luckily benign.                             
    beq *                  // Are we all done? We are done when the color cursor hi-byte overflows to $00
!:
    dex                    // Are we done rendering fib[n] chars?
    bne render
    bcs clear_carry        // If the 9th bit is set we render 256 extra chars. X is already 0. 
    eor #($51^$20)         // Flip the drawing char between space ($20) and filled circle ($51). A already holds the current char-value.
    sta.z symbol
    bne main               // Calculate the next fibonacci number in the sequence. Also the entry point of the program when CHRGET is called after the load. Z is clear on the initial CHRGET call.