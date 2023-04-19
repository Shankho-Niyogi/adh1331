function [max_idx, nmax] = find_max_idx(in_vec, flag);
%   find_max      return indices of all local maxima of a vector
% USAGE: [max_idx, nmax] = find_max_idx(in_vec, flag);
%
%  returns a vector of indices for the maxima of a time series 
%   and the number of maxima found (if desired).
%
%  if flag is greater than zero, returns only positive peaks,
%  if flag is less than zero, returns only negative peaks,
%  if flag equals zero, returns both positive and negative peaks.
%  (default is 1);
%

if nargin < 2, flag = 1; end;
tflag = 0;

[n,m] = size(in_vec);
if n == 1, in_vec = in_vec'; tflag = 1; end;

if flag < 0,
  in_vec = -in_vec;
end;

temp1 = in_vec(1:(length(in_vec)-1));
temp2 = in_vec(2:(length(in_vec)));

% maxima where slope is positive for the first sequence and
%    negative for the second...

tempindx= [diff(temp1)] > 0 & [diff(temp2) < 0];
if flag == 0,
  tempindx2= [diff(temp1)] < 0 & [diff(temp2) > 0];
  max_idx = find((tempindx + tempindx2) == 1);
else
  max_idx = find(tempindx == 1);
end;

nmax = length(max_idx);
if tflag == 1, max_idx = max_idx'; end;
