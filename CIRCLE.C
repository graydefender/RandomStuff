#include <dos.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <graphics.h>

int setaspect();
int plot();
int plot8();
int glcircle();

int xcenter,ycenter;
unsigned xaspect,yaspect;

extern int MaxX,MaxY;

main()
{
  int i;
  grafinit(VGA,VGAHI);          /* INITIALIZE THE GRAPHICS */
  cleardevice();
  while (!kbhit()) glcircle(random(MaxX),random(MaxY),random(50));
}

int glcircle (xpos,ypos,radius)
int xpos;
int ypos;
int radius;
{
  int x,y,sum;

  xcenter = xpos;
  ycenter = ypos;

  x = 0;
  y = radius << 1;
  sum = 0;

  while (x<=y)
   {
     if (x & 1) plot8(x>>1,(y+1)>>1);  /* Plot if x is odd */
     sum += (x<<1)+1;
     x++;
     if (sum>0)
      {
	sum -= (y<<1)-1;
	y--;
      }
   }
}

int plot8(int x, int y)
{
   putpixel(x+xcenter,y+ycenter,CYAN);
   putpixel(x+xcenter,ycenter-y,CYAN);
   putpixel(xcenter-x,y+ycenter,CYAN);
   putpixel(xcenter-x,ycenter-y,CYAN);
   putpixel(y+xcenter,x+ycenter,CYAN);
   putpixel(y+xcenter,ycenter-x,CYAN);
   putpixel(xcenter-y,x+ycenter,CYAN);
   putpixel(xcenter-y,ycenter-x,CYAN);
}

