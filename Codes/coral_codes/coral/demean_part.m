function data_out=demean_part(data,header);
%   demean_part   remove mean from coral data
% USAGE: data_out=demean_part(data,header);
% 
% remove the mean from the columns of the data array
% the data array may be padded at the start or end with zeros
% as defined in header.  remove the mean of the real data only
% and leave the zero padding untouched
% data and header are arrays with one column per seismogram
% see update_data for a description of 'header'

[n,m]=size(data);
data_out=data;
[istart,iend]=find_nonzero(header);
for i=1:m
  index  = istart(i):iend(i);
  dd=data(index,i);
  data_out(index,i)=dd-mean(dd);
end;
