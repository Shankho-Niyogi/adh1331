function data_out=differentiate_part(data,header,sintr);
%   differentiate_part take derivative of coral data
% USAGE: data_out=differentiate_part(data,header,sintr);
% 
% differentiate data that are stored in columns of data array
% the data array may be padded at the start or end with zeros
% as defined in header.  differentiate the real data only
% and leave the zero padding untouched
% data and header are arrays with one column per seismogram
% see update_data for a description of 'header'
% sintr is a vector of sample intervals (samples/sec).

[n,m]=size(data);
data_out=data;
[istart,iend]=find_nonzero(header);
for i=1:m
  index  = istart(i):iend(i);
  data_out(index,i)=gradient(data(index,i),sintr(i));
end;
