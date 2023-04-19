function data_out=envelope_part(data,header,env_index);
%   envelope_part envelope function for coral data
% USAGE: data_out=envelope_part(data,header,env_index);
% 
% apply the envelope function to the columns of the
% data array.  only apply the transformation to column n if the nth
% element of index is greater than zero.
% the data array may be padded at the start or end with zeros
% as defined in header.  transform only the data, and leave the zero 
% padding untouched.  The envelope function of a time series f(t) is
% defined here as (f^2 + H(f)^2)^.5 where H(f) is the hilbert transform 
% of f.  Apply a cosine taper to the first and last three
% points of the data prior to hilbert transformation.
% see update_data for a description of 'header'

[n,m]=size(data);
[istart,iend]=find_nonzero(header);  % find start and end of data
data_out=data;
for i=1:m
  if env_index(i)>0,
    index  = istart(i):iend(i);
    n1=iend(i)-istart(i)+1;
    if n1==1 | n1==2;
      data_out(index,i)=abs(data(index,i));
    else
      f=min(.5,3/n1);                  % taper 3 points on each side (or fewer 
      temp1=taperd(data(index,i),f);   % if there are less than 6 data points total)
      temp2=hilbert_trans(temp1);
      data_out(index,i)=sqrt(temp1.*temp1 + temp2.*temp2);
    end
  end
end;
