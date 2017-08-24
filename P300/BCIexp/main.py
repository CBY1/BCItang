#!user/bin/python
# -*-coding:utf-8-*-

#FileName: BCIappP3.py
#Version: 1.0
#Author: Jingsheng Tang
#Date: 2017/8/17
#Email: mrtang@nudt.edu.cn
#Github: trzp


from BCIcore import *
from block import Block
from imagebox import Imagebox
from random import shuffle
from BCIFunc import *
from pygame_anchors import anchors as ANCH
import time
from camera import Camera

txt = [chr(i+97) for i in range(26)]+[str(i) for i in range(10)]

class BciApplication(BciCore):
    '''
    members:
        state: dict, to record the experiment state
        stimuli: dict, object with method reset() and show(), refers to Blcok
        expset: Expset, to set experiment params
        current_phase: return current phase
        screen: pygame.Surface, after method init_screen() called, the screen is solid

    methods:
        Initialize()
        init_screen(): create main screen
        Phase(): adding phases by calling phase(),the phases should start at 'start' phase and ended at 'stop' phase
        change_phase(ph): change phase to ph immediately
        in_phase(ph): return if currently in the ph phase
        Frame(): call at each frame
        Transition(ph): call according to the current phase
        Process(sig): call on each data package recieved (50ms). sig: the Signal object.
        StartRun(): start the program
    '''

    def Initialize(self):
        self.STATES.state['code']=-1
        self.STATES.state['trial']=0

        # self.expset.experiment_name = 'word speller'
        # self.expset.subject_name = 'TJS'
        # self.expset.AMPon = False

        self.init_screen((960,720))
        self.GUIsetup()

        self.signal = []

        tasklist = range(36)
        shuffle(tasklist)
        self.tasklist = tasklist[0:9]
        self.current_task = ''
        self.currentbook = None
        self.currentindex = None
        self.res = 0

        self.anc = ANCH.keys()

    def Phase(self):
        self.phase(name='start',       next='prompt',    duration=3)
        self.phase(name='prompt',      next='on',        duration=2)
        self.phase(name='on',          next='off',       duration=0.1)
        self.phase(name='off',         next='on',        duration=0.1)
        self.phase(name='res',         next='prompt',    duration=2)
        self.phase(name='stop')

    def stimon(self,i):
        self.stimuli['flsh%d'%(i)].forecolor = (255,255,255,255)
        self.stimuli['flsh%d'%(i)].reset()

    def stimoff(self,i):
        self.stimuli['flsh%d'%(i)].forecolor = (255,255,255,0)
        self.stimuli['flsh%d'%(i)].reset()

    def prompton(self,i):
        self.stimuli['flsh%d'%(i)].bordercolor = (0,255,0)
        self.stimuli['flsh%d'%(i)].borderon = True
        self.stimuli['flsh%d'%(i)].reset()

    def promptoff(self,i):
        self.stimuli['flsh%d'%(i)].borderon = False
        self.stimuli['flsh%d'%(i)].reset()

    def reson(self,i):
        self.stimuli['flsh%d'%(i)].bordercolor = (255,0,0)
        self.stimuli['flsh%d'%(i)].borderon = True
        self.stimuli['flsh%d'%(i)].reset()

    def resoff(self,i):
        self.stimuli['flsh%d'%(i)].borderon = False
        self.stimuli['flsh%d'%(i)].reset()

    def getres(self):
        return 1

    def Transition(self,phase):
        if phase == 'prompt':
            if len(self.anc)!=0:
                self.stimuli['welcome'].textanchor = self.anc.pop()
                self.stimuli['welcome'].reset()
            self.stimuli['welcome'].visible = True

            if len(self.tasklist)==0:
                self.change_phase('stop')
            else:
                self.STATES.state['trial']+=1
                self.resoff(self.res)
                self.current_task = self.tasklist.pop()
                self.prompton(self.current_task)
                self.cube, self.codebook, self.codeindex = generate_cube_codebook((6,6),3)

        elif phase == 'on':
            self.stimuli['camera'].visible = True
            self.stimuli['welcome'].visible = False

            if self.codebook==[]:
                self.change_phase('res')
            else:
                self.currentbook = self.codebook.pop()
                self.STATES.state['code'] = self.codeindex.pop()
                [self.stimon(d) for d in self.currentbook]

        elif phase == 'off':
            self.STATES.state['code'] = -1
            [self.stimoff(d) for d in self.currentbook]

        elif phase == 'res':
            self.stimuli['camera'].visible = False
            self.promptoff(self.current_task)
            self.res = self.getres()
            self.reson(self.res)

    def Frame(self): #called on ever screen frame
        pass

    def Process(self,sig):
        pass

    def GUIsetup(self):
        scrw,scrh = self.screen.get_size()
        center = [scrw/2,scrh/2]
        scrh = scrh - 80				# task, result 显示区占用了一部分。
        hunit = int(scrh/13.5)
        wunit = int(scrw/13)
        hpos = [3*hunit,5*hunit,7*hunit,9*hunit,11*hunit,13*hunit]
        wpos = [1.5*wunit,3.5*wunit,5.5*wunit,7.5*wunit,9.5*wunit,11.5*wunit]
        pos_sti = [(x,y) for y in hpos for x in wpos ]
        unit = int(min(hunit,wunit))

        for i in range(36):
            self.stimuli['flsh%d'%(i)] = Block(self.screen,(1.5*wunit,hunit),pos_sti[i],text=txt[i],
                                               textsize=int(unit/1.5),forecolor=(255,255,255,0),
                                               borderon=False,bordercolor=(0,255,0),visible=True,
                                               layer=1)
            self.stimuli['flsh%d'%(i)].reset()

        impath = os.path.split(os.sys.argv[0])[0]+'\\pics\\pic.png'
        self.stimuli['welcome'] = Imagebox(self.screen,position=center,image=impath,layer=2,
                                           textanchor='lefttop',text='welcome',textsize=30,
                                           textcolor=(255,0,0),borderon=True,borderwidth=2)

        self.stimuli['welcome'].reset()
        self.stimuli['camera']=Camera(self.screen,layer=-1,siz = (scrw,scrh),visible=False)


if __name__ == '__main__':
    app = BciApplication()
    app.StartRun()

