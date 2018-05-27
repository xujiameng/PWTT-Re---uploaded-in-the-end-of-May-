%%% 5.09打药数据整合

clear all
clc
%% data_label1  降压部分
load 'D:/test/实验数据与程序/data转mat数据处理/5.09_data_1.mat';
data=data((110*60+45)*1000:(122*60+0)*1000,:);
delect=[ 496000,length(data);262000,318000];
for i=1:length(delect)
    data(delect(i,1):delect(i,2),:)=[];
end
clear delect
delect=[ 415000,length(data);355000,365000;342000,345000;260000,275000;130000,140000];
for i=1:length(delect)
    data(delect(i,1):delect(i,2),:)=[];
end
data_label1=data;

%% data_label2  降压部分
load 'D:/test/实验数据与程序/data转mat数据处理/5.09_data_1.mat';
data=data(( 123*60+46)*1000:(137*60+56)*1000,:); 
delect=[  822000,648000; 834000,792000;762000,766000;740000,750000;706000,710000;624000,662000;574000,578000;  300000,315000;154000,255000; 128000,138000 ];
for i=1:length(delect)
    data(delect(i,1):delect(i,2),:)=[];
end
data_label2=data;

% %% data_label3  升压部分  (ECG信号异常严重，无法处理)
% load 'D:/test/实验数据与程序/data转mat数据处理/5.09_data_2.mat';
% data=data(( 34*60+24)*1000:(43*60+12)*1000,:); 
% 
% data_label3=data;

%% data_label3  降压部分
load 'D:/test/实验数据与程序/data转mat数据处理/5.09_data_2.mat';
data=data(( 44*60+08)*1000:(51*60+07)*1000,:); 
delect=[ 324000,350000;300000,315000; 62000,74000 ];
for i=1:length(delect)
    data(delect(i,1):delect(i,2),:)=[];
end
clear delect
delect=[162000,166000 ];
for i=1:size(delect,1)
    data(delect(i,1):delect(i,2),:)=[];
end

data_label4=data;
%% 整合
clear data
data=[data_label1; data_label2; data_label4];
