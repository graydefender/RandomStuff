10 rem
15 rem goto 15
20 BASE=2*4092: POKE 53272,PEEK(53272)OR8
30 POKE 53265,PEEK(53265)OR32
40 FOR I=BASE TO BASE+7999:POKE I,0:NEXT
50 FOR I=1024 TO 2023:POKE I,16:NEXT I
60 GOTO 200
70 REM
80 REM
90 xx=INT(HPSN/8)
100 ROW=INT(VPSN/8)
110 LINE=VPSN AND 7
120 BYTE =BASE+ROW*320+8*xx+LINE
130 BIT=7-(HPSN AND 7)
140 POKE BYTE,PEEK(BYTE) or (2^BIT)
150 RETURN
160 REM
170 REM
180 REM
190 REM
200 REM
210 REM
220 FOR VPSN=0 TO 199
225 FOR HPSN=160 TO 160
230 GOSUB 80
240 NEXT HPSN:NEXT VPSN
250 VPSN=100
260 FOR HPSN=8 TO 327
270 GOSUB 80
280 NEXT HPSN
290 GOTO 290

 