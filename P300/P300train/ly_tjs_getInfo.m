function [signal,state,parms] = ly_tjs_getInfo(datfiles,datdir)
% anotated by mrtang
% 该函数的作用在于从指定文件中读取信号等。

fprintf(1,'loading data...\n');
% 初始化state
statestr = {'PhaseInSequence' 'StimulusType' 'StimulusCode' 'StimulusBegin'};
numstat = length(statestr);
state = struct; 
for dd = 1:numstat
    state.(char(statestr(dd))) = [];
end

% 文件读取控制
if isempty(datfiles)
    [datfiles, datdir] = uigetfile('*.dat','Select the P300 ASCII(.dat) data file(s)','multiselect','on');
end
if iscell(datfiles)==0
    datfiles = {datfiles};
end

numdat = length(datfiles);  %文件数量
signal = [];                
state.trialnr = [];         %记录了当前所在的trial编号

for kk = 1:numdat
    [sig,sts,prm] = load_bcidat([datdir char(datfiles(kk))]);               %读取数据
    if ~strcmp(class(sts.StimulusType),class(sts.StimulusCode))             %拼接sts
        sts.StimulusType = cast(sts.StimulusType,class(sts.StimulusCode));
    end
    signal = cat(1,signal,sig);                                             %拼接信号
    parms.SoftwareCh_total(kk) = size(signal,2);                            %信号通道数量
    parms.SamplingRate(kk) = prm.SamplingRate.NumericValue;                 %信号采样率
    try
        OffTime = prm.ISIMinDuration.NumericValue;                          %刺激灭的时间 ms
    catch
        try
            OffTime = prm.ISIDuration.NumericValue;
        catch
        end
    end            
    OnTime = prm.StimulusDuration.NumericValue;                             %刺激亮的时间 ms
%     parms.OnTime = OnTime;
%     parms.OffTime = OffTime;
%     parms.PreSetInterval = prm.PreSequenceDuration.NumericValue;
    parms.NumberOfSequences(kk) = prm.NumberOfSequences.NumericValue;

%   读取state
    for zz = 1:numstat
        if isfield(sts,char(statestr(zz)))
            state.(char(statestr(zz))) = cat(1,state.(char(statestr(zz))),sts.(char(statestr(zz))));
        end
    end
end

samps = size(signal,1);
indx = find(state.PhaseInSequence(1:samps-1)==1 & state.PhaseInSequence(2:samps)==2)+1;
state = rmfield(state,'PhaseInSequence');
state.trialnr = zeros(samps,1);
state.trialnr(indx) = ones(1,length(indx));
state.trialnr = cumsum(state.trialnr);
state.trialnr = int16(state.trialnr);
parms.NumberOfSequences = min(parms.NumberOfSequences);
parms.SamplingRate = unique(parms.SamplingRate);
parms.trainfiles = datfiles;
parms.cube_dim = prm.cube_dim.NumericValue;
fprintf('...Done\n');

