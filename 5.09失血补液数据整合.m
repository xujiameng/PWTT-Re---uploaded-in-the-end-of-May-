%%% 5.09ʧѪ��Һ��������

clear all
clc
%% data_label1  ע�䰢��Ʒ����  ����������
load 'D:/test/ʵ�����������/dataתmat���ݴ���/5.09_data_2.mat';
data=data((55*60+09)*1000:(74*60+02)*1000,:);
delect=[ 496000,length(data);262000,318000];
for i=1:length(delect)
    data(delect(i,1):delect(i,2),:)=[];
end


%% data_label2  ʧѪ����   PPG�����쳣
load 'D:/test/ʵ�����������/dataתmat���ݴ���/5.09_data_2.mat';
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

%% data_label3  ʧѪ����  
load 'D:/test/ʵ�����������/dataתmat���ݴ���/5.09_data_2.mat';
data=data(( 153*60+11)*1000:(156*60+18)*1000,:); 
data_label2=data;

%% data_label4  ��Һ����  
load 'D:/test/ʵ�����������/dataתmat���ݴ���/5.09_data_2.mat';
data=data(( 247*60+49)*1000:end,:); 
delect=[ 280000-60*1000,295000-60*1000];
for i=1:size(delect,1)
    data(delect(i,1):delect(i,2),:)=[];
end


data_label3=data;

%% ����
clear data
data=[data_label1; data_label2];
