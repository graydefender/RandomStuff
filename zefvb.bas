0 clr:cls
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
1660 yy=8
1680 cx=0
1700 cy=1
1720 dx=5
1740 dy=5
1750 wd=50
1760 gosub 1940
1780 a=peek(197)
1790 rem a, s =left and right w,z=up and down q=quit
1800 comp a,10:[bne 1820]:dec cx:gosub 1940:goto 1780
1820 comp a,13:[bne 1840]:inc cx:gosub 1940:goto 1780
1840 comp a,9 :[bne 1860]:dec cy:gosub 1940:goto 1780
1860 comp a,12:[bne 1880]:inc cy:gosub 1940:goto 1780
1880 comp a,62:[bne 1900]:"done":keypress:stop
1900 goto 1780
1910 rem
1920 rem
1940 rem
1945 comp cy,32768:[bcc 1962]:cy=9
1962 comp cx,32768:[bcc 1970]:cx=wd
1970 comp cx,wd:[bcc 1975:beq 1975]:cx=0
1975 comp cy,9:[bcc 1980:beq 1980]:cy=0
1980 offset=dy*y+dx+1023
2000 sub h=yy-1:for j=0 to h
2020 add ny=j+cy
2040 comp ny,9:[bcc2060:beq2060]:sub ny=ny-10
2060 for i=1 to xx
2080 add nx=i+cx
2100 compnx,wd:[bcc2120:beq2120]:sub nx=nx-wd
2120 x$=a$(ny)
2122 xx$=mid$(x$,nx,1)
2123 mm=asc(xx$):;ub mm=mm-64
2125 add nn=offset+i:;rint "mm="mm"xx$="xx$
2126 pokenn,mm
2140 next i
2160 add offset=offset+y
2180 next j
2200 return


