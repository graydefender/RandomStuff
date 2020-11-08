import pygame as pg
import settings
import game

class Text():
    def __init__(self,game,x,y,text,size,alignment,stay,duration):
        self.X = x
        self.Y = y
        self.Text = text
        self.Duration = duration
        self.aplhaReduction = 155 // (self.Duration * settings.FPS)
        self.Alpha = 155
        self.Game = game
        self.Size = size
        self.Alignment = alignment
        self.Stay = stay * settings.FPS

    def draw(self):
        pgfont = pg.font.match_font(settings.TEXT_FONT)
        font = pg.font.Font(pgfont, self.Size)
        text_surface = font.render(self.Text, True, (self.Alpha,self.Alpha,self.Alpha))
        text_rect = text_surface.get_rect()
        if str.upper(self.Alignment) == "CENTRE":
            x = self.X - text_rect.width // 2
        elif str.upper(self.Alignment) == "LEFT":
            x = self.X - text_rect.width 
        elif str.upper(self.Alignment) == "RIGHT":
            x = self.X + text_rect.width

        text_rect.topleft = (x, self.Y)
        self.Game.screen.blit(text_surface, text_rect)

    def update(self):
        if self.Stay == 0:
            self.Alpha -= self.aplhaReduction
            if self.Alpha < 0:
                self.Alpha = 0
        else:
            self.Stay -= 1

