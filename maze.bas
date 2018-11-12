1000 dim x,y,Width,Height,ch
1010 ch=160
1020 print chr$(147)
1030 Width = 7
1040 Height =4
1050 dim PC(Width*Height+1):DIM PR(Width*Height+1):REM STACK
1060 dim Visits(Height+1,Width+1)
1070 x=2
1080 y=2
1090 poke 1024+x*2+40*y*2,ch
1100 if int(rnd(1)*2)=0 then poke 1024+x*2+40*y*2-40,ch
1110 REM SET BORDER CELLS TO VISITED
1120 FOR C=0 TO Height
1130 Visits(C,0)=1:Visits(C,Width)=1
1131 poke 1024+C*40,ch:poke 1024+C*40+Width*2,ch
1132 poke 1024+C*40+(Height*40),ch: poke 1024+C*40+(Height*40)+Width*2,ch
1160 NEXT C
1170 FOR R=0 TO Width
1180 Visits(0,R)=1:Visits(Height,R)=1
1181 poke 1024+R,ch:poke 1024+R+Width,ch
1182 poke 1024+(Height*2)*40+R,ch:poke 1024+(Height*2)*40+R+Width,ch
1210 NEXT R
1220   gosub 1250
1230 rem gosub 1350
1240 goto 1240
1250 U=U+1:PC(U)=x:PR(U)=y:REM PUSH
1260 Visits(y,x)=1
1270 IF Visits(y,x+1)=1 AND Visits(y+1,x)=1 AND Visits(y,x-1)=1 AND Visuts(y-1,x)=1 THEN GOTO 1340
1280 z=INT(RND(1)*4)
1290 if z=0 and Visits(y-1,x)=0 then Visits(y-1,x)=1:y=y-1:poke 1024+x*2+40*y*2,ch:poke 1024+x*2+40*y*2-40,ch:goto 1250
1300 if z=1 and Visits(y+1,x)=0 then Visits(y+1,x)=1:y=y+1:poke 1024+x*2+40*y*2,ch:poke 1024+x*2+40*y*2+40,ch:goto 1250
1310 if z=2 and Visits(y,x-1)=0 then Visits(y,x-1)=1:x=x-1:poke 1024+x*2+40*y*2,ch:poke 1024+x*2+40*y*2-1,ch:goto 1250
1320 if z=3 and Visits(y,x+1)=0 then Visits(y,x+1)=1:x=x+1:poke 1024+x*2+40*y*2,ch:poke 1024+x*2+40*y*2+1,ch:goto 1250
1330 goto 1280
1340 x=PC(U):y=PR(U):U=U-1:REM POP
1350 IF U > 0 THEN GOTO 1270
1360 return
1370 goto 1370
1380 rem
1390 rem DISPLAY Visits
1400 for i=0 to Height
1410 for j=0 to Width
1420 print Visits(i,j);
1430 next j
1440 print
1450 next i
1460 return