from typing import ClassVar
import pygame as pg
import random
from settings import *
from soundFx import *

class Enemy(pg.sprite.Sprite):
        
    drumbeat = 0
    def __init__(self,color,value):

        super().__init__()        
    
        self.image = pg.Surface([ENEMY_WIDTH, ENEMY_HEIGHT])
        self.image.fill(color)
        self.color=color
        self.score_value=value    # num points this enemy is worth
        self.width=ENEMY_WIDTH
        self.height=ENEMY_HEIGHT
        self.rect = self.image.get_rect()
        self.prevdir=0
        self.steps_taken=0

    def Init_Enemies(self,game):
    
        Enemy_Lista = [BLUE for i in range(game.Max_Enemies)]            
        pct = int(.15 * game.Max_Enemies)  #** For example 15% of enemies will be RED/PURPLE/ORANGE
        for value in range(pct):
            Enemy.Place_In_EArray(Enemy_Lista,PURPLE,game.Max_Enemies)
            Enemy.Place_In_EArray(Enemy_Lista,RED,game.Max_Enemies)
            Enemy.Place_In_EArray(Enemy_Lista,ORANGE,game.Max_Enemies)            
        game.Enemy_SPAWN_List = Enemy_Lista

    def Place_In_EArray(Enemy_List,color,max):
        Not_Set = True
        while Not_Set:
            randpos=random.randrange(max)            
            if Enemy_List[randpos] == BLUE:                
                Enemy_List[randpos] = color
                Not_Set=False    
    #***
    # Move ALL the enemies around the screen
    #***    
    def move(self):                
       if self.LevelCoolDown>0:
           self.LevelCoolDown -= 1
           return

       Enemy.drumbeat+=1
       if Enemy.drumbeat==40:
           playSound("walking")
           Enemy.drumbeat=0 
        
       # Delay a bit before moving enemies       
       if self.enemy_delay<Enemy.enemyspeed:
           self.enemy_delay+=1
       else:
           self.enemy_delay=0                  
            # Add Enemy Sprites on screen but stop adding them when threshold reached
           if len(self.enemies) < self.Max_Enemies and self.MORE_ENEMIES == True:            
               Enemy.add_enemies(self)
           else: 
               self.MORE_ENEMIES=False
               self.allspawned=True
           #** 
           # MOVE ALL of the enemies:
           # What I do is 1) copy the enemy x,y 2) remove enemy, then 3) pick a random direction to move
           # 4) check collision in new position 5) if no collision add enemy back in 
           # new location otherwise add enemy back in old location
           #**           
           for baddie in self.enemies:
               placeholder_x, placeholder_y = baddie.rect.x, baddie.rect.y
               baddie_color = baddie.color
               maybe = random.randrange(2)
               if baddie_color in (RED, ORANGE, PURPLE) and maybe==0:  # Make these colors MORE AGGRESSIVE - move toward the player                   
                   xory = random.randrange(2)
                   if xory == 0: #Sometimes move RED toward X sometimes toward Y
                       if baddie.rect.x < self.player.rect.x:
                           randir = 3 # move right toward player
                       else:
                           randir = 2 # move left toward player
                   else:
                       if baddie.rect.y < self.player.rect.y:
                           randir = 1 # move up toward player
                       else:
                           randir = 0 # move down toward player
                   Enemy.Move_Enemy_In_Dir(Enemy,randir,baddie)
                   baddie.steps_taken=0
                   self.enemies.remove(baddie)  
               else: 
                   randir=random.randrange(4)  # Move in random direction
                   self.enemies.remove(baddie)              
                                
                   if baddie.steps_taken>=ENEMY_STEPS_B4_CHDIR:
                       baddie.steps_taken=0                    

                       if randir != baddie.prevdir:
                           Enemy.Move_Enemy_In_Dir(Enemy,randir,baddie)
                   else:
                           randir=baddie.prevdir
                           baddie.steps_taken+=1                           
                           Enemy.Move_Enemy_In_Dir(Enemy,randir,baddie)
               #***********************************************************
               #Check collision: if enemies collide with another enemy then
               #put enemy back in original location, otherwise allow the move
               if pg.sprite.spritecollideany(baddie,self.enemies): 
                    baddie.rect.x=placeholder_x
                    baddie.rect.y=placeholder_y
                    self.enemies.add(baddie)                                                   
               else:
                    self.enemies.add(baddie)                                  
                    
    def Move_Enemy_In_Dir(self,randir,badguy):             
        if randir==0:  # UP
            badguy.rect.y-=ENEMY_GRANULARITY  
            self.CheckY(badguy)
        elif randir==1:  # DOWN
            badguy.rect.y+=ENEMY_GRANULARITY
            self.CheckY(badguy)            
        if randir==2:  # LEFT
            badguy.rect.x-=ENEMY_GRANULARITY
            self.CheckX(badguy)
        elif randir==3:  # RIGHT
            badguy.rect.x+=ENEMY_GRANULARITY
            self.CheckX(badguy)            
        badguy.prevdir=randir

    def CheckX(badguy):            
        if badguy.rect.x > SCREEN_WIDTH - badguy.width:
            badguy.rect.x = SCREEN_WIDTH - badguy.width
        elif badguy.rect.x < 0:
            badguy.rect.x = 0

    # Keep player on the screen vertical Boundaries
    def CheckY(badguy):            
        if badguy.rect.y > SCREEN_HEIGHT - HUD_HEIGHT:
            badguy.rect.y = SCREEN_HEIGHT - HUD_HEIGHT
        elif badguy.rect.y < 0:
            badguy.rect.y = 0            

    #***
    # Function to add a new enemy to the play field
    # without landing on top of existing enemy
    #***
    def add_enemies(self):       
        points_worth=10
        Color = BLUE

        self.enemies_spawned+=1  # Count how many enemies spawned this level so far               
        count =len(self.enemies)
        if count < len(self.Enemy_SPAWN_List):
            Baddie_Color=self.Enemy_SPAWN_List[count]
            if Baddie_Color==PURPLE:
                Color = PURPLE
                points_worth=300
            elif Baddie_Color==RED:
                Color = RED
                points_worth=200
            elif Baddie_Color==ORANGE:
                Color= ORANGE
                points_worth=100
        else:           
            return        
        block = Enemy(Color,points_worth)
            
        # # Set a random location for the block
        block.rect.x = random.randrange(0,SCREEN_WIDTH-ENEMY_WIDTH+2)  # +2 bc they appear on right border but inside a little
        block.rect.y = random.randrange(5,SCREEN_HEIGHT-HUD_HEIGHT)   

        # Do not add enemy to the sprite list unless no collision with enemies and player
        if not pg.sprite.spritecollide(block, self.enemies, False) and not pg.sprite.spritecollide(block,self.PlayerSprites, False):   
            self.enemies.add(block)   
 
        # alternate method of detecting enemy sprite collisions
        # Did not implement but I thought it was a was great idea...
        # from cyb3rfly3r in discord
        # collisions = pg.sprite.groupcollide(group, group, False, False)
        # for sp in collisions:
        #     collideList = collisions[sp]
        #     collideList.remove(sp) # do not collide with yourself
        #     if collideList:
        #         for spOther in collideList:
        #             sp.setCollision()
        #             spOther.setCollision()
        #             collisions[spOther].remove(sp) # remove duplicate detection
        #             BasicPhysicsObject.doCollision(sp, spOther)
        #     else:            
        #         sp.resetCollision()