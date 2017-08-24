% 该脚本用与进行p300训练
clear all;
clc;
close all;
%% 选择数据
[datfiles, datdir] = ...
    uigetfile('*.eeg','Select the EEG P300 (.eeg) training data file(s)','multiselect','on','..\BCIexp\data\');
if datdir == 0, return; end
if ~iscell(datfiles)
    datfiles = {datfiles};
end
datfiles = sort(datfiles);
%% 载入数据
sig = [];
state.trial = [];
state.code = [];
mn = 0;
for i=1:length(datfiles)
    f = fullfile(datdir,datfiles{i});
    [Info,EEG,sts] = readeeg(f);
    sig = [sig,EEG];  
    sts.trial(sts.trial>0)=sts.trial(sts.trial>0)+mn;
   	state.trial = [state.trial,sts.trial];
    state.code = [state.code,sts.code];
    mn = max(state.trial);
end

%% 分析数据
wind = [100 800];  %ms
baselinewin = [-200/1000,0];
window = round(wind*Info.SamplingRate/1000);
winL = window(2)-window(1);
CH = [1,2,3,4,5];
numch = length(CH);
Responses = ly_tjs_GetP3Responses(signal(:,CH), state.trialnr, window, state.StimulusCode, state.StimulusType,parms.SamplingRate, baselinewin);
MUD=tjs_SWLDA(Responses.Responses,Responses.Type,window);
numresponse = size(Responses.Responses,1);
scores = reshape(Responses.Responses,numresponse,numch*winL)*MUD;
result = tjs_p3_predict(Responses,scores,parms.cube_dim);

%% 目标样本
target_sig = Responses.Responses(Responses.Type == 1,:,:);
target_sig = mean(target_sig,1);
target_sig = mean(target_sig,3);
nontarget_sig = Responses.Responses(Responses.Type == 0,:,:);
nontarget_sig = mean(nontarget_sig,1);
nontarget_sig = mean(nontarget_sig,3);
t = linspace(wind(1),wind(2),winL);
figure;
hold on
grid on
plot(t,target_sig,'m');
plot(t,nontarget_sig,'g');
cd(oldpath);

%% 保存参数
current_path = cd;
ind = find(current_path == '\');
mudname = fullfile(current_path(1:ind(end-1)-1),'parms','mud','MUD.mat');
TFs = parms.SamplingRate;
Twindow = window;
Tblwindow = round(baselinewin*TFs);
Tp3chs = CH;
TMUD = MUD;
Tp3filter = Responses.p3filter;
save(mudname,'TFs','Twindow','Tblwindow','Tp3chs','TMUD','Tp3filter');
disp('params saved as:')
disp(mudname)

% % 说明：参数直接保存的是Twindow记录的是点数而不是时间，因此在采样率不一致的时候计算不会报错，但是实际截取的不是期望信号。
% % 另外，建议在线和离线时stimulusduration和ISIduration一致




