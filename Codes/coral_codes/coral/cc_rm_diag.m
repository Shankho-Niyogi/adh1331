function [cc_idx] = cc_rm_diag(n);
%   cc_rm_diag    reorganize indices for cross correlations
% USAGE: [cc_idx] = cc_rm_diag(n);
%
%  returns a vector of indices that will give all columns of a
%  matrix of cross-correlograms that are returned from xcor.m
%  except for the autocorrelograms (which lie at positions
%  that are "diagonal" in the matrix of cross-correlograms).
%
%    note:  the matrix actually represents a 3-D matrix of
%           cross-correlograms by stretching the third dimension
%           out into elements in a sequence of columns.  The
%           sequence looks like [(1,1),(1,2),...,(1,n),(2,2),
%           (2,3),...,(2,n),...,(n-1,n-1),(n-1,n),(n,n)], where
%           the rows of each column represent the cross-correlogram
%           for that pair of time-series.

cc = []; cc_idx = [];
cc_idx = 1:(n*(n+1)/2);

temp = 1; tempvec=[];
for i = 0:(n-1),
  tempvec = [tempvec, temp];
  temp = temp + (n-i);
end;

for i = 1:length(tempvec),
  j = find(cc_idx ~= tempvec(i));
  cc_idx = cc_idx(j);
end;
