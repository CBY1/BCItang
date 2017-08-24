function MUD=tjs_SWLDA(Responses,Type,windowlen,varargin)
% arranged by mrtang on 2015.4.23

% ԭ��˵����
% �������õ����ź�����������ǣ����ж�Ԫ���Իع�����������ݽ����Ա���ɸѡ��ϣ��õ���ϳ�ƽ�档
% ���յ�����Ǹ���ϳ�ƽ���Ȩֵϵ�������õ����źŴ��뵽�ó�ƽ���У����ܼ���õ�һ����������Խ��
% ˵���볬ƽ�������Խ�ã����źŹ���ΪĿ����Ӧ�ĸ���Խ��
% ps:�����ڶ�Ԫ�ع����ʱ��ʹ�õ��Ǿ�ֵ�˲��ͽ�����֮����źš��������Ȩֵϵ���Ѿ���չ����ԭʼά���ϡ�
% ������ʹ��ʱ��ֻ��Ҫ����ͨ���źŽ�����β�����γ�һά����֮�����ֱ������Ȩֵϵ�����м����ˡ�

% ����˵��
% ǰ3��������ѡ����ѡ������˳��Ϊ��MAfilter,DecFact,penter,premove,maxiter,method

% responses:�ź�����, ��������*��������*����ͨ����
% MAfilter & DecFact:�ó�����Ҫ���źŽ��н������Ӷ�ʵ��������ά�����ȶ��źŽ��о�ֵ�˲����ٽ�������
% MAfiltre:��ֵ�˲����ڳ��ȡ�re:10
% DecFact:�����������re:10
% re: ���������Ӧ�����ô��ھ�ֵ�˲����ڳ��ȡ��������в��õĽ�������ѵ���õ���Ȩֵ��չ��ԭʼά�ռ��м����Ч�����᲻һ�¡�
% windowlen:[�ź���ʼ�� �ź���ֹ��]
% tresponse:����������ʹ��tjs_getP3_fevector���
% type:�������
% penter,premove���ֱ����ڿ����𲽻ع����������ˮƽ
% maxiter���𲽻ع��������ز���

% ����ֵ
% ���MUD��Ϊһ���������������� ͨ����*���ڳ��ȡ�����ʱ���õ��Ķ�ͨ��������β�������ֱ����MUD�˶��õ��÷֡�

%% ������ȡ
arglst = {'MAfilter','DecFact','penter','premove','maxiter','method'};
%Ĭ�������
MAfilter=10;
DecFact=10;
penter=0.1;
premove=0.15;
maxiter=60;
method=1;
% ������޸�Ĭ�ϲ�������Ҫ������Ҫ����ָ��˳���������������������ֵҲ���������
% Ĭ�ϲ�����������˳�����θ���ֵ��
for i=1:length(varargin)
    eval([arglst{i} '=' num2str(varargin{i})]);                         
end

%% ������ȡ
numchannels = size(Responses,3);                                                %�ź�ͨ������
first=ceil(((MAfilter-1)/DecFact)+1);                                           %���ǵ��˲����λ��䣬ȥ���ź�ͷ�������������˲����ã�������ʼ�㡣
xx=size(Responses,1);                                                           %�ź�����������
sizex=(length(1:DecFact:[windowlen(2)-windowlen(1)])-first+1)*numchannels;      %��������������ά����������ͨ��������֮��ĵ���*ͨ������
tresponse=zeros(xx,sizex);
for hh=1:xx
    dresponse=filter(ones(1,MAfilter)/MAfilter,1,Responses(hh,:,:));            %��ֵ�˲�
    dresponse=dresponse(1,1:DecFact:[windowlen(2)-windowlen(1)],:);             %������
    tresponse(hh,:)=reshape(dresponse(1,first:size(dresponse,2),:),1,sizex);    %�γ����յ�һά������������ȥ����ͷ���źš�
end

%% �������
Type = double(Type);
target=find(Type==1);           %Ŀ����
standard=find(Type==0);         %��Ŀ����
indtn=[target;standard];        
data=tresponse(indtn,:);        %ͳһ�źš�Ŀ���ź���ǰ����Ŀ���ź��ں�
Label=2*(Type(indtn)-.5);       %��0/1�������Ϊ-1/1��

%% ��Ԫ���Իع����
% stepwisefit���𲽻ع������penter,premove��������������ˮƽ��
% ���أ�in�ڴ�ŵ��������Է���,��û�й��׵ķ����޳���B��ŵ��Ǹ��������Ȩֵ��
% ��������Է�����Ӧ��Ȩֵ�͹�������Ϲ�ʽ��ʹ����Ϲ�ʽ�������źŽ��м�Ȩ��;��ܼ����һ�������
% ���ǳ�֮Ϊ�÷֡���Ȼ����ģ�͵�ƥ���Խ�ߣ���͵ĵ÷�ҲԽ�ߡ��������ͨ���жϵ÷ֵĸߵ�����ΪĿ
% ��Ĺ��ơ���ˣ��ں��濴����Variables������һЩ�е����Ա任��������յĽ����û��Ӱ�졣

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

%% ����������
% �����Ѿ���������Ϲ�ʽ����һ��Ȩֵϵ�������ڽ��й���ʱ���԰��շ�����������̣����źŽ��о�ֵ�˲�������������ֱ�����ø���Ϲ�ʽ��
% ���ǿ��ǵ����źŽ��о�ֵ�˲���������Խϴ󣨹ؼ��Ǿ�ֵ�˲����ص������ģ��ٽ��н�������Ҳ����ζ���˷���90%�ļ��㣩�����ǿ��Կ���
% ��Ȩֵϵ����չ��ԭʼ�ź�ά�ռ���ȥ�����������Ч��һ�£���ֻ��Ҫ���м򵥾���ˡ�ע�������ǰ�������ǽ�����������ھ�ֵ�˲����ڳ��ȡ�         
index= in~=0;
Variables=B(index);
Variables=10*Variables/max(abs(Variables));             % ���ڷ���ʱֻ���յ÷ָߵ����򣬶���ʹ�þ���ֵ�������Variable�����Ա任���ǿ��Խ��ܵġ� 
Variables = Variables/norm(Variables);                  % ��һ��
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
MUD(:,2) = MUD(:,2) - windowlen(1) + (MUD(:,1)-1) * (windowlen(2)-windowlen(1));  % ԭ�ȼ�¼�����ڸ���ͨ���ϵ�λ�ã�ͨ������õ��ź���β����֮���λ�á�
tem = zeros(numchannels*(windowlen(2)-windowlen(1)),1);
tem(MUD(:,2)+1)=MUD(:,3);
MUD = [];
MUD = tem;  % ���ˣ�MUD��һ���������������� ͨ����*���ڳ��ȡ�����ʱ���õ��Ķ�ͨ��������β�������ֱ����MUD�˶��õ��÷֡�
fprintf(1, '...Done\n');