; *
; * BLACKBOARD 
; *
*=$8000
COLOR               = $10
BASE                = $2000
SCROLY              = $d011
VMCSB               = $d018
COLMAP              = $400
; *
HMAX                = 320
VMAX                = 200
HMID                = 160
VMID                = 100
; *
SCRLEN              = 8000
MAPLEN              = 1000
TEMPA               = $FB
TEMPB               = TEMPA+2
; *
TABPTR              = TEMPA
TABSIZ              = $9000
; *
HPSN                = TABSIZ+2
VPSN                = HPSN+2
CHAR                = VPSN+1
ROW                 = CHAR+1
LINE                = ROW+1
xBYTE               = LINE+1
BITT                = xBYTE+2
MPRL                = BITT+1
MPRH                = MPRL+1
MPDL                = MPRH+1
MPDH                = MPDL+1
PRODL               = MPDH+1
PRODH               = PRODL+1                    
; * 
FILVAL              = PRODH+1
JSV                 = FILVAL+1
; *                    
                    jmp               START             
; *                    
BLKFIL              lda               FILVAL
                    ldx               TABSIZ+1          
                    BEQ               PARTPG            
                    ldy               #0                
FULLPG              sta               (TABPTR),y
                    iny
                    bne               FULLPG            
                    inc               TABPTR+1          
                    dex
                    bne               FULLPG            
PARTPG              ldx               TABSIZ
                    beq               FINI              
                    LDY               #0                
PARTLP              STA               (TABPTR),y
                    iny
                    dex
                    bne               PARTLP            
FINI                rts
; *                     
; * 16-Bit Multiplication Routine
; *
MULT16              lda               #0
                    sta               PRODL             
                    sta               PRODH             
                    ldx               #17               
                    clc
MULT                ROR               PRODH
                    ROR               PRODL             
                    ROR               MPRH              
                    ROR               MPRL              
                    bcc               CTDOWN            
                    clc
                    lda               MPDL              
                    adc               PRODL             
                    sta               PRODL             
                    lda               MPDH              
                    adc               PRODH             
                    sta               PRODH             
CTDOWN              dex
                    bne               MULT              
                    rts
; *
; * PLOT Routine
; *
PLOT                lda               VPSN
                    lsr               A                 
                    lsr               A
                    lsr               A
                    sta               ROW
; *
; * Char = HPSN/8 (16-bit divide)               
; *
                    lda               HPSN              
                    sta               TEMPA             
                    lda               HPSN+1            
                    sta               TEMPA+1           
                    ldx               #3                
DLOOP               lsr               TEMPA+1
                    ror               TEMPA             
                    dex
                    bne               DLOOP             
                    lda               TEMPA             
                    sta               CHAR
; *
; *              
                    lda               VPSN              
                    and               #7                
                    sta               LINE  
; *
; * BITT=7-(HPSN and 7)            
; *
                    lda               HPSN              
                    and               #7                
                    sta               BITT              
                    sec
                    lda               #7                
                    sbc               BITT              
                    sta               BITT 
; * BYTE=Base+row*hmax+8*char+LINE             
                    lda               ROW               
                    sta               MPRL              
                    lda               #0                
                    sta               MPRH              
                    lda               #<HMAX            
                    sta               MPDL              
                    lda               #>HMAX            
                    sta               MPDH              
                    jsr               MULT16            
                    lda               MPRL              
                    sta               TEMPA             
                    lda               MPRL+1            
                    sta               TEMPA+1           
;* ADD product to base                    
                    clc
                    lda               #<BASE            
                    adc               TEMPA             
                    sta               TEMPA             
                    lda               #>BASE            
                    adc               TEMPA+1           
                    sta               TEMPA+1           
; * MULTIPLY 8 * char                    
                    lda               #8                
                    sta               MPRL              
                    lda               #0                
                    sta               MPRH              
                    lda               CHAR              
                    sta               MPDL              
                    lda               #0                
                    sta               MPDH              
                    jsr               MULT16            
                    lda               MPRL              
                    sta               TEMPB             
                    lda               MPRH              
                    sta               TEMPB+1           
; ADD LINE                    
                    clc
                    lda               TEMPB             
                    adc               LINE              
                    sta               TEMPB             
                    lda               TEMPB+1           
                    adc               #0                 
                    sta               TEMPB+1           
; BYTE+TEMPA+TEMPB
                    clc
                    lda               TEMPA             
                    adc               TEMPB             
                    sta               TEMPB             
                    lda               TEMPA+1           
                    adc               TEMPB+1           
                    sta               TEMPB+1           
; POKE BYTE, peek (byte) or 2 bit
                    ldx               BITT              
                    inx
                    lda               #0                
                    sec
SQUARE              rol
                    dex
                    bne               SQUARE            
                    ldy               #0                
                    ora               (TEMPB),y         
                    sta               (TEMPB),y         
                    rts
; Main routine starts here
START               lda               #$18
                    sta               VMCSB             
                    LDA               SCROLY            
                    ora               #32               
                    sta               SCROLY            
; Select graphics bank 1
                    lda               $dd02             
                    ora               #$03              
                    sta               $dd02     
; *        
                    lda               $dd00             
                    ora               #$03              
                    sta               $dd00             
; clear bit map
                    lda               #0                
                    sta               FILVAL            
                    lda               #<BASE            
                    sta               TABPTR            
                    lda               #>BASE            
                    sta               TABPTR+1       
                    lda               #<SCRLEN
                    sta               TABSIZ            
                    lda               #>SCRLEN          
                    sta               TABSIZ+1          
                    jsr               BLKFIL            
; Set BKG and Line Colors
                    lda               #COLOR            
                    sta               FILVAL            
                    lda               #<COLMAP          
                    sta               TABPTR            
                    lda               #>COLMAP          
                    sta               TABPTR+1          
                    lda               #<MAPLEN          
                    sta               TABSIZ            
                    lda               #>MAPLEN          
                    sta               TABSIZ+1          
                    jsr               BLKFIL            
; Draw horizontal line
                    lda               #VMID             
                    sta               VPSN              
                    lda               #0
                    sta               HPSN              
                    sta               HPSN+1            
AGIN                JSR               PLOT
                    inc               HPSN              
                    bne               NEXT              
                    inc               HPSN+1            
NEXT                LDA               HPSN+1
                    cmp               #>HMAX            
                    bcc               AGIN              
                    LDA               HPSN              
                    CMP               #<HMAX            
                    BCC               AGIN              
; Draw vertical line
                    lda               #0                
                    sta               VPSN              
POINT               LDA               #<HMID
                    sta               HPSN              
                    LDA               #>HMID            
                    sta               HPSN+1            
                    jsr               PLOT              
                    inc               HPSN
                    bne               SKIP              
                    INC               HPSN+1            
SKIP                JSR               PLOT
                    ldx               VPSN              
                    inx
                    stx               VPSN              
                    cpx               #VMAX             
                    bcc               POINT             
INF                 jmp               INF