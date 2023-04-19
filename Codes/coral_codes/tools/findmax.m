function [xmax,ymax,index]=findmax(x,y);
%   findmax       interpolate to find maximum value
% usage: [xmax,ymax,index]=findmax(x,y);
%
% Find the maximum value of y and the corresponding value of x by first finding
% the maximum value of y, then fitting a second order polynomial to the three
% points nearest this maximum value. Return x,y values at the peak of the 
% polynomial. index is a row vector containing the indices of the peak values
% of y.  x and y must be column vectors (or an array of column vectors) of the
% same dimension.  xmax and ymax are row vectors, containing the same number of
% rows as x and y.

[n,m]=size(y);
cnt = 0;
for i=1:m;                               % loop over each column
  k=find(y(:,i)==ones(n,1)*max(y(:,i))); % find the index of the max of y 
  index(i)=k(1);                         % save the index
  if (k(1)-1) > 0 & (k(1)+1) < n,
    cnt = cnt + 1;
    ind=[k(1)-1:k(1)+1]';              % index for three points near peak
    p=polyfit(x(ind,i),y(ind,i),2);    % fit a parabola to points near peak
    xmax(cnt)=-p(2)/(2*p(1));          % x value at maximum value of parabola
    ymax(cnt)=polyval(p,xmax);         % calculate ymax
  end;
end;
