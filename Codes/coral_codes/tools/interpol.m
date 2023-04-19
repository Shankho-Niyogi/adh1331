function [y0]=interpol(x,y,x0);
%   interpol      linear interpolation
% usage: [y0]=interpol(x,y,x0);
% interpolate or extrapolate y(x) linearly at the points x0
% x,y,x0 must be column vectors, x and y must be the same size
% x must be either increasing or decreasing monotonically
%

% check size of input arrays
[nx,mx]=size(x); [ny,my]=size(y); [nx0,mx0]=size(x0); 
if (mx >1), disp('ERROR: x must be a column vector'); return; end
if (my >1), disp('ERROR: y must be a column vector'); return; end
if (mx0>1), disp('ERROR: x0 must be a column vector'); return; end
if (nx~=ny),disp('ERROR: x and y must be the same size');size(x),size(y),return; end

% if x is monotonically decreasing, multiply x and x0 by -1
% to force x to be monotonically increasing
if x(2)<x(1),
  x=-x;x0=-x0;
end

% check to see that x is monotonically increasing
if diff(x)>0, 
else, 
  disp('ERROR: x is neither increasing, nor decreasing monotonically');
  plot(x);
  [x,y]
  return
end

% for each x0, find indices in x corresponding to first value < x0
i=zeros(size(x0));
for j=1:nx0
  temp=find(x0(j)>x);
  if length(temp)==0,
    i(j)=1;
  else
    i(j)=max(temp);
  end
end
i=max(1,i);  i=min(nx-1,i);    %  adjust indices for extrapolation
y0 = y(i) + (y(i+1)-y(i)) .* (x0-x(i)) ./ (x(i+1)-x(i));

