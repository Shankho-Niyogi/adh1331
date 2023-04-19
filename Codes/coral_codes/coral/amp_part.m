function data_out=amp_part(data,header);
%   amp_part      calculate amplitudes of each trace
% USAGE: data_out=amp_part(data,header);
% 
% Calcualte peak-to-peak amplitudes, maximum amplitudes and 
% minimum amplitudes of each trace and return in
% the array data_out that has dimension 3 x number of traces

[n,m]=size(data);
data_out=zeros(3,m);
[istart,iend]=find_nonzero(header);
for i=1:m
  index  = istart(i):iend(i);
  dd=data(index,i);
  data_out(:,i)=[(max(dd)-min(dd)); max(dd); min(dd)];
end;
