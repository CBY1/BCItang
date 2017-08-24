function Responses = ly_tjs_GetP3Responses(signal_p300,trialnr,window,StimulusCode,StimulusType, samplingrate, baseline_win)
% annotate by mrtang
% �ú������������ڰ������ö��źŽ�����Ƭ��

% ����ԭ��
% ��ԭʼ���ź�����˸��ʼʱ��Ϊ��㣬��ȡbaseline_win��������䷶Χ�ź���Ϊ�����Ĳο��źš�
% ��ȡwindow��������䷶Χ��Ϊ��˸��Ӧ��ԭʼ�źš������Ӧԭʼ�źż�ȥ�ο��źţ��õ�У��
% ����Ӧ�ź���Ϊ���յ�������
% ps:�źž������˲�����

% ����˵����
% signal_p300:ԭʼ�źš�num*channels,ÿһ�д���һ��ͨ�����źš�
% trialnr:��ÿ���źŵȳ�����¼�˵�ǰ����trial��
% window��ָ���Ľ�ȡ�źŵ���ʼλ�õ���ֹλ�á�
% baseline_win:��׼�ߴ��ڡ���������Ϊ��׼�ο����źŽ�ȡλ�á�

% ����ֵ��
% Response.Response:�źš�N*windowlen*channels������ÿһ����˸��Ӧһ���ź�������ÿ�������ĳ��Ⱦ���window�޶��ĳ��ȡ�
% Responses.Code����¼�˵�ǰ��˸�ı��
% Responses.Type����¼�˵�ǰ��˸�Ƿ�Ϊָ��ѵ��Ŀ�꣬target��
% Responses.trial����¼�˵�ǰ����trial��

fprintf(1,'extracting samples...\n');
Num = fir1(32,[0.05 25]./100);
%load BP_0.1_30_n96.mat                             %���߱�����˲�������0.10-30Hz��ͨ�˲���
signal_p300_filtered = filter(Num,1,signal_p300);   %�ź��˲�    
baseline_win = round(baseline_win*samplingrate);    %�źŻ�׼����
numchannels_p300 = size(signal_p300_filtered,2);    %P300�ź�ͨ������
numflash = length(StimulusCode);                    %��˸������    
% ind = find(diff(StimulusCode)>1)+1;               %�ҵ�ÿ����˸����ʼλ��
ind = find(StimulusCode(1:numflash-1)==0 & StimulusCode(2:numflash)>=1)+1;    %�ҵ�ÿ����˸����ʼλ�á�������ԭ����д����ɬ,�������������м�û�����0������ǳ����ã� 
% ind = ind(find(ind+window(2)-2<=numflash));      %��֤���һ����˸��Ӧ���ź���Ȼ�ܹ��ۼ��㹻һ���źŴ��ĳ��ȡ����ڶ��ļ�������Ȼ����ȫ��

% ��¼��ÿ����˸��ʼʱ��֮��window(1)��window(2)֮����ź���Ϊ������
% �ɼ�window�����ý�Ϊ���������Ķ����ź���Ƭ����˸֮��Ĺ�ϵ���磺����˸��ʼʱ���𣿻���˸����𣿣���
% ���⣬���ص��ź���Ƭ�Ѿ������˴�ͨ�˲���������ÿһ���ź���Ƭ����ȥ����˸֮ǰһ��ʱ�䣨��samplingrate��baseline_win���ƣ�
% �źŵ�ƽ��ֵ���������������źŵ�����Ư�ơ�
xx = length(ind);
Responses.Responses = zeros(xx,window(2)-window(1),numchannels_p300,'single');
for kk = 1:xx
    slice = signal_p300_filtered(ind(kk)+window(1)-1:ind(kk)+window(2)-2,:);
    mean_bl = mean(signal_p300_filtered(ind(kk)+baseline_win(1):ind(kk)+baseline_win(2),:));
    baseline = repmat(mean_bl,size(slice,1),1);
    Responses.Responses(kk,:,:) = slice - baseline;
end

Responses.Code = StimulusCode(ind);     %code����ʱ��˳���¼��flash�ı��
Responses.Type = StimulusType(ind);     %type��¼�˵�ǰ�Ƿ�Ϊ����Ŀ��
Responses.trial = trialnr(ind);
Responses.p3filter = Num;
fprintf(1,'...Done\n');


