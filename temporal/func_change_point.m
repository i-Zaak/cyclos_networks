function func_change_point(data)
% change-point detection - create data in wanted format here, the code for
% change-point detection in python
% 
% Eva Bujnoskova, August 2014

datadir = 'data';
mkdir(datadir);

fileName = [datadir,filesep,'names_network.lut'];
inputfile = fopen(fileName,'w+');

fprintf(inputfile,'virtual\treal\n');
for i = 1:size(data(1).m,1)
    fprintf(inputfile,'%d\t%d\n',i-1,i);
end

fclose(inputfile);


for i = 1:size(data,2)  % for each time window
    matrix = data(i).m;
    [node1,node2] = find(matrix~=0);
    
    if i<10
        fileName = [datadir,filesep,'network0',num2str(i),'.pairs'];
    else
        fileName = [datadir,filesep,'network',num2str(i),'.pairs'];
    end
    inputfile = fopen(fileName,'w+');
    
    if node1>0
        for j = 1:length(node1)
            fprintf(inputfile,'%d\t%d\n',node1(j),node2(j));
        end
    end
    
    fclose(inputfile);
end