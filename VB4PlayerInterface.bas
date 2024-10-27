
5 rem bank 0
10 clr
15 scaninit
20 decimal p1,p2,p3,p4:tag x1=p1+4
30 tag x2=p2+4,x3=p3+4,x4=p4+4
40 scanjoy
45 rem
50 print p1,p2,p3,p4
60 goto 40
100 end

5 rem bank 1
10 proc scanjoy
20 [lda $dc01:and #$1f:sta x1:lda $dc00
30 [and #$1f:sta x2:lda $dd01:ora #$80
40 [sta $dd01:lda $dd01:and #$1f
50 [sta x3:lda $dd01:and #$7f:sta $dd01
60 [lda $dd01:pha:and #$0f:sta x4:pla
70 [and #$20:lsra:ora x4:sta x4
100 return
1000 proc scaninit
1010 [lda #$80:sta $dd03:lda $dd01
1020 [sta $dd01
1030 return


























