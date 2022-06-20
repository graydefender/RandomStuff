0 cls:clr:random
1010 tag ch=160
1030 width = 17
1040 height =12
1045 u=0
1050 dim pc(205),pr(205),visits(234)
1070 x=2
1080 y=2
1082 v1=x*2
1085 v2=40*y*2+1024+v1
1090 poke v2,ch
1100 z=rnd(2)and1
1110 compz,0:[bne1120
1112 letv1=x:dublv1
1114 v2=80*y+984+v1
1115 poke v2,ch
1120 for c=0 to height
1122 c4=c*40
1125 v1=c*width
1128 add v2=v1+width
1130 visits(v1)=1:visits(v2)=1
1135 add v1=c4+1024
1136 poke v1,ch
1137 let v1=width:dubl v1
1138 add v2 =c4+1024:add v2=v2+v1
1140 poke v2,ch
1145 let v1 = c4
1148 v2 = height*40                    :     add v2=v2+1024:add v2=v2+v1
1150 poke v2,ch
1153 let v2=width:dubl v2
1154 v3=height*40:add v3=v3+1024       :     add v3=v3+v1:add v3=v3+v2
1157 poke v3,ch
1160 next c
1170 for r=0 to width
1175 add gg=1024+r
1180 visits(r)=1
1182 v1=height*width:add v1=v1+r
1184 visits(v1)=1
1187 v2=gg+width
1188 poke gg,ch:poke v2,ch
1198 v1=height*80
1204 add v2=v1+gg
1210 poke v2,ch
1212 add v2=v1+gg:add v2=v2+width
1214 poke v2,ch
1219 next r
1224 ;gosub 1400:stop
1230 gosub 1250
1240 "done":stop
1250 inc u:pc(u)=x:pr(u)=y:rem push
1252 ;print u
1255 v1=y*width:add v1=v1+x            :     visits(v1)=1
1265 sub v4=y-1                        :     v4=v4*width:add v4=v4+x
1272 v3=y*width                        :     add v3=v3+x:dec v3
1274 add v2=y+1:v2=v2*width            :     add v2=v2+x
1275 v1=y*width                        :     add v1=v1+x:incv1
1279 if visits(v1) and visits(v2) and visits(v3) and visits(v4) then1340
1280 z=rnd(2)and3:[comp z,0:beq1290    :     comp z,2:bcc1300:beq1312:bcs1323
1290 if visits(v4) then1300
1297 visits(v4)=1:decy:calc:pokej,ch
1298 sub j=j-40:poke j,ch:goto 1250
1300 if visits(v2) then1312
1308 visits(v2)=1:incy:calc:pokej,ch
1309 add j=j+40:poke j,ch:goto 1250
1312 if visits(v3) then1323
1319 visits(v3)=1:decx:calc
1320 dec j:goto1327
1323 if visits(v1) then1330
1326 visits(v1)=1:incx:calc
1327 pokej,ch,ch:goto 1250
1330 goto 1280
1340 x=pc(u):y=pr(u):u=u-1:rem pop
1350 compare u,0:[bne 1265]
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
1500 proc calc
1510 let i=y:dubli:dubli:add i=i+y
1520 dubli:dubli:dubli
1530 add j=x+512:add j=j+i:dublj
1540 return