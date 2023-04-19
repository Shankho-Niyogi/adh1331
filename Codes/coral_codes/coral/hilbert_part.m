function data_out=hilbert_part(data,header,index);
%   hilbert_part  apply hilbert transform to coral data 
% USAGE: data_out=hilbert_part(data,header,index);
% 
% apply a hilbert transform (+90 deg phase shift) to the columns of the
% data array.  only apply the transformation to column n if the nth
% element of index is greater than zero.
% the data array may be padded at the start or end with zeros
% as defined in header.  transform only the data, and leave the zero 
% padding untouched.  Apply a cosine taper to the first and last three
% points of the data prior to transformation.
% see update_data for a description of 'header'

[n,m]=size(data);
[istart,iend]=find_nonzero(header);  % find start and end of data
data_out=data;
for i=1:m
  if index(i)>0,
    index  = istart(i):iend(i);
    n1=iend(i)-istart(i)+1;
    data_out(index,i)=hilbert_trans(taperd(data(index,i),3/n1));
  end
end;
