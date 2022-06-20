0 clr:cls
10 gosub 3000
1400 dim a$(10)
1420 a$(0)="--------------------------------------------------"
1440 a$(1)=" ++++++       ++++++   @                    @    +"
1460 a$(2)=" ++   +       ++   +   @     ****         @@@@   +"
1480 a$(3)=" ++++++       ++++++*  @    *    *       @    @  +"
1500 a$(4)="                       @   *      *      @    @  +"
1520 a$(5)="         +++  @   @@   @  *        *     @@@@@@  +"
1540 a$(6)="         + +  @   @@   @  **********             +"
1560 a$(7)="         +++   @@@@@@@@   *        *     @@@@@@* +"
1580 a$(8)="    +           +         *        *           * +"
1600 a$(9)="    ++++++++++++         *********************** +"
1620 y=40
1640 xx=8
1650 fori=0to9:a$=a$(i):b=len(a$)
1651 a=asc(a$):ifa=64thena=0
1652 a$=mid$(a$,2)+chr$(a)
1653 do1651,b
1655 a$(i)=a$+left$(a$,xx):next
1660 yy=8
1680 cx=0
1700 cy=1
1720 dx=5
1740 dy=5
1750 wd=50
1760 display
1780 a=peek(197)
1790 rem a, s = left and right w, z = up and down q=quit
1800 comp a,10:[bne 1820]:dec cx:     display:goto 1780
1820 comp a,13:[bne 1840]:inc cx:     display:goto 1780
1840 comp a,9 :[bne 1860]:dec cy:     display:goto 1780
1860 comp a,12:[bne 1880]:inc cy:     display:goto 1780
1880 comp a,62:[bne 1900]:"fun":    poke198,0:keypress:stop
1900 gosub 4000:goto 1780
1910 rem
1920 rem
1940 proc display
1945 comp cy,32768:[bcc 1962]:let cy=9
1962 comp cx,32768:[bcc 1970]:let cx=wd
1970 comp wd,cx:[bcs1975]:let cx=0
1975 comp  9,cy:[bcs1980]:let cy=0
1980 offset=dy*y
1981 add offset=offset+dx
1982 add offset=offset+49152
2000 let ny=cy
2040 comp 9,ny:[bcs2060]:sub ny=ny-10
2060 add nx=1+cx
2100 compwd,nx:[bcs2120]:sub nx=nx-wd
2120 xx$=mid$(a$(ny),nx,xx)
2140 poke offset,xx$
2160 add offset=offset+y
2170 inc ny
2180 do 2040,yy
2200 return
3000 copyset 25,1
3010 charpat 0,25
3020 codex---x---
3030 code-xxx-xxx
3050 code--------
3060 code--------
3070 code--x---x-
3080 codexx-xxx-x
3090 code--------
3100 code--------
3110 vidloc 48,48,25:cls
3999 return
4000 inc cy:if cy=100 then cy=0:goto4004
4002 return
4004 [tag ch=51200
4005 [ldx ch+7:ldy #6
4010 [lda ch,y:sta ch+1,y
4020 [dey:bpl 4010
4030 [stx ch
4040 return