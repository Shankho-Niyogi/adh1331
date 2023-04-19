function [data]=deglitch(data,n,m);
%   deglitch      remove a glitch
% USAGE: [data]=deglitch(data,n,m);
% deglitches the mth trace in a data matrix whose data traces are stored
%  by column...n is the number of glitches to remove
for k = 1:n,
  [x,index]=sort(-abs(diff(data(:,m))));
  i=max(index(1:2));
  x=[1 2 3 5 6 7]';
  y=[data(i-3:i-1,m);data(i+1:i+3,m)];
  y4=polyval(polyfit(x,y,5),4);
  data(i,m)=y4;
end
