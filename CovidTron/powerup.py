import pygame
from settings import *
from pygame.locals import *
from soundFx import *

#**************************************
# Create / Init/ Power up 
# Contains code to initialize and update
# the power ups (shimmer effect)
#**************************************
class PowerUp(pygame.sprite.Sprite):

    def __init__(self,x,y,type,letter):

        # Call the parent class (Sprite) constructor
        super().__init__()      

        self.height = PLAYER_HEIGHT+5
        self.width = PLAYER_WIDTH+5
        self.shimmer = 4
        self.color = BLUE
        self.x=x
        self.y=y
        self.type = type          # -== no power up 0==Autofire 
        self.type_letter = letter # type (A==autofire L==2 way fire X==fire all directions)
        self.shimmerindex = 0
        self.image = pygame.Surface((self.width,self.height)) 
        self.rect   = self.image.get_rect()
        self.rect.x = self.x
        self.rect.y = self.y
         
    def update(self):
        shimmercolors=[BLUE,ORANGE,YELLOW,ORANGE,PURPLE]        
        self.shimmerindex+=1
        if self.shimmerindex==10:                    
            self.shimmerindex=0  
            self.shimmer -=1              
            if self.shimmer==0:
                self.shimmer=4
            self.color=shimmercolors[self.shimmer]
            pygame.draw.circle(self.image, self.color, (14, 15), 15) 
            self.font = pygame.font.SysFont(TEXT_FONT, 25)
            self.textSurf = self.font.render(self.type_letter, True, WHITE)
            self.image.blit(self.textSurf,(8,7))

