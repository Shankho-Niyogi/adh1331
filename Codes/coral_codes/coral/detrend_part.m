function data_out=detrend_part(data,header);
%   detrend_part  remove linear trend from coral data
% USAGE: data_out=detrend_part(data,header);
% 
% remove the trend from the columns of the data array
% the data array may be padded at the start or end with zeros
% as defined in header.  remove the trend of the real data only
% and leave the zero padding untouched
% data and header are arrays with one column per seismogram
% see update_data for a description of 'header'

[n,m]=size(data);
data_out=data;
[istart,iend]=find_nonzero(header);
for i=1:m
  index  = istart(i):iend(i);
  dd=data(istart(i):iend(i),i);
  data_out(istart(i):iend(i),i)=detrend(dd);
end;
