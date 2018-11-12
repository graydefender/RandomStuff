1000 rem ** Gray Defender 11/04/2008
1010 rem ** Draw Maze - Recursive backtracking algorithm
1020 rem ** Adapted from:
1030 rem "https://rosettacode.org/"
1040 dim x,y,Width,Height,ch,index
1050 ch=160:SCWIDTH=40:poke 53280,5
1060 print chr$(147): rem clear screen
1070 Width = 18
1080 Height =11
1090 dim SX(Width*Height+1):DIM SY(Width*Height+1):REM Stack X,Stack Y
1100 dim Vs(Height+1,Width+1): REM Visits array
1110 x=7 : REM START X POS in maze
1120 y=7 : REM START Y POS
1130 poke 1024+x*2+SCWIDTH*y*2,ch: rem starting pos pokes this and next line
1140 if int(rnd(1)*2)=0 then poke 1024+x*2+SCWIDTH*y*2-SCWIDTH,ch:REM see video for expl.
1150 REM SET BORDER CELLS TO VISITED
1160 o1=1024+Height*SCWIDTH:o2=1024+Width*2:o3=o1+Width*2
1170 FOR i=0 TO Height:REM set border all around outter edges as 'visited'
1180    Vs(i,0)=1:Vs(i,Width)=1
1190    poke 1024+i*SCWIDTH,ch:poke i*SCWIDTH+o2,ch: rem draw vert borders
1200    poke i*SCWIDTH+o1,ch: poke i*SCWIDTH+o3,ch
1210 NEXT i
1220 FOR i=0 TO Width:REM set border all around outter edges as 'visited'
1230    Vs(0,i)=1:Vs(Height,i)=1
1240    poke 1024+i,ch:poke 1024+i+Width,ch: rem draw horiz borders
1250    poke 1024+(Height*2)*SCWIDTH+i,ch:poke 1024+(Height*2)*SCWIDTH+i+Width,ch
1260 NEXT i
1270 Index=Index+1:SX(Index)=x:SY(Index)=y:REM PUSH x,y onto stack
1280 Vs(y,x)=1
1290 IF Vs(y,x+1)=1 AND Vs(y+1,x)=1 AND Vs(y,x-1)=1 AND Vs(y-1,x)=1 THEN GOTO 1360
1300 z=INT(RND(1)*4)
1310 if z=0 and Vs(y-1,x)=0 then Vs(y-1,x)=1:y=y-1:poke 1024+x*2+SCWIDTH*y*2,ch:poke 1024+x*2+SCWIDTH*y*2-SCWIDTH,ch:goto 1270
1320 if z=1 and Vs(y+1,x)=0 then Vs(y+1,x)=1:y=y+1:poke 1024+x*2+SCWIDTH*y*2,ch:poke 1024+x*2+SCWIDTH*y*2+SCWIDTH,ch:goto 1270
1330 if z=2 and Vs(y,x-1)=0 then Vs(y,x-1)=1:x=x-1:poke 1024+x*2+SCWIDTH*y*2,ch:poke 1024+x*2+SCWIDTH*y*2-1,ch:goto 1270
1340 if z=3 and Vs(y,x+1)=0 then Vs(y,x+1)=1:x=x+1:poke 1024+x*2+SCWIDTH*y*2,ch:poke 1024+x*2+SCWIDTH*y*2+1,ch:goto 1270
1350 goto 1300
1360 x=SX(Index):y=SY(Index):Index=Index-1:REM POP x and y off of stack
1370 IF Index > 0 THEN GOTO 1290
1380 poke 53280,4
1390 goto 1390