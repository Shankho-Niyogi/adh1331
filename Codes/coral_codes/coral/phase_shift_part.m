function [data_out,header]=phase_shift_part(data,header,angle);
%   phase_shift_part  apply phase shifts to coral data
% USAGE: [data_out,header]=phase_shift_part(data,header,angle);
% 
% apply a frequency independent phase shift of 'angle' degrees to the 
% columns of the data array.  (a hilbert transform is a +90 deg 
% phase shift)  angle is a vector with one element per column of data.
% the data array may be padded at the start or end with zeros
% as defined in header.  taper only the data, and leave the zero 
% padding untouched.  Apply a cosine taper to the first and last three
% points of the data prior to transformation.
% see update_data for a description of 'header'

[n,m]=size(data);
[istart,iend]=find_nonzero(header);  % find start and end of data
data_out=data;
for i=1:m
  if angle(i)~=0,
    index  = istart(i):iend(i);
    n1=iend(i)-istart(i)+1;
    d=taperd(data(index,i),3/n1);
    if angle(i)==180,
      data_out(index,i)=-d;
    else
      data_out(index,i)=cos(angle(i)*pi/180)*d + ...
                        sin(angle(i)*pi/180)*hilbert_trans(d);
    end 
  end
end;
header=clean_phase(header,angle);
