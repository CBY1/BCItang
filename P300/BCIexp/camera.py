#!user/bin/python
# -*-coding:utf-8-*-

#FileName: camera.py
#Version: 1.0
#Author: Jingsheng Tang
#Date: 2017/8/24
#Email: mrtang@nudt.edu.cn
#Github: trzp


import pygame
from VideoCapture import Device
from pygame_anchors import *
# from PIL import ImageEnhance

class Camera(object):
    def __init__(self,root,devnum=0,siz=(640,480),position=(0,0),anchor='lefttop',layer=0,visible=True):
        self.cam = Device(devnum)
        self.root = root
        self.siz = siz
        self.position=position
        self.anchor=anchor
        self.layer = layer
        self.visible=visible

        self.brightness = 1.0
        self.contrast = 1.0
        
        self.reset()

    def reset(self):
        self.blitp = blit_pos1(self.siz,self.position,self.anchor)

    def show(self):
        if self.visible:
            im = self.cam.getImage()
            # im = ImageEnhance.Brightness(im).enhance(self.brightness)
            # im = ImageEnhance.Contrast(im).enhance(self.contrast)
            sur = pygame.image.fromstring(im.tostring(),(640,480), "RGB")
            if self.siz[0] != 640 or self.siz[1] != 480:
                sur = pygame.transform.scale(sur,self.siz)
            self.root.blit(sur,self.blitp)
