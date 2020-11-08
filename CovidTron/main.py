#*******************************************
#* COVID-O-TRON
#* Gray Defender
#* 11/07/2020
#* 11/08/2002
#* Bug fix to keep enemies within border
#* Bug fix to not spawn enemies on player
#* Bug fix to spawn remaining enemy count
#* after dying only after all enemies spawned
#*******************************************
import pygame as pg
import game
import player
import settings

CurrentRound=0
#player.Player.PowerupType=2
g = game.Game()
g.showTitleScreen()
g.enemies_level_start=settings.ENEMIES_PER_RND

while g.running:

    if g.RoundClear:
        CurrentRound += 1
        g.enemy_hits=0
        g.Max_Enemies=g.enemies_level_start
        g.new(CurrentRound)

    if g.dead:
        g.dead=False
        if g.NoOfLives == 0:        
            g.showGameOverScreen()
            CurrentRound=0
            g.RoundClear=True 
            g.playing=True
            g.enemies_per_transition=settings.ENEMIES_PER_RND
            g.enemies_level_start=settings.ENEMIES_PER_RND
            g.NoOfLives=settings.NUMBER_LIVES
            g.bonus_score=settings.FREE_MAN
            g.allspawned=False
            g.First_Time_in_Round=True
            player.Player.score=0
            player.Player.PowerupType=-1
            g.showTitleScreen()   # Loop back to Title Screen
        else:
            g.NoOfLives-=1
            g.playing=True                
            CurrentRound-=1
            g.RoundClear=True   
            
pg.display.quit()
pg.quit()