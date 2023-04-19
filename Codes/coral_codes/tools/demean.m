function d1=demean(d);
%   demean        remove mean from columns of matrix
% usage: d1=demean(d);

[n,m]=size(d);
meand=mean(d);
for ii=1:m
  d1(:,ii)=d(:,ii)-meand(ii);
end;
