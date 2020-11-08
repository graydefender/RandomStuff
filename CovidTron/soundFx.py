import pygame
import sys
import os
import random

sounds = {}

def initSoundManager():
    sounds["firing"] = pygame.mixer.Sound("Assets/firing.wav")
    sounds["freeman"] = pygame.mixer.Sound("Assets/freeman.wav")
    sounds["dying"] = pygame.mixer.Sound("Assets/dying.wav")
    sounds["enemydying"] = pygame.mixer.Sound("Assets/enemydying1.wav")
    sounds["pickup"] = pygame.mixer.Sound("Assets/pickup.wav")
    sounds["transition"] = pygame.mixer.Sound("Assets/transition.wav")
    sounds["walking"] = pygame.mixer.Sound("Assets/walking.wav")

def playSound(soundName):
    channel = sounds[soundName].play()


def playSoundContinuous(soundName):
    channel = sounds[soundName].play(-1)


def stopSound(soundName):
    channel = sounds[soundName].stop()