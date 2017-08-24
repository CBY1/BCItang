function result = tjs_p3_predict(Responses,scores,cube_dim)
% written by mrtang on 2015.4.24

% 基本原理：
% 预测每个trial的目标，和统计相应正确率

% 参数说明：
% Responses:主要使用到的是code、type、trial。
% scores:使用SWLDA拟合公式对每个样本输出的得分向量。

%返回值
resultstr = {'pre_target' 'task_target' 'prow' 'pcol' 'p' 'trial'};     %预测目标，任务目标，行准确率，列准确率，总体准确率,trial标号
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
                                      
for j = 1:trialnum     %逐trial分析
    temcode = Responses.Code(Responses.trial==j);       %当前trial的code
    temptype = Responses.Type(Responses.trial==j);      %当前trial的type
    tar = unique(temcode(temptype==1))';                %当前trial的目标tar
    if rownum==1
        tar = [1,tar];
    end
    if colnum==1
        tar = [tar,rownum+colnum];
    end        
    temp = [scores(Responses.trial==j),temcode];
    maxr = -inf;                                        %记录行的最高得分
    pr = -1;                                            %记录预测的行
    maxc = -inf;                                        %记录列的最高得分
    pc = -1;                                            %记录预测的列
    
    for jj = 1:rownum                                   %分析行
        temx = sum(temp(temp(:,2)==jj,1));
        if temx > maxr                                  %冒泡排序
            maxr = temx;
            pr = jj;
        end
    end
    
    for kk = 1+cube_dim(1):cube_dim(1)+colnum           %分析列
        temx = sum(temp(temp(:,2)==kk,1));
        if temx > maxc                                      %冒泡排序
            maxc = temx;
            pc = kk;
        end
    end

    result.pre_target = [result.pre_target;[pr,pc]];    %记录了预测的行列标号
    result.task_target = [result.task_target;tar];      %任务的实际行列标号
    result.trial = [result.trial;j];                    %trial标号
end
st = result.pre_target==result.task_target;
result.prow = sum(st(:,1))/size(st,1);                  %行预测准确率
result.pcol = sum(st(:,2))/size(st,1);                  %列预测准确率
result.p = sum(st(:,1).*st(:,2))/size(st,1);            %总体预测准确率
fprintf(1,'...Done\n');
fprintf(1,'the row predicting correct rate: %8.1f%%\n',result.prow*100);
fprintf(1,'the column predicting correct rate: %5.1f%%\n',result.pcol*100);
fprintf(1,'the target predicting correct rate: %5.1f%%\n',result.p*100);
end
  