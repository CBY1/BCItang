#!user/bin/python
# -*-coding:utf-8-*-

#FileName: block.py
#Version: 1.0
#Author: Jingsheng Tang
#Date: 2017/8/12
#Email: mrtang@nudt.edu.cn
#Github: trzp

import pygame
from pygame_anchors import *
import os

class Block(object):
    def __init__(self,root,
                    siz = (5,5),
                    position = (0,0),
                    anchor = 'center',
                    borderon = False,
                    borderwidth = 1,
                    bordercolor = (0,0,0),
                    forecolor = (255,255,255,255),
                    textcolor = (0,255,255),
                    textfont = 'arial',
                    textanchor = 'center',
                    textsize = 10,
                    text = '',
                    layer = 0,
                    visible = False):

        pygame.font.init()
        self.root = root

        self.siz = siz
        self.position = position
        self.anchor = anchor
        self.borderon = borderon
        self.borderwidth = borderwidth
        self.bordercolor = bordercolor
        self.forecolor = forecolor
        self.textcolor = textcolor
        self.textfont = textfont
        self.textanchor = textanchor
        self.textsize = textsize
        self.text = text
        self.visible = visible
        self.layer = layer

        self.sur = None
        self.blitp = None
        self.blitpborder = None

        if not os.path.isfile(self.textfont): self.textfont = pygame.font.match_font(self.textfont)
        self.font_object = pygame.font.Font(self.textfont,self.textsize)

        self.blitp = self.blitpborder = blit_pos1(self.siz,self.position,self.anchor)

    def reset(self):
        self.blitp = self.blitpborder = blit_pos1(self.siz,self.position,self.anchor)
        if self.forecolor[3]!=0:
            self.sur = pygame.Surface(self.siz).convert_alpha()
            self.sur.fill(self.forecolor)

            if self.text != '':
                c = [int(0.5*i) for i in self.sur.get_size()]
                txt = self.font_object.render(self.text,1,self.textcolor)
                p = blit_pos(txt,c,'center')
                self.sur.blit(txt,p)
        else:
            if self.text != '':
                self.sur = self.font_object.render(self.text,1,self.textcolor)
                self.blitp = blit_pos(self.sur,self.position,self.anchor)

        return self.sur,self.blitp

    def show(self):
        if self.visible:
            if self.sur!=None:  self.root.blit(self.sur,self.blitp)
            if self.borderon:   pygame.draw.rect(self.root,self.bordercolor,pygame.Rect(self.blitpborder,self.siz),self.borderwidth)

