function [s,t,dt]=slantstack(d,srate,x,y);
% USAGE: [s,t,dt]=slantstack(d,srate,x,y);
%
% input parameters:
% d = array of column vectors of data (nxm)
% srate=sample rate (Hz)
% x = m-vector containing distance or ray parameter etc for each seismogram
% y = l-vector containing stacking parameter
%     stack time shifts are x*y/srate
%
% output parameters:
% s = array of column vectors of slant stacks (n1xl)
%     n1=n+dtmax-dtmin where dt are the time shifts
% t = time vector of s assuming the first point in the data series start at
%     time equals zero.
% dt= time shifts

[n,m]=size(d);
l=length(y);
slowrate=y/srate;
dt=zeros(m,l);

for im=1:m; dt(im,:)=round(x(im)*slowrate); end;

dtmin=min(min(dt));
dtmax=max(max(dt));
n1=n+dtmax-dtmin;
s=zeros(n1,l);
for il=1:l
  for im=1:m
    index=[1:n]+dt(im,il)-dtmin;
    s(index,il)=s(index,il)+d(:,im);
  end
end
s=s/m;
t=([0:n1-1]'+dtmin)*srate;


