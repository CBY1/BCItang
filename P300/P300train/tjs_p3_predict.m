function result = tjs_p3_predict(Responses,scores,cube_dim)
% written by mrtang on 2015.4.24

% ����ԭ��
% Ԥ��ÿ��trial��Ŀ�꣬��ͳ����Ӧ��ȷ��

% ����˵����
% Responses:��Ҫʹ�õ�����code��type��trial��
% scores:ʹ��SWLDA��Ϲ�ʽ��ÿ����������ĵ÷�������

%����ֵ
resultstr = {'pre_target' 'task_target' 'prow' 'pcol' 'p' 'trial'};     %Ԥ��Ŀ�꣬����Ŀ�꣬��׼ȷ�ʣ���׼ȷ�ʣ�����׼ȷ��,trial���
numstat = length(resultstr);
result = struct;
for dd = 1:numstat
    result.(char(resultstr(dd))) = [];
end

fprintf(1,'predicting...\n');
Responses.Code = double(Responses.Code);
trialnum = Responses.trial(end);
rownum = cube_dim(1);
colnum = cube_dim(2);
                                      
for j = 1:trialnum     %��trial����
    temcode = Responses.Code(Responses.trial==j);       %��ǰtrial��code
    temptype = Responses.Type(Responses.trial==j);      %��ǰtrial��type
    tar = unique(temcode(temptype==1))';                %��ǰtrial��Ŀ��tar
    if rownum==1
        tar = [1,tar];
    end
    if colnum==1
        tar = [tar,rownum+colnum];
    end        
    temp = [scores(Responses.trial==j),temcode];
    maxr = -inf;                                        %��¼�е���ߵ÷�
    pr = -1;                                            %��¼Ԥ�����
    maxc = -inf;                                        %��¼�е���ߵ÷�
    pc = -1;                                            %��¼Ԥ�����
    
    for jj = 1:rownum                                   %������
        temx = sum(temp(temp(:,2)==jj,1));
        if temx > maxr                                  %ð������
            maxr = temx;
            pr = jj;
        end
    end
    
    for kk = 1+cube_dim(1):cube_dim(1)+colnum           %������
        temx = sum(temp(temp(:,2)==kk,1));
        if temx > maxc                                      %ð������
            maxc = temx;
            pc = kk;
        end
    end

    result.pre_target = [result.pre_target;[pr,pc]];    %��¼��Ԥ������б��
    result.task_target = [result.task_target;tar];      %�����ʵ�����б��
    result.trial = [result.trial;j];                    %trial���
end
st = result.pre_target==result.task_target;
result.prow = sum(st(:,1))/size(st,1);                  %��Ԥ��׼ȷ��
result.pcol = sum(st(:,2))/size(st,1);                  %��Ԥ��׼ȷ��
result.p = sum(st(:,1).*st(:,2))/size(st,1);            %����Ԥ��׼ȷ��
fprintf(1,'...Done\n');
fprintf(1,'the row predicting correct rate: %8.1f%%\n',result.prow*100);
fprintf(1,'the column predicting correct rate: %5.1f%%\n',result.pcol*100);
fprintf(1,'the target predicting correct rate: %5.1f%%\n',result.p*100);
end
  