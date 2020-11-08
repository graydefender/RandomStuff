import pygame as pg
from pygame.locals import *
from settings import *
import enemy
import player
from pygame import font
import texts
from soundFx import *
import powerup
import random

#***************************************************
# Enemy RampUps
#RampUp_NoEnemies = [3]
#RampUp_NoEnemies = [ 3, 5, 7,12,15,19,23,27,32,37,42,47,52,57,62]
#RampUp_PlayerSPD = [ 2, 2, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4]
#RampUp_EnemySPD  = [10, 8, 6, 4, 3, 3, 2, 2, 1, 1, 1, 0, 0, 0, 0] 

RampUp_NoEnemies = [ 3, 5, 7,12,15,19,23,27,32,37,42,47]
RampUp_PlayerSPD = [ 2, 2, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4]
RampUp_EnemySPD  = [10, 8, 6, 4, 3, 3, 2, 2, 1, 1, 1, 0]
#***************************************************
class Game:
    
    def __init__(self):
        # Initialise game code
        pg.init()
        pg.mixer.init()
        initSoundManager()
        self.screen = pg.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pg.display.set_caption(TITLE)
        self.clock = pg.time.Clock()
        self.Max_Enemies=0  
        self.dead=False  
        self.playing=True
        self.running = True
        self.NoOfLives = NUMBER_LIVES
        self.enemy_delay=0
        self.enemies_level_start=0  #** Number of enemies at level start
        self.enemies_per_transition=ENEMIES_PER_RND
        self.RoundClear=True
        self.dead = False 
        self.Enemy_SPAWN_List=[]
        self.enemies_spawned=0
        self.allspawned=False
      
        self.First_Time_in_Round=True  # Needed to skip level ramp ups after you die within a given round
        self.bonus_score=FREE_MAN  # free man every xxxx points
        self.enemy_hits=0  #track how many enemies were destroyed
        
        #***
        # Sprite groups        
        #***
        self.PlayerSprites = pg.sprite.Group()
        self.projectile = pg.sprite.Group()
        self.enemies    = pg.sprite.Group()
        self.powerups   = pg.sprite.Group()        
    
        self.points = []

        #***
        # As long As more enemies is true then game will
        # continue adding enemies
        # Set up player sprite
        #***
        self.player = player.Player(self,K_UP)
        self.PlayerSprites.add(self.player)
        
    def new(self, round):
       #** Set player sprite to yellow again
        for sprite in self.PlayerSprites:
            sprite.image.fill((YELLOW))

        self.Level = round
        self.RoundClear = False
        self.MORE_ENEMIES = True
        self.LevelCoolDown=50
        self.allspawned=False

        player.Player.playerspeed =PLAYER_SPEED  # Default Player speed

        if self.First_Time_in_Round==True:         
            if self.Level <= len(RampUp_NoEnemies):
                self.Max_Enemies = RampUp_NoEnemies[self.Level-1]  # Subtract one bc self.level starts at 1 not 0
                self.enemies_level_start = self.Max_Enemies
                player.Player.playerspeed  = RampUp_PlayerSPD[self.Level-1]  
                enemy.Enemy.enemyspeed = RampUp_EnemySPD[self.Level-1]   
            else:
                self.player.maxprojectilecooldown = 15

        self.First_Time_in_Round=False
        
        player.Player.x = SCREEN_WIDTH//2
        player.Player.y = SCREEN_HEIGHT//2       
        enemy.Enemy.Init_Enemies(enemy.Enemy,self)

        text = texts.Text(self, 400, 450, "Round {:02d}".format(round),50,"CENTRE",3,1)
        self.points.append(text)

        if  len(self.powerups)<1:  # If powerup is not currently active and no power ups on the current screen
            if self.Level == POWERUP1_LEVEL and player.Player.PowerupType!=0:   # First power up            
                powerup1=powerup.PowerUp(RandPwrPos(SCREEN_WIDTH),RandPwrPos(SCREEN_HEIGHT),0,"A") #*** Auto fire enabled ***
                self.powerups.add(powerup1)                    
            elif self.Level == POWERUP2_LEVEL and player.Player.PowerupType!=1: # Second power up            
                powerup1=powerup.PowerUp(RandPwrPos(SCREEN_WIDTH),RandPwrPos(SCREEN_HEIGHT),1,"L") #*** Two way fire enabled ***
                self.powerups.add(powerup1)        
            elif self.Level == POWERUP3_LEVEL and player.Player.PowerupType!=2:  # First power up            
                powerup1=powerup.PowerUp(RandPwrPos(SCREEN_WIDTH),RandPwrPos(SCREEN_HEIGHT),2,"X") #*** 4 way fire enabled ***                     
                self.powerups.add(powerup1)        
        self.run()

    #***
    # Executed from MAIN
    # to run the main game code
    #***
    def run(self):    
        # Game Loop Code

        self.playing = True
        while self.playing:
                      
            self.clock.tick(FPS)
            self.events()
            self.update()
            self.draw()           
    #***
    # Executed from this class (run definition)
    # to run the main game code
    #***
    def update(self):
        # Game Loop Update Method
        self.PlayerSprites.update()

        self.projectile.update()
        self.player.update()          
        enemy.Enemy.move(self)
            
        for point in self.points:
            point.update()
            if point.Alpha == 0:
                self.points.remove(point)
        
        self.powerups.update()

    #***
    # Executed from this class (run definition)
    # Check events to determine if game over is true
    #*** 
    def events(self):
        # Game Loop Events handler
        for event in pg.event.get():
            # check for closing the window
            if event.type == pg.QUIT:
                if self.playing:
                    self.playing = False
                self.running = False
    #***
    # Executed from this class (run definition)
    # Draw everything on the screen once per cycle
    #***
    def draw(self):
        # Game Loop draw screen
        self.screen.fill(BLACK)
        
        self.showHUD()        
        self.PlayerSprites.draw(self.screen)
        self.enemies.draw(self.screen)
        self.projectile.draw(self.screen)

        for point in self.points:
            point.draw()
  
        self.powerups.draw(self.screen)

        # After redrawing the screen, flip it
        pg.display.flip()
        pass

    def showTitleScreen(self):

       base_y=50  # Make it easier to adjust height of Image and COVID title text
      #self.game=game
       pg.init()
       self.screen = pg.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
       self.image = pygame.Surface((SCREEN_WIDTH,SCREEN_HEIGHT))
       self.image.fill((BLACK))
       self.screen.blit(self.image,(SCREEN_WIDTH,SCREEN_HEIGHT))
       pg.display.flip()

       image = pg.image.load(COVID_IMAGE)
       self.screen.blit(image, (285 , base_y))

       font = pg.font.Font(TITLE_FONT,100)
       text_surface = font.render("COVID -   - TRON", True, GREEN)
       text_rect = text_surface.get_rect()
       text_rect.topleft = (24, base_y+60)
       self.screen.blit(text_surface, text_rect)

       font = pg.font.Font(TEXT_FONT,20)
       text_surface = font.render("10  Points", True, WHITE)
       text_rect = text_surface.get_rect()
       text_rect.topleft = (350, base_y+230)
       self.screen.blit(text_surface, text_rect)

       pg.draw.rect(self.screen,BLUE,(320,base_y+230,ENEMY_WIDTH,ENEMY_HEIGHT))
       pg.draw.rect(self.screen,ORANGE,(320,base_y+240+ENEMY_HEIGHT,ENEMY_WIDTH,ENEMY_HEIGHT))
       pg.draw.rect(self.screen,RED,(320,base_y+250+ENEMY_HEIGHT*2,ENEMY_WIDTH,ENEMY_HEIGHT))
       pg.draw.rect(self.screen,PURPLE,(320,base_y+260+ENEMY_HEIGHT*3,ENEMY_WIDTH,ENEMY_HEIGHT))

       text_surface = font.render("100 Points", True, WHITE)
       text_rect = text_surface.get_rect()
       text_rect.topleft = (350, base_y+255)
       self.screen.blit(text_surface, text_rect)

       text_surface = font.render("200 Points", True, WHITE)
       text_rect = text_surface.get_rect()
       text_rect.topleft = (350, base_y+280)
       self.screen.blit(text_surface, text_rect)

       text_surface = font.render("300 Points", True, WHITE)
       text_rect = text_surface.get_rect()
       text_rect.topleft = (350, base_y+305)
       self.screen.blit(text_surface, text_rect)

       text_surface = font.render("(Press spacebar to play)", True, WHITE)
       text_rect = text_surface.get_rect()
       text_rect.topleft = (200, SCREEN_HEIGHT-30)
       self.screen.blit(text_surface, text_rect)

       font1 = pg.font.match_font(TEXT_FONT2)
       font = pg.font.Font(font1, 20)       
       text_surface = font.render("Controls: (Arrow Keys + Space to fire)", True, WHITE)
       text_rect = text_surface.get_rect()
       text_rect.topleft = (285, SCREEN_HEIGHT//2+110)
       self.screen.blit(text_surface, text_rect)

       pg.display.flip()
       Press_Any_Key()
       for sprite in self.PlayerSprites:
           sprite.rect.x=SCREEN_WIDTH//2
           sprite.rect.y=SCREEN_HEIGHT//2


    #**************************************
    # DISPLAY GAME OVER SCREEN
    #**************************************    
    def showGameOverScreen(self):

       base_y=50  # Make it easier to adjust height of Image and COVID title text
       self.screen.fill(BLACK)
       self.showHUD()  

       for j in range(40):        
            for i in range(175,255):
                    font = pg.font.Font(TITLE_FONT,100)
                    text_surface = font.render("Game Over!", True, (0,i,0))
                    text_rect = text_surface.get_rect()
                    text_rect.topleft = (150,SCREEN_HEIGHT//3)
                    self.screen.blit(text_surface, text_rect)
                    pg.display.flip()
            for i in reversed(range(255,175)):
                    font = pg.font.Font(TITLE_FONT,100)
                    text_surface = font.render("Game Over!", True, (0,i,0))
                    text_rect = text_surface.get_rect()
                    text_rect.topleft = (150,SCREEN_HEIGHT//3)
                    self.screen.blit(text_surface, text_rect)
                    pg.display.flip()

    #**************************************
    # DISPLAY SCORE / ROUND / LEVELS
    #**************************************           
    def showHUD(self):
        font = pg.font.Font(TEXT_FONT,18)
        text_surface = font.render("SCORE:", True, WHITE)
        text_rect = text_surface.get_rect()
        text_width1, text_height = font.size("SCORE:")
        text_rect.topleft = (0, SCREEN_HEIGHT-text_height)
        self.screen.blit(text_surface, text_rect)

        text_surface = font.render(str(player.Player.score), True, RED)
        text_rect = text_surface.get_rect()
        text_width, text_height = font.size("txt")
        text_rect.topleft = (text_width1, SCREEN_HEIGHT-text_height)
        self.screen.blit(text_surface, text_rect)

        text_surface = font.render("Round:", True, WHITE)
        text_rect = text_surface.get_rect()
        text_width2, text_height2 = font.size("txt")
        text_rect.topleft = (SCREEN_WIDTH//2-text_width1+50, SCREEN_HEIGHT-text_height2)
        self.screen.blit(text_surface, text_rect)

        text_surface = font.render(str(self.Level), True, RED)
        text_rect = text_surface.get_rect()
        text_width2, text_height2 = font.size("txt")
        text_rect.topleft = (SCREEN_WIDTH//2+50, SCREEN_HEIGHT-text_height2)
        self.screen.blit(text_surface, text_rect)

        text_surface = font.render("Lives:", True, WHITE)
        text_rect = text_surface.get_rect()
        text_width3, text_height2 = font.size("txt")
        text_rect.topleft = (SCREEN_WIDTH-text_width3-100, SCREEN_HEIGHT-text_height2)
        self.screen.blit(text_surface, text_rect)

        text_surface = font.render(str(self.NoOfLives), True, RED)
        text_rect = text_surface.get_rect()
        text_width2, text_height2 = font.size("txt")
        text_rect.topleft = (SCREEN_WIDTH-45, SCREEN_HEIGHT-text_height2)
        self.screen.blit(text_surface, text_rect)

    def transition(self):    
        colors = [BLUE,ORANGE,RED,PURPLE]
        effectstart=0
        for i in range (15):
            colorindex=0
            while colorindex<4: 
                left=0
                right=0
                effectcolor=effectstart
                for count in range(30):                                    
                    pg.draw.rect(self.screen,colors[effectcolor],(left,right,SCREEN_WIDTH-left*2,SCREEN_HEIGHT-right*2))            
                    effectcolor+=1
                    if effectcolor>3:
                        effectcolor=0
                    left+=10
                    right+=10
                colorindex+=1
                effectstart+=1
                if effectstart>3:
                    effectstart=0
                pg.display.flip()
                pg.time.wait(30) 

    # def getround(self):
    #     return self.Level                        
    def SetPlayerDead(self):
        self.dead=True
        
# Grab random x,y for Power up position (1 at a time)
# Idea was to not spawn directly in center of screen
# where player starts
def RandPwrPos(width):
    if random.randrange(2)==0:
        val= random.randrange(50,width//2-50)
    else:
        val= random.randrange(width//2+50,width-50)
    return (val)

def Press_Any_Key():
    done=False
    while not done:    
        for event in pygame.event.get():  # User did something
            if event.type == pygame.KEYDOWN:
                keypressedcode = event.key # This is the ASCII code
                if keypressedcode==K_SPACE:
                    done=True
                    break
 
            elif event.type == pygame.QUIT:  # If user clicked close
                done = True  # Flag that we are done so we exit this loop
