'*** Gray Defender 11/08/2018
'*** Draw Maze - Recursive backtracking algorithm
'*** Adapted from:
'*** https://rosettacode.org/
CONST SCREEN=$200
CONST SC_WIDTH=20
CONST Width=5    'Max=10 , Min=2
CONST Height=5   'Max=6  , Min=3
dim x,y,z,Width,Height,#ch,index,vWidth
vWidth=Width+1
if Width>10 or Width<2 or Height>6 or Height<3 then
  cls
  print at 0,"Invalid maze params!"
  goto EXIT_PROGRAM
end if
print at 0,"Press Up"
while cont1.up=false 
  x=random(100)
wend

#ch=($5f*8)+6  ' 5f is the card character and +6 is the color
cls ' Clear the screen
DIM SX(Width*Height+1):DIM SY(Width*Height+1) ' STACK X, STACK Y
DIM Vs((Height+1)*(vWidth)) ' Visits Array
x = 2 ' Start x position in maze
y = 2 ' Start y position in maze
poke SCREEN+x*2+(SC_WIDTH*y*2),#ch ' Starting position poke this and next line
if random(2)=0 then poke SCREEN+x*2+(SC_WIDTH*y*2)-SC_WIDTH,#ch ' Only do this 50% of the time

For i=0 to Height ' Set border all around outer edges as visited
  Vs(i*vWidth)=1:Vs(i*vWidth+Width)=1
  poke SCREEN+i*SC_WIDTH,#ch:poke SCREEN+i*SC_WIDTH+Width*2,#ch   ' Draw vertical borders
  poke SCREEN+i*SC_WIDTH+Height*SC_WIDTH,#ch:poke SCREEN+i*SC_WIDTH+Height*SC_WIDTH+Width*2,#ch
next i
For i=0 to Width ' Set border all around outer edges as visited
  Vs(i)=1:Vs(Height*vWidth+i)=1
  poke SCREEN+i,#ch:poke SCREEN+i+Width,#ch  				      ' Draw horizontal borders
  poke SCREEN+Height*2*SC_WIDTH+i,#ch:poke SCREEN+Height*2*SC_WIDTH+i+Width,#ch
next i

PUSH_STACK:
index=index+1:SX(index)=x:SY(index)=y ' Push x, y onto the stack
Vs((y*vWidth)+x)=1
CHECK_VISITS:
all_visits=Vs(y*vWidth+x+1)+Vs((y+1)*vWidth+x)+Vs((y-1)*vWidth+x)+Vs(y*vWidth+x-1)
if all_visits=4 then goto POP_STACK 'Check if all directions have been visited
GET_RANDOM:
z=random(4)
if z=0 and Vs((y-1)*vWidth+x)=0 then Vs((y-1)*vWidth+x)=1:y=y-1:poke SCREEN+x*2+SC_WIDTH*y*2,#ch:poke SCREEN+x*2+SC_WIDTH*y*2-SC_WIDTH,#ch:goto PUSH_STACK
if z=1 and Vs((y+1)*vWidth+x)=0 then Vs((y+1)*vWidth+x)=1:y=y+1:poke SCREEN+x*2+SC_WIDTH*y*2,#ch:poke SCREEN+x*2+SC_WIDTH*y*2+SC_WIDTH,#ch:goto PUSH_STACK
if z=2 and Vs(y*vWidth+x-1)=0   then Vs(y*vWidth+x-1)=1  :x=x-1:poke SCREEN+x*2+SC_WIDTH*y*2,#ch:poke SCREEN+x*2+SC_WIDTH*y*2-1,#ch       :goto PUSH_STACK
if z=3 and Vs(y*vWidth+x+1)=0   then Vs(y*vWidth+x+1)=1  :x=x+1:poke SCREEN+x*2+SC_WIDTH*y*2,#ch:poke SCREEN+x*2+SC_WIDTH*y*2+1,#ch       :goto PUSH_STACK
goto GET_RANDOM
POP_STACK:
x=SX(index):y=SY(index):index=index-1 'POP x and Y off of stack
if index>0 then goto CHECK_VISITS
EXIT_PROGRAM: 

