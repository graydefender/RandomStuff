100 cls:clr:random:decimal z
1010 ch=160
1030 width = 17
1040 height =12
1045 u=0
1050 dim pc(205):dim pr(205):dim visits(234)
1070 x=2
1080 y=2
1082 v1=x*2
1085 v2=40*y*2+1024+v2+v1
1090 poke v2,ch
1100 z=rnd*2:z=whole(z) 
1110 if z=0
1112 then   v1=x*2 
1114 then   v2=40*y*2+1024-40+v1
1115 then   poke v2,ch
1120 for c=0 to height
1122    c4=c*40
1125    v1=c*width
1128    v2=v1+width
1130    visits(v1)=1:visits(v2)=1
1135    v1 = c4+1024
1136    poke v1,ch
1137    v1=width*2
1138    v2 =c4+1024+v1
1140    poke v2,ch
1145    v1 = c4
1148    v2 = height*40+1024+v1
1150    poke v2,ch
1153    v2=width*2
1154    v3=height*40+1024+v1+v2
1157    poke v3,ch
1160 next c
1170 for r=0 to width
1175    gg=1024+r
1180    visits(r)=1
1182    v1=height*width+r
1184    visits(v1)=1
1187    v2=gg+width
1188    poke gg,ch:poke v2,ch
1198    v1=height*2*40
1204    v2=v1+gg
1210    poke v2,ch
1212    v2=v1+gg+width
1214    poke v2,ch
1219 next r
1224 ;gosub 1400:stop
1230   gosub 1250
1240 "done":stop
1250 u=u+1:pc(u)=x:pr(u)=y:rem push
1252 ;print u
1255 v1=y*width+x:visits(v1)=1
1265 v4=y-1:v4=v4*width+x
1272 v3=y*width+x-1
1274 v2=y+1:v2=v2*width+x
1275 v1=y*width+x+1
1279 if visits(v1)=1 and visits(v2)=1 and visits(v3)=1 and visits(v4)=1then1340
1280 z=rnd*4:z=whole(z) 
1290 if z=0 and visits(v4)=0 
1296 then  h=x*2
1297 then  visits(v4)=1:y=y-1:i=40*y*2:j=i+1024+h
1298 then  poke j,ch:j=h+i+1024-40:poke j,ch:goto 1250
1300 if z=1 and visits(v2)=0 
1307 then  h=x*2
1308 then  visits(v2)=1:y=y+1:i=40*y*2:j=1024+h+i
1309 then  poke j,ch:j=1024+h+i+40:poke j,ch:goto 1250
1312 if z=2 and visits(v3)=0 
1317 then   i=40*y*2
1319 then  visits(v3)=1:x=x-1:h=x*2:j=1024+h+i
1320 then  poke j,ch:j=1024+h+i-1:poke j,ch:goto 1250
1323 if z=3 and visits(v1)=0 
1324 then  i=40*y*2
1326 then  visits(v1)=1:x=x+1:h=x*2:j=1024+h+i
1327 then poke j,ch:j=1024+h+i+1:poke j,ch:goto 1250
1330 goto 1280
1340 x=pc(u):y=pr(u):u=u-1:rem pop
1350 compare u,0:[beq 1360:bcs 1265]
1360 return
1400 for i=0 to height
1410 for j=0 to width
1415 v=i*width+j
1418 k=i*40+j+1024
1420 poke k,visits(v)
1430 next j
1440 ;print
1450 next i
1460 return 
