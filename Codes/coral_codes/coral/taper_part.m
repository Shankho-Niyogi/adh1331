function data_out=taper_part(data,header,f);
%   taper_part    taper coral data
% USAGE: data_out=taper_part(data,header,f);
% 
% taper the columns of data array with an f% cosine taper
% eg. taperd(d,.05) tapers 5% from the beginning and end of
% the time series.
% the data array may be padded at the start or end with zeros
% as defined in header.  taper only the data, and leave the zero 
% padding untouched.
% see update_data for a description of 'header'

[n,m]=size(data);
data_out=data;
[istart,iend]=find_nonzero(header);
for i=1:m
  index  = istart(i):iend(i);
  n1=iend(i)-istart(i)+1;
  data_out(index,i)=data(index,i).*taper(n1,f);
end;
