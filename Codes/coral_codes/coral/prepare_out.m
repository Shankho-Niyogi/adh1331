function [Data_out,Extras_out,Record_out,Comment_out,Calib_out,Loc_out,Station_out]= ...
      prepare_out(Data,Extras,Record,Comment,Calib,Loc,Station,data1,header1,label1,obs1);
%   prepare_out   convert coral data to internal AH format
% USAGE: [Data_out,Extras_out,Record_out,Comment_out,Calib_out,Loc_out,Station_out]= ...
%     prepare_out(Data,Extras,Record,Comment,Calib,Loc,Station,data1,header1,label1,obs1);
%  updates derived parameters using data read from AH file

Index=header1(5,:);
Data_out=data1;
[ndata,ntrace]=size(Data_out);
Station_out=Station(:,Index);
Calib_out=Calib(:,Index);
Loc_out=Loc(:,Index);
Comment_out=Comment(:,Index);
Record_out=Record(:,Index);
Extras_out=Extras(:,Index);
Extras_out(7:12,:)=header1(7:12,:);
Extras_out(13:20,:)=obs1(1:8,:);
semi=zeros(1,ntrace)+abs(';');
Comment_out(161:362,:)=[abs(label1(17:30,:)) ; semi ; Comment_out(161:347,:)];
%Comment_out(161:174,:)=abs(label1(17:30,:));

Record_out(1:2,:)=timeadd(Loc_out(7:8,:),header1(1,:)); % absolute time of first sample
Record_out(3,:)=ndata*ones(1,ntrace);                   % number of data
Record_out(4,:)=header1(6,:);                           % sample interval
Record_out(5,:)=max(abs(Data_out));                     % maximum amplitude of each trace
Record_out(6,:)=zeros(1,ntrace);                        % offset time for display???

