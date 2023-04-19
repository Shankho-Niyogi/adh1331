function [data_out] = rm_zeropad(data_in)
%   rm_zeropad    remove zero padding in a matrix
% USAGE: [data_out] = rm_zeropad(data_in)
%
%  truncates the incoming data to remove any zero padding that is common
%  to all of the columns of the data matrix.  outputs a smaller, non-padded
%  matrix as data_out

[n,m] = size(data_in);
temp_max = [];
for i = 1:m,
  nzidx = find(data_in(:,i) ~= 0);
  temp_max = [temp_max, max(nzidx)];
end;
new_n = max(temp_max);
data_out = data_in(1:new_n,:);
