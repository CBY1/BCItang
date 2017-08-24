function [signal,state,parms] = ly_tjs_getInfo(datfiles,datdir)
% anotated by mrtang
% �ú������������ڴ�ָ���ļ��ж�ȡ�źŵȡ�

fprintf(1,'loading data...\n');
% ��ʼ��state
statestr = {'PhaseInSequence' 'StimulusType' 'StimulusCode' 'StimulusBegin'};
numstat = length(statestr);
state = struct; 
for dd = 1:numstat
    state.(char(statestr(dd))) = [];
end

% �ļ���ȡ����
if isempty(datfiles)
    [datfiles, datdir] = uigetfile('*.dat','Select the P300 ASCII(.dat) data file(s)','multiselect','on');
end
if iscell(datfiles)==0
    datfiles = {datfiles};
end

numdat = length(datfiles);  %�ļ�����
signal = [];                
state.trialnr = [];         %��¼�˵�ǰ���ڵ�trial���

for kk = 1:numdat
    [sig,sts,prm] = load_bcidat([datdir char(datfiles(kk))]);               %��ȡ����
    if ~strcmp(class(sts.StimulusType),class(sts.StimulusCode))             %ƴ��sts
        sts.StimulusType = cast(sts.StimulusType,class(sts.StimulusCode));
    end
    signal = cat(1,signal,sig);                                             %ƴ���ź�
    parms.SoftwareCh_total(kk) = size(signal,2);                            %�ź�ͨ������
    parms.SamplingRate(kk) = prm.SamplingRate.NumericValue;                 %�źŲ�����
    try
        OffTime = prm.ISIMinDuration.NumericValue;                          %�̼����ʱ�� ms
    catch
        try
            OffTime = prm.ISIDuration.NumericValue;
        catch
        end
    end            
    OnTime = prm.StimulusDuration.NumericValue;                             %�̼�����ʱ�� ms
%     parms.OnTime = OnTime;
%     parms.OffTime = OffTime;
%     parms.PreSetInterval = prm.PreSequenceDuration.NumericValue;
    parms.NumberOfSequences(kk) = prm.NumberOfSequences.NumericValue;

%   ��ȡstate
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

