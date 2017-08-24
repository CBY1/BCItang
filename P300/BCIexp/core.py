#!user/bin/python
# -*-coding:utf-8-*-

#FileName: core.py
#Version: 1.0
#Author: Jingsheng Tang
#Date: 2017/8/10
#Email: mrtang@nudt.edu.cn
#Git: trzp


import numpy as np
import time
import threading

from ampclient import AmpClient
from storage import Storage
from bcitypes import *

try:    __INF__ = float('inf')
except: __INF__ = 0xFFFF

class core(threading.Thread):
    def __init__(self,phase_ev,sig,bci_sts,expset):
        self.phase_ev = phase_ev
        self.sig = sig
        self.bci_sts = bci_sts
        self.expset = expset

        self.amp = AmpClient()
        self.store = Storage()

        self.currentphase = 'start'
        self.PHASES = {'start':{'next':'','duration':__INF__},'stop':0}
        self.param = EEGparam()
        threading.Thread.__init__(self)

    def addphase(self,name='',next='',duration=__INF__):
        self.PHASES[name]={'next':next,'duration':duration}

    def inphase(self,phase):
        return phase==self.currentphase

    def changephase(self,phase):
        if self.PHASES.has_key(phase):
            self.currentphase=phase
            self.__clk = time.clock()
            self.phase_ev.set()
        else:
            raise IOError,'no phase: %s found!'%(phase)

    def run(self):
        print 'core thread started!'
        stskeys = self.bci_sts.state.keys()
        stsnum = len(stskeys)

        if self.expset.AMPon:
            # self.sig.states = stskeys
            self.amp.initialize()
            self.store.create_file(self.expset)
            self.store.write_info(self.amp.param,str(stskeys))

            temsts = np.zeros((stsnum,400000),dtype=np.float64)
            while not self.amp.getdata()[0]:  pass
            indx = 0

        self.__clk = time.clock()
        self.phase_ev.set()

        while True:
            clk = time.clock()

            if self.expset.AMPon:
                for i in range(stsnum):
                    temsts[i,indx]=self.bci_sts.state[stskeys[i]]
                indx+=1

                r = self.amp.getdata()
                if r[0]:
                    d = r[1]
                    sample = np.linspace(0,indx-1,self.amp.param.point+1).astype(np.int32)
                    stt = temsts[:,sample[1:]]
                    dd = np.vstack((d,stt))
                    self.store.write_data(dd)
                    self.sig.eeg = d
                    for i in range(stsnum): self.sig.state[stskeys[i]]=stt[i,]
                    self.sig.event.set()
                    indx = 0

            if clk-self.__clk>self.PHASES[self.currentphase]['duration']:
                self.currentphase=self.PHASES[self.currentphase]['next']
                self.__clk = clk
                self.phase_ev.set()
                if self.inphase('stop'):break

        if self.expset.AMPon:  self.store.close_file()
        print 'core thread ended!'

