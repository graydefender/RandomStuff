#include <stdio.h>
#include <conio.h>
#include <bios.h>
#include <dos.h>
#include <stdlib.h>

struct list
 {
    int x1;
    int y1;
    struct list *next;
 };

struct list *first, *last;

/* X and Y are positions of the head */
/* xdir = 1 --> right */
/* xdir =-1 --> left  */
/* ydir =-1 --> down  */
/* ydir = 1 --> up    */

int key,x=15,y=10,ydir=1,xdir=0,xmin=1,xmax=80,ymin=2,ymax=25,over=0;
int length_list=0,del=7;
char space[2], tail_ch[2],head_ch[2];

main()
{
  init_vars();
  directions();
  do {
	rotate();
	if ((x==xmin) && (xdir==-1)) {ydir=-1; xdir=0;}
	if ((x==xmax) && (xdir==1))  {ydir= 1; xdir=0;}
	if ((y==ymin) && (ydir==-1)) {xdir= 1; ydir=0;}
	if ((y==ymax) && (ydir== 1)) {xdir=-1; ydir=0;}

	if (key=bioskey(1)) bioskey(0);
	switch(key) {
	   case 18432 : { ydir = -1; xdir = 0; break;} /* UP          */
	   case 20480 : { ydir =  1; xdir = 0; break;} /* DOWN        */
	   case 19200 : { xdir = -1; ydir = 0; break;} /* LEFT        */
	   case 19712 : { xdir =  1; ydir = 0; break;} /* RIGHT       */
	   case 7777  : { add_node(); break;         } /* LETTER a    */
	   case 8292  : { delete_node(); break;      } /* LETTER d    */
	   case 4709  : { over = 1; break;           } /* LETTER e    */
	   case 3389  : { del++; break;              } /* LETTER =    */
	   case 3117  : { if (del>0) del--; break;   } /* LETTER -    */
	} /* switch */
	delay(del);
  } while (!over);
} /* MAIN */

/********************SUB PROGRAMS*********************/

int rotate()
{
  int x2,y2;
  x2=last->x1;
  y2=last->y1;
  puttext(x2,y2,x2,y2,(void *)tail_ch);
  delete_node();
  x+=xdir;
  y+=ydir;
  add_node();
  puttext(x,y,x,y,(void *)head_ch);    /* put a new node at the head */
}

int add_node()      /* add a node to the end of the list */
{
  struct list *temp;
  temp = (struct list *)malloc(sizeof(struct list));
  last->next=temp;
  last=temp;
  last->x1=x;
  last->y1=y;
  length_list++;
}

int delete_node()  /* delete node from the beginning of the list */
{
  if (length_list>1)
   {
     struct list *temp;
     int x1,y1;
     temp=first;
     x1=first->next->x1;
     y1=first->next->y1;
     first=first->next;
     free(temp);
     puttext(x1,y1,x1,y1,(void *)space); /* erase off the screen */
     length_list--;
   }
}

int init_vars()  /* initialize the vars. and linked list len=2 */
{
  space[0]=' ';         /* Initialize all the attribute chars */
  space[1]=0;           /*                                    */
  tail_ch[0]='0';       /*                                    */
  tail_ch[1]=111;       /*                                    */
  head_ch[0]='A';       /*                                    */
  head_ch[1]=113;       /*                                    */

  first=(struct list *)malloc(sizeof(struct list));
  last=first;
}

int directions()
{
  clrscr();
  textcolor(WHITE);
  cprintf("\n\n\n\n");
  cprintf("LETTER:");
  cprintf("\n\ra) -- Insert node");
  cprintf("\n\rd) -- Delete node");
  cprintf("\n\re) -- End program");
  cprintf("\n\r=) -- Increase the delay");
  cprintf("\n\r-) -- Decrease the delay");
  cprintf("\n\n---------- Press any key to continue ----------");
  getch();
  clrscr();
  gotoxy(0,0);
  textcolor(BLACK);
  textbackground(WHITE);
  cprintf("                                  E to end                                     ");
  gotoxy(0,0);
}