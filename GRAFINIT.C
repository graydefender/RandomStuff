#include <graphics.h>

/* IBM8514 Driver info */
#define IBMFNC     IBMOBJ
#define IBMDRIVER  IBM8514_driver
#define IBMNAME    "IBMFNC"

/* PC3270 Driver info */
#define PC3FNC     PC3
#define PC3DRIVER  PC3270_driver
#define PC3NAME    "PC3FNC"

/* ATT400 Driver info */
#define ATTFNC     ATTOBJ
#define ATTDRIVER  ATT_driver
#define ATTNAME    "ATTFNC"

/* CGA Driver info */
#define CGAFNC     CGAOBJ         /* NAME OF THE .OBJ FILE TO LINK IN */
#define CGADRIVER  CGA_driver
#define CGANAME    "CGAFNC"

/* EGA, VGA Driver info */
#define EGAVGAFNC  EGAVGA
#define VGADRIVER  EGAVGA_driver
#define EGAVGANAM  "EGAVGAFNC"

int huge (*CGAFNC)(void);       /* The CGA      graphics device driver  */
int huge (*EGAVGAFNC)(void);    /* The EGA, VGA graphics device driver  */
int huge (*IBMFNC)(void);       /* The IBM8514  graphics device driver  */
int huge (*PC3)(void);          /* The PC3270   graphics device driver  */
int huge (*ATTFNC)(void);       /* The ATT      graphics device driver  */

double AspectRatio;		/* Aspect ratio of a pixel on the screen*/
int    MaxX, MaxY;		/* The maximum resolution of the screen */
int    MaxColors;		/* The maximum # of colors available	*/
int    ErrorCode;		/* Reports any graphics errors		*/
struct palettetype palette;	/* Used to read palette info    	*/

void grafinit(GraphDriver,GraphMode)
/************************************************************************/
/*	PROGRAM:    GRAFINIT.C                                          */
/*                                                                      */
/*	FUNCTION: Initializes the graphics system and reports           */
/* 	          any errors which occured.  This routine installs      */
/*		  the graphics device driver so that BORLAND graphics   */
/*		  programs will not require any .bgi file in order      */
/*		  to execute.                                           */
/*                                                                      */
/*                                                                      */
/************************************************************************/
int GraphDriver;         /* CGA, EGA, VGA, etc.       */
int GraphMode;           /* EGAHI, EGALO, VGAHI, etc. */
{
  int xasp, yasp;	 /* Used to read the aspect ratio*/
  void *drvrname;
  int huge (*driver)(void);
  void     (*rgstrdrv)(void);


  if (GraphDriver==0 && GraphMode == 0)
   { /* INITIALIZE TEXT MODE */
     closegraph();
     return;
   }

  switch (GraphDriver)
   {
     case CGA:
       driver    = CGAFNC;        /* Set up pointer to function    */
       rgstrdrv  = CGADRIVER;     /* Set up pointer to function    */
       drvrname  = &CGANAME;
     break;

     case EGA:
     case VGA:
       driver    = EGAVGAFNC;     /* Set up pointer to function    */
       rgstrdrv  = VGADRIVER;     /* Set up pointer to function    */
       drvrname  = &EGAVGANAM;
     break;

     case IBM8514:
       driver    = IBMFNC;        /* Set up pointer to function    */
       rgstrdrv  = IBMDRIVER;     /* Set up pointer to function    */
       drvrname  = &IBMNAME;
     break;

     case PC3270:
       driver    = PC3FNC;        /* Set up pointer to function    */
       rgstrdrv  = PC3DRIVER;     /* Set up pointer to function    */
       drvrname  = &PC3NAME;
     break;

     case ATT400:
       driver    = ATTFNC;        /* Set up pointer to function    */
       rgstrdrv  = ATTDRIVER;     /* Set up pointer to function    */
       drvrname  = &ATTNAME;
     break;
   }

  registerbgidriver(rgstrdrv);         /* Register the driver as linked in */
  installuserdriver(drvrname,driver);  /* Sets up the call to initgraph()  */
  initgraph( &GraphDriver, &GraphMode,"");

  ErrorCode = graphresult();		/* Read result of initialization*/
  if( ErrorCode != grOk ){		/* Error occured during init	*/
    printf(" Graphics System Error: %s\n", grapherrormsg( ErrorCode ) );
    exit(1);
  }

  getpalette( &palette );		/* Read the palette from board	*/
  MaxColors = getmaxcolor() + 1;	/* Read maximum number of colors*/

  MaxX = getmaxx();
  MaxY = getmaxy();		   	     /* Read size of screen	*/

  getaspectratio( &xasp, &yasp );	     /* Read the hardware aspect*/
  AspectRatio = (double)xasp / (double)yasp; /* Get correction factor	*/
}
