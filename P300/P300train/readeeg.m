function [Info,EEG,State] = readeeg(file)
    book = [17,9,6,14,14,8];
    name = {'ExperimentName','SubjectName','Time','SamplingRate','EEGChannels','State'};
    fid = fopen(file,'r');
    
    for i=1:6
        con = fgetl(fid);
        Info.(name{i})=con(book(i):end);
    end
    
    Info.SamplingRate = str2double(Info.SamplingRate);
    Info.EEGChannels = str2double(Info.EEGChannels);
    str = Info.State;
    tem = Info.State(find(str=='[')+1:find(str==']')-1);
    iind = find(tem==char(39));
    Info.State = {};
    c = 1;
    for i=1:2:length(iind)
        Info.State{c}=tem(iind(i)+1:iind(i+1)-1);
        c=c+1;
    end

    rows = Info.EEGChannels + length(Info.State);
    data = fread(fid,inf,'double');
    columns = length(data)/rows;
    if columns~=floor(columns)
        columns = floor(columns);
        data = data(1:columns*rows);
    end
    
    data = reshape(data,rows,columns);
    EEG = data(1:Info.EEGChannels,:);
    for i=1:length(Info.State)
        State.(Info.State{i})=int32(data(Info.EEGChannels+i,:));
    end
    fclose(fid); 
end
        