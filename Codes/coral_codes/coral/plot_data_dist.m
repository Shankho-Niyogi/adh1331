function plot_data_dist(stimes,etimes,qtimes,index2);
%   plot_data_dist  plot seismogram start times and earthquake times
% usage: plot_data_dist(stimes,etimes,qtimes,index2);

n=length(stimes(1,:));
m=length(index2);
if m>0,
  times=timediff([stimes etimes qtimes(:,index2)])/3600;
else
  times=timediff([stimes etimes])/3600;
end
sttimes=[times(1:n);times(n+1:2*n)];
ytimes =[1:n;1:n];

if m>0, 
  qqtimes=[times(2*n+1:2*n+m);times(2*n+1:2*n+m)];
  qytimes=[ones(1,m);ones(1,m)*n];
  plot(sttimes,ytimes,qqtimes,qytimes);
else
   plot(sttimes,ytimes);
end
xlabel('time in hours')
ylabel('seismogram number')
title('data and event times') 
