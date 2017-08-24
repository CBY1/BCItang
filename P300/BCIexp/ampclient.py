#!user/bin/python
# -*-coding:utf-8-*-

#FileName: ampclient.py
#Version: 1.0
#Author: Jingsheng Tang
#Date: 2017/8/11
#Email: mrtang@nudt.edu.cn
#Github: trzp


import mmap
import struct
import numpy as np
from bcitypes import *
import time


class AmpClient(object):
    '''
    the pycorder acquire data for every 50ms. this class is used to read these data
    from a piece of shared memory named '__eeg_from_pycorder__'.
    '''
    def __init__(self):
        self.shm = mmap.mmap(0,24,access=mmap.ACCESS_READ,tagname='__eeg_from_pycorder__')
        self.param = EEGparam()

    def initialize(self):
        self.shm.seek(0)
        fs,chs,p = struct.unpack('3d',self.shm.read(24))
        self.size = int((4+chs*p)*8)
        self.shm = mmap.mmap(0,self.size,access=mmap.ACCESS_READ,tagname='__eeg_from_pycorder__')
        self.databytesize = int(chs*p*8)
        self.ind = 0
        self.rs = 'd'*int(chs*p)

        self.param.samplingrate = int(fs)
        self.param.eegchannels = int(chs)
        self.param.point = int(p)

    def getdata(self):
        self.shm.seek(24)
        ind = struct.unpack('d',self.shm.read(8))[0]
        d = ind - self.ind

        if d>1:
            print time.strftime('%H:%M:%S   ',time.localtime(time.time())) + 'lost %i data'%(d)

        if d>0:
            self.ind = ind
            self.shm.seek(32)
            data = np.array(struct.unpack(self.rs, self.shm.read(self.databytesize))).reshape((self.param.eegchannels, self.param.point))
            return 1,data
        else:
            return 0,0
