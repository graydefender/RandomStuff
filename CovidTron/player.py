import pygame
from pygame.locals import *
from settings import *
import projectile
from settings import PLAYER_HEIGHT, SCREEN_HEIGHT, SCREEN_WIDTH
from soundFx import *
import texts

#** 
# Player Control and movement through keyboard
#**
class Player(pygame.sprite.Sprite):

    score=0
    PowerupType=-1
    lasthoriz=K_LEFT
    lastvert=K_UP

    def __init__(self,game,lastdirection):
        self.lastdirection=lastdirection
  
        super().__init__()
  
        self.game=game
        self.width = PLAYER_WIDTH
        self.height =PLAYER_HEIGHT        

        # Make our top-left corner the passed-in location.
        self.image = pygame.Surface((self.width,self.height))
        self.image.fill((YELLOW))

        self.rect = self.image.get_rect()

        self.rect.x = SCREEN_WIDTH // 2
        self.rect.y = SCREEN_HEIGHT // 2

        self.lasthoriz=K_LEFT
        self.lastvert=K_UP

        self.projectilecooldown=0
        self.maxprojectilecooldown = 25
    def update(self):
        #** In the event bullet leaves screen boundaries
        #** REMOVE the bullet off the screen & memory
        #***
        for bullet in self.game.projectile:
            if bullet.rect.y < 0 or bullet.rect.y > SCREEN_HEIGHT - PLAYER_HEIGHT \
            or bullet.rect.x < 0 or bullet.rect.x-PROJECTILE_OFFSET > SCREEN_WIDTH - PLAYER_WIDTH:
                self.game.projectile.remove(bullet)
        #***
        # Grab the keyboard up/down/left/right/space
        # This construct also allows diagonal movement ie. left+down
        #*** 
        keys=pygame.key.get_pressed()
        if keys[K_LEFT]:            
            self.rect.x -= self.playerspeed            
            self.CheckX()
            self.lastdirection=K_LEFT            
            self.lasthoriz=K_LEFT
        elif keys[K_RIGHT]:
            self.rect.x += self.playerspeed
            self.CheckX()
            self.lastdirection=K_RIGHT            
            self.lasthoriz=K_RIGHT
        if keys[K_UP]:            
            self.rect.y -= self.playerspeed
            self.CheckY()
            self.lastdirection=K_UP   
            self.lastvert=K_UP         
        elif keys[K_DOWN]:
            self.rect.y += self.playerspeed
            self.CheckY()
            self.lastdirection=K_DOWN
            self.lastvert=K_DOWN

        SpriteGroup = pygame.sprite.groupcollide(self.game.powerups,self.game.PlayerSprites,True,False) 
        projectile.Projectile.Check_Hit_PowerUp(self,SpriteGroup)

        #*** Check if Player Collides with Enemy ***
        SpriteGroup =  pygame.sprite.groupcollide(self.game.PlayerSprites,self.game.enemies,False,True) 
        if SpriteGroup:
            playSound("dying")
            
            spn=len(self.game.Enemy_SPAWN_List) # Spawned            
            #hits=self.game.enemy_hits           # Enemies Destroyed on screen

            if (self.game.allspawned==True):
                self.game.enemies_level_start=len(self.game.enemies)+1 #spn-hits 
            else: 
                self.game.enemies_level_start=spn
            self.First_Time_in_Round=False
            
            text = texts.Text(self.game, 550, SCREEN_HEIGHT-15, str(self.game.enemies_level_start)+" enemies remaining",15,"CENTRE",3,1)
            self.game.points.append(text)

            bs=175
            cv=145
            for i in range(5):
                self.DyingEffect(bs,cv,0,0)
                self.DyingEffect(-bs,cv,0,0)
            self.DyingEffect(bs,cv,cv,0)
            #reset values to original
            self.image = pygame.Surface((self.width,self.height))        
            self.image.fill((YELLOW))
            self.game.draw()                               
            pygame.sprite.Group.empty(self.game.enemies)
            pygame.sprite.Group.empty(self.game.projectile)
            self.game.playing=False
            self.game.SetPlayerDead()
            self.game.Enemy_SPAWN_List.clear()           
            pygame.sprite.Group.empty(self.game.enemies)
            pygame.sprite.Group.empty(self.game.projectile)            
            pygame.sprite.Group.empty(self.game.powerups)
            self.game.enemies_spawned=0
            self.image.fill((BLACK))
            return            

        if  Player.PowerupType>=0 or keys[K_SPACE]:
            if self.projectilecooldown==0 :
                #stopSound("walking")
                playSound("firing")
                #*** After cooldown period, FIRE a BULLET!! In direction player last moved on screen
                self.projectilecooldown=self.maxprojectilecooldown
                projectile1=projectile.Projectile(self.game,self.lastdirection,self.rect.x,self.rect.y)                                        
                self.game.projectile.add(projectile1)

                directions=[K_UP,K_DOWN,K_LEFT,K_RIGHT]
                if Player.PowerupType==2:  # Power up to fire in all directions 
                    if self.lastdirection in directions:
                        directions.remove(self.lastdirection)  # Dont fire in this direction (..already did a few lines above)
                    for newbullet in directions: # add projectiles in the three other directions
                        projectile1=projectile.Projectile(self.game,newbullet,self.rect.x,self.rect.y)                                        
                        self.game.projectile.add(projectile1)
                if Player.PowerupType==1:  # Power up to fire in two directions
                    if self.lastdirection in [K_UP,K_DOWN]:
                        xlastvert=K_UP
                        if self.lastvert==K_LEFT:
                            xlastvert=K_RIGHT
                        if self.lastvert==K_RIGHT:
                            xlastvert=K_LEFT

                        projectile1=projectile.Projectile(self.game,self.lasthoriz,self.rect.x,self.rect.y)                                        
                        self.game.projectile.add(projectile1)
                    else: 
                        xlasthoriz=K_DOWN
                        if self.lasthoriz==K_UP:
                            xlasthoriz=K_DOWN
                        if self.lasthoriz==K_DOWN:
                            xlasthoriz=K_UP

                        projectile1=projectile.Projectile(self.game,self.lastvert,self.rect.x,self.rect.y)                                        
                        self.game.projectile.add(projectile1)                                           
            else:
                self.projectilecooldown-=1                                   
   
    # Keep player on the screen horizontal Boundaries
    def CheckX(self):            
        if self.rect.x > SCREEN_WIDTH - self.width:
            self.rect.x = SCREEN_WIDTH - self.width
        elif self.rect.x < 0:
            self.rect.x = 0

    # Keep player on the screen vertical Boundaries
    def CheckY(self):            
        if self.rect.y > SCREEN_HEIGHT - HUD_HEIGHT:
            self.rect.y = SCREEN_HEIGHT - HUD_HEIGHT
        elif self.rect.y < 0:
            self.rect.y = 0     

    def addToScore(self,game,amount_toadd):       
        self.score+=amount_toadd
        if self.score>game.bonus_score:
            playSound("freeman")
            game.NoOfLives+=1
            game.bonus_score+=FREE_MAN
            game.showHUD()

    #** Create some kind of effect for dying...
    def DyingEffect(self,base,a,b,c):
        if base<0:
            rng=reversed(range(abs(base),200))
        else:
            rng=range(base,200)

        for BB in rng:
            self.image = pygame.Surface((self.width+base/30,self.height+base/30))
            if a>0: 
                a=BB
            if b>0: 
                b=BB
            if c>0: 
                c=BB

            self.image.fill(((a,b,c)))
            self.game.draw()           
       

      