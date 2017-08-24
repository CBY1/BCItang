#!user/bin/python
# -*-coding:utf-8-*-

#FileName: storage.py
#Version: 1.0
#Author: Jingsheng Tang
#Date: 2017/8/9
#Email: mrtang@nudt.edu.cn
#Github: trzp

import os, time
import numpy as np
from bcitypes import *


class Storage(object):
    def __init__(self):
        self.expset = None
        self.data_file = None

    def getnum(self,file,head,extension):
        hi = file.find(head)
        ei = file.find(extension)
        if hi==-1 or ei==-1:
            return -1
        else:
            try:
                num = int(file[hi+len(head):ei])
                return num
            except:
                return -1

    def create_file(self,expset):
        self.expset = expset
        head = self.expset.subject_name +'-S%iR'%(self.expset.session)
        extension = '.dat'
        filenum = self.expset.run
        filename = head+str(filenum)+extension
        filepath = self.expset.path+'//'+filename
        if not os.path.exists(self.expset.path):
            os.makedirs(self.expset.path)
        else:
            files = os.listdir(self.expset.path)
            nums = [self.getnum(f,head,extension) for f in files if self.getnum(f,head,extension)>-1]
            if nums!=[]:    filepath = self.expset.path+'//'+head+str(max(nums)+1)+extension
        self.data_file = open(filepath,'a')

    def write_info(self,param,sts):
        self.data_file.write('experiment name:'+self.expset.experiment_name+'\n')
        self.data_file.write('subject:'+self.expset.subject_name+'\n')
        self.data_file.write('time:'+time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+'\n')
        self.data_file.write('samplingrate:'+str(param.samplingrate)+'\n')
        self.data_file.write('eeg channels:'+str(param.eegchannels)+'\n')
        self.data_file.write('states:'+sts+'\n')

    def write_data(self,data):#channels x points
        d = data.transpose().flatten()
        self.data_file.write(d.tostring())

    def close_file(self):
        self.data_file.close()




