import pygame as pg
import settings

class Point():
    def __init__(self,game,x,y,points):
        self.X = x
        self.Y = y
        self.Points = points
        self.aplhaReduction = 255 // (2 * settings.FPS)
        self.Alpha = 255
        self.Game = game

    def draw(self):
        pgfont = pg.font.match_font(settings.TEXT_FONT)
        font = pg.font.Font(pgfont, 15)
        text_surface = font.render(str(self.Points), True, (self.Alpha,self.Alpha,self.Alpha))
        text_rect = text_surface.get_rect()
        text_rect.topleft = (self.X, self.Y)
        self.Game.screen.blit(text_surface, text_rect)

    def update(self):
        self.Alpha -= self.aplhaReduction
        if self.Alpha < 0:
            self.Alpha = 0
