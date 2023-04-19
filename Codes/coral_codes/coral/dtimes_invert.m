function [answer]=dtimes_invert(difftime,m);
%   dtimes_invert invert cross-correlation lag times for self-consistent set
% usage: [answer]=dtimes_invert(difftime,m);
%
%   difftime = column vector of differential arrival times (s)
%        (e.g. 2-1, 3-1, 4-1, 3-2, 4-2, 4-3) for m=4
%   m        = number of parameters in solution vector
%   answer   = column vector of self consistent differential times that
%               best fit the observed values.
%   (e.g. 1-0, 2-0, 3-0, 4-0 where m=4, and 0 denotes mean of 1,2,3,4.)

% construct A matrix

if m==1, answer=0; return; end;

mm=(m-1)*m/2;
A=zeros(mm,m);
k=0;
for i=1:m-1;
  for j=i+1:m;
    k=k+1;
    A(k,i)=-1;
    A(k,j)=1;
  end;
end;

% construct generalized inverse of A, note that it has one eigenvalue that
% is zero because there is an absolute time shift of all the seismograms
% which is unconstrained.  this mean value is set to zero in the definition
% of ddagger

[U,D,V]=svd(A,0);
d=diag(D);
ddagger= [1.0./d(1:(m-1));0];
answer=V*(ddagger.*(U'*difftime));
