function data_out=integrate_part(data,header,sintr);
%   integrate_part integrate coral data
% USAGE: data_out=integrate_part(data,header,sintr);
% 
% integrate data that are stored in columns of data array
% the data array may be padded at the start or end with zeros
% as defined in header.  integrate the real data only
% and leave the zero padding untouched
% data and header are arrays with one column per seismogram
% see update_data for a description of 'header'
% sintr is a vector of sample intervals (samples/sec).

[n,m]=size(data);
data_out=data;
[istart,iend]=find_nonzero(header);
for i=1:m
  index  = istart(i):iend(i);
  dd=data(index,i);
  data_out(index,i)=(cumsum(dd)-(dd(1)+dd)/2)*sintr(i);
end;
