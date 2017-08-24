function Responses = ly_tjs_GetP3Responses(signal_p300,trialnr,window,StimulusCode,StimulusType, samplingrate, baseline_win)
% annotate by mrtang
% 该函数的作用在于按照设置对信号进行切片。

% 基本原理：
% 对原始列信号自闪烁开始时刻为起点，截取baseline_win定义的区间范围信号作为样本的参考信号。
% 截取window定义的区间范围作为闪烁响应的原始信号。最后将响应原始信号减去参考信号，得到校正
% 的响应信号作为最终的样本。
% ps:信号经过了滤波处理。

% 参数说明：
% signal_p300:原始信号。num*channels,每一列代表一个通道的信号。
% trialnr:与每列信号等长。记录了当前所属trial。
% window：指定的截取信号的起始位置到终止位置。
% baseline_win:基准线窗口。定义了作为基准参考的信号截取位置。

% 返回值：
% Response.Response:信号。N*windowlen*channels。即，每一个闪烁对应一个信号样本。每个样本的长度就是window限定的长度。
% Responses.Code：记录了当前闪烁的编号
% Responses.Type：记录了当前闪烁是否为指定训练目标，target。
% Responses.trial：记录了当前所在trial。

fprintf(1,'extracting samples...\n');
Num = fir1(32,[0.05 25]./100);
%load BP_0.1_30_n96.mat                             %离线保存的滤波参数，0.10-30Hz带通滤波。
signal_p300_filtered = filter(Num,1,signal_p300);   %信号滤波    
baseline_win = round(baseline_win*samplingrate);    %信号基准窗口
numchannels_p300 = size(signal_p300_filtered,2);    %P300信号通道数量
numflash = length(StimulusCode);                    %闪烁的数量    
% ind = find(diff(StimulusCode)>1)+1;               %找到每次闪烁的起始位置
ind = find(StimulusCode(1:numflash-1)==0 & StimulusCode(2:numflash)>=1)+1;    %找到每次闪烁的起始位置。（来自原程序，写法晦涩,但对于任务标记中间没有填充0的情况非常有用） 
% ind = ind(find(ind+window(2)-2<=numflash));      %保证最后一个闪烁对应的信号仍然能够累计足够一个信号窗的长度。对于多文件数据仍然不安全。

% 记录了每次闪烁开始时刻之后window(1)到window(2)之间的信号作为样本。
% 可见window的设置较为灵活。可以灵活的定义信号切片与闪烁之间的关系（如：从闪烁开始时刻起？或闪烁完成起？）。
% 另外，返回的信号切片已经经过了带通滤波处理。并且每一个信号切片都减去了闪烁之前一段时间（由samplingrate和baseline_win控制）
% 信号的平均值，作用在于消除信号的整体漂移。
xx = length(ind);
Responses.Responses = zeros(xx,window(2)-window(1),numchannels_p300,'single');
for kk = 1:xx
    slice = signal_p300_filtered(ind(kk)+window(1)-1:ind(kk)+window(2)-2,:);
    mean_bl = mean(signal_p300_filtered(ind(kk)+baseline_win(1):ind(kk)+baseline_win(2),:));
    baseline = repmat(mean_bl,size(slice,1),1);
    Responses.Responses(kk,:,:) = slice - baseline;
end

Responses.Code = StimulusCode(ind);     %code按照时间顺序记录了flash的编号
Responses.Type = StimulusType(ind);     %type记录了当前是否为任务目标
Responses.trial = trialnr(ind);
Responses.p3filter = Num;
fprintf(1,'...Done\n');


