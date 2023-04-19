function [index,index2]=pick_event(stime,etime,qtimes,window);
%   pick_event    pick event from catalog given seismogram start/stop times
% Usage: [index,index2]=pick_event(stime,etime,qtimes,window);

% choose event time
time_diff=timediff([etime qtimes]);
time_diff=time_diff(2:length(time_diff));
index1=find(time_diff<0);                 % only consider events occurring before end time
time_diff=timediff([stime qtimes(:,index1)]);
time_diff=time_diff(2:length(time_diff));
index=find(time_diff==max(time_diff));     % choose event as last event to occur before the end of the record.
index=index1(index);
index2=find(time_diff >= window);
if length(index2>0), index2=index1(index2); end

