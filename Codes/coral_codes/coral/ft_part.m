function [D,F]=ft_part(data,header);
%   ft_part       apply fourier transform to coral data
% USAGE: [D,F]=ft_part(data,header);
% 
% apply a fast fourier transform to the non-zero part of
% the data.  Zero pad the data to use a fast fourier transform.
% See ft
% D is the fourier transform and F are the frequencies

[n,m]=size(data);
N=2^nextpow2(n);
D=zeros(N,m);
F=D;
[istart,iend]=find_nonzero(header);
sintr=header(6,:);
for i=1:m
  index  = istart(i):iend(i);
  dd=data(index,i);
  N=2^nextpow2(length(dd));
  [DD,FF]=ft(dd,N,0,sintr(i));
  D(1:N,i)=DD;
  F(1:N,i)=FF;
end;
