import pygame
from settings import *
from pygame.locals import *
import player
import points
import enemy
import game
from soundFx import *
import texts

class Projectile(pygame.sprite.Sprite):

    def __init__(self,game,direction,x,y):

        # Call the parent class (Sprite) constructor
        super().__init__()
        self.game=game        

        # Floating point representation of where the player is
        self.x = x
        self.y = y

        # Direction of projectile (Up/down/left/right)
        self.direction = direction

        self.height = PROJECTILE_HEIGHT
        self.width = PROJECTILE_WIDTH
       
        # Create the image of the player surface
        self.image = pygame.Surface((self.width,self.height))

        # Color of the player
        self.image.fill(WHITE)

        # Get a rectangle object that shows where our image is
        
        self.rect   = self.image.get_rect()
        self.rect.x = self.x
        self.rect.y = self.y

    #***
    # Check the direction of bullet/projectile and adjust it's position
    #**
    def update(self):
        if self.direction==K_UP:
            self.y-=PROJECTILE_SPEED
        if self.direction==K_DOWN:
            self.y+=PROJECTILE_SPEED
        if self.direction==K_LEFT:
            self.x-=PROJECTILE_SPEED            
        if self.direction==K_RIGHT:
            self.x+=PROJECTILE_SPEED            

        self.rect.x=self.x+PROJECTILE_OFFSET
        self.rect.y=self.y+PROJECTILE_OFFSET
    
        #***
        # After moving bullet, check for Collisions 
        # with each enemy on screen
        #***
        for bullet in self.game.projectile:  
            # had to use SpriteGroup to extract the score point value of the enemy destroyed
            SpriteGroup =  pygame.sprite.spritecollide(bullet,self.game.enemies,True)
            for Sprite in SpriteGroup:       
                self.game.enemy_hits+=1
                playSound("enemydying")
                self.game.projectile.remove(bullet) 
                
                player.Player.addToScore(player.Player,self.game,Sprite.score_value)
                if Sprite.score_value != 10:  # Dont fade score amount if only 10 points
                    pnt = points.Point(self.game,Sprite.rect.x,Sprite.rect.y,Sprite.score_value)
                    self.game.points.append(pnt)

                if len(self.game.enemies)<=0:
                    if self.game.enemy_hits>=self.game.Max_Enemies:
                        playSound("transition")
                        self.game.enemy_hits=0                        
                        self.game.RoundClear = True
                        self.game.playing = False
                        self.game.First_Time_in_Round=True
                        self.game.enemies_per_transition+=ENEMIES_PER_RND  #Keep running total of new enemies per round                            
                        self.game.enemies_level_start=self.game.enemies_per_transition      # Set the max enemies to the total for the new round                        
                        self.game.screen.fill(BLACK) # Clear screen, since last sprites were not clearing after last bullet hit on screen... bug
                        self.game.showHUD()        # show score again...
                        pygame.display.flip()
                        pygame.time.wait(1000)  
                        self.game.transition()
                        break
            # Check if Powerup was hit
            SpriteGroup =  pygame.sprite.spritecollide(bullet,self.game.powerups,True)
            self.Check_Hit_PowerUp(SpriteGroup)

    #***
    #* Check for if either the player or a bullet has
    #* collided with a power up, and enable it if true
    #* Called from player.py & projectile.py
    #***
    def Check_Hit_PowerUp(self,SpriteGroup):
        for Sprite in SpriteGroup: 
            playSound("pickup")
            player.Player.PowerupType=Sprite.type   # Grab Power up type (0=autofire 1=2 way fire 3=fire all directions)
            type_text=["Auto Fire","Two Way Fire","Four Way Fire"]
            text = texts.Text(self.game, 400, 500, type_text[Sprite.type].format(round),50,"CENTRE",3,1)
            self.game.points.append(text) 


    
