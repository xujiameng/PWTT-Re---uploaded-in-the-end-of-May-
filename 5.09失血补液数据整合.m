%%% 5.09失血补液数据整合

clear all
clc
%% data_label1  注射阿托品部分  数据质量差
load 'D:/test/实验数据与程序/data转mat数据处理/5.09_data_2.mat';
data=data((55*60+09)*1000:(74*60+02)*1000,:);
delect=[ 496000,length(data);262000,318000];
for i=1:length(delect)
    data(delect(i,1):delect(i,2),:)=[];
end


%% data_label2  失血部分   PPG整段异常
load 'D:/test/实验数据与程序/data转mat数据处理/5.09_data_2.mat';
data=data((103*60+16)*1000:(132*60+30)*1000,:);
delect=[ 1480000,1495000;1,1330000];
for i=1:length(delect)
    data(delect(i,1):delect(i,2),:)=[];
end
clear delect
delect=[ 379000,382000;298000,302000;30000,35000];
for i=1:length(delect)
    data(delect(i,1):delect(i,2),:)=[];
end
data_label1=data;

%% data_label3  失血部分  
load 'D:/test/实验数据与程序/data转mat数据处理/5.09_data_2.mat';
data=data(( 153*60+11)*1000:(156*60+18)*1000,:); 
data_label2=data;

%% data_label4  补液部分  
load 'D:/test/实验数据与程序/data转mat数据处理/5.09_data_2.mat';
data=data(( 247*60+49)*1000:end,:); 
delect=[ 280000-60*1000,295000-60*1000];
for i=1:size(delect,1)
    data(delect(i,1):delect(i,2),:)=[];
end


data_label3=data;

%% 整合
clear data
data=[data_label1; data_label2];
