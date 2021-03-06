function MUD=tjs_SWLDA(Responses,Type,windowlen,varargin)
% arranged by mrtang on 2015.4.23

% 原理说明：
% 对整理得到的信号样本（带标记）进行多元线性回归分析。对数据进行自变量筛选拟合，得到拟合超平面。
% 最终的输出是该拟合超平面的权值系数。将得到的信号代入到该超平面中，就能计算得到一个输出，输出越大
% 说明与超平面的贴合越好，即信号估计为目标响应的概率越大。
% ps:尽管在多元回归分析时，使用的是均值滤波和降采样之后的信号。但输出的权值系数已经铺展到了原始维度上。
% 即在线使用时，只需要将多通道信号进行首尾连接形成一维向量之后就能直接运用权值系数进行计算了。

% 参数说明
% 前3个参数必选。可选参数的顺序为：MAfilter,DecFact,penter,premove,maxiter,method

% responses:信号样本, 样本数量*样本点数*样本通道数
% MAfilter & DecFact:该程序需要对信号进行降采样从而实现特征降维。首先对信号进行均值滤波，再降采样。
% MAfiltre:均值滤波窗口长度。re:10
% DecFact:降采样间隔。re:10
% re: 降采样间隔应当设置大于均值滤波窗口长度。否则本文中采用的将降采样训练得到的权值铺展到原始维空间中计算的效果将会不一致。
% windowlen:[信号起始点 信号终止点]
% tresponse:特征向量，使用tjs_getP3_fevector获得
% type:样本标记
% penter,premove：分别用于控制逐步回归分析显著性水平
% maxiter：逐步回归分析的相关参数

% 返回值
% 输出MUD，为一个列向量，长度是 通道数*窗口长度。在线时将得到的多通道数据首尾相连后可直接与MUD乘而得到得分。

%% 参数读取
arglst = {'MAfilter','DecFact','penter','premove','maxiter','method'};
%默认情况下
MAfilter=10;
DecFact=10;
penter=0.1;
premove=0.15;
maxiter=60;
method=1;
% 如果有修改默认参数的需要，则需要按照指定顺序给出，并且其左侧参数的值也必须给出。
% 默认参数按照所列顺序，依次赋新值。
for i=1:length(varargin)
    eval([arglst{i} '=' num2str(varargin{i})]);                         
end

%% 特征提取
numchannels = size(Responses,3);                                                %信号通道数量
first=ceil(((MAfilter-1)/DecFact)+1);                                           %考虑到滤波初段畸变，去掉信号头部。这里依据滤波设置，计算起始点。
xx=size(Responses,1);                                                           %信号样本的数量
sizex=(length(1:DecFact:[windowlen(2)-windowlen(1)])-first+1)*numchannels;      %最终特征向量的维数。即单个通道降采样之后的点数*通道数。
tresponse=zeros(xx,sizex);
for hh=1:xx
    dresponse=filter(ones(1,MAfilter)/MAfilter,1,Responses(hh,:,:));            %均值滤波
    dresponse=dresponse(1,1:DecFact:[windowlen(2)-windowlen(1)],:);             %降采样
    tresponse(hh,:)=reshape(dresponse(1,first:size(dresponse,2),:),1,sizex);    %形成最终的一维特征向量，并去掉了头部信号。
end

%% 标记整理
Type = double(Type);
target=find(Type==1);           %目标标记
standard=find(Type==0);         %非目标标记
indtn=[target;standard];        
data=tresponse(indtn,:);        %统一信号。目标信号在前，非目标信号在后。
Label=2*(Type(indtn)-.5);       %将0/1标记整理为-1/1。

%% 多元线性回归分析
% stepwisefit：逐步回归分析。penter,premove控制显著性评价水平。
% 返回：in内存放的是显著性分量,将没有贡献的分量剔除。B存放的是各分量拟合权值。
% 配合显著性分量对应的权值就构成了拟合公式，使用拟合公式对输入信号进行加权求和就能计算出一个结果，
% 我们称之为得分。显然，与模型的匹配度越高，求和的得分也越高。因此我们通过判断得分的高低来作为目
% 标的估计。因此，在后面看到对Variables进行了一些列的线性变换，这对最终的结果并没有影响。

switch method
    case 1 %SWLDA
        fprintf(1, 'Stepwise Regression...\n');   
        [B,SE,PVAL,in] = stepwisefit(data,Label,'maxiter',maxiter,'display','off','penter',penter,'premove',premove);   %maxiter=60;penter=0.1;premove=0.15
    case 2 % Least Squares
        fprintf(1, 'Least Squares Regression...\n');
        B=regress(Label,[data ones(1,size(data,1))']);
        B=B(1:length(B)-1);
        in=ones(1,length(B));
    case 3 % Logistic
        fprintf(1, 'Logistic Regression...\n');
        B=robustfit(data,Label,'logistic');
        B=B(2:length(B));
        in=ones(1,length(B));
end

%% 参数的生成
% 由于已经生成了拟合公式（即一组权值系数），在进行估计时可以按照分析程序的流程，对信号进行均值滤波，降采样，再直接运用该拟合公式。
% 但是考虑到对信号进行均值滤波计算量相对较大（关键是均值滤波是重叠卷积的，再进行降采样，也就意味着浪费了90%的计算）。我们可以考虑
% 将权值系数铺展到原始信号维空间上去。这样计算的效果一致，且只需要进行简单矩阵乘。注意这里的前提条件是降采样间隔大于均值滤波窗口长度。         
index= in~=0;
Variables=B(index);
Variables=10*Variables/max(abs(Variables));             % 由于分类时只按照得分高低排序，而不使用绝对值，因而对Variable的线性变换都是可以接受的。 
Variables = Variables/norm(Variables);                  % 归一化
chin=reshape(in,length(in)/numchannels,numchannels);
[samp,ch]=find(chin==1);
chused=unique(ch);
newind=windowlen(1)+(samp+first-2)*DecFact;
for rr=1:length(chused);
    idx=find(ch==chused(rr));
    ch(idx)=rr*ones(1,length(idx));
end

MUD=[];
hh=1;
for gg=1:size(Variables,1)
    MUD(hh:hh+MAfilter-1,1)=ch(gg)*ones(1,MAfilter);
    MUD(hh:hh+MAfilter-1,2)=newind(gg)-MAfilter+1:newind(gg);
    MUD(hh:hh+MAfilter-1,3)=Variables(gg)*ones(1,MAfilter);
    hh=hh+MAfilter;
end
MUD(:,2) = MUD(:,2) - windowlen(1) + (MUD(:,1)-1) * (windowlen(2)-windowlen(1));  % 原先记录的是在各自通道上的位置，通过计算得到信号首尾相连之后的位置。
tem = zeros(numchannels*(windowlen(2)-windowlen(1)),1);
tem(MUD(:,2)+1)=MUD(:,3);
MUD = [];
MUD = tem;  % 至此，MUD是一个列向量，长度是 通道数*窗口长度。在线时将得到的多通道数据首尾相连后可直接与MUD乘而得到得分。
fprintf(1, '...Done\n');
