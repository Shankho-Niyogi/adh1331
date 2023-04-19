function [smat, nstrings] = cut_string(svec, sep);
%   cut_string    cut a character string into a matrix
% USAGE:  [smat, nstrings] = cut_string(svec, sep)
%
%  takes the fields separated by blanks in an input character vector and
%  puts them into a character array with nstrings rows.  blanks are
%  defined in the optional vector argument sep, which takes the default
%  separators of space, tab, and null characters.
%
%   note:  must first determine the size of the largest string, then
%          create a large enough matrix, then cut the strings out of the
%          filename vector

% by default, space, tab, and null characters counted as white space...
%  else use separator defined by user

if nargin == 1,
  sep = [' ', '	', setstr(0)];
end;
svec = [sep(1), svec, sep(1)];        % pad beginning and end with a separator

lensep = length(sep);
if lensep == 1,
  blanks=find(svec==sep);
else
  idx = [];
  for i = 1:lensep,
    newidx = find(svec == sep(i));
    if length(newidx) > 0,
      idx = [idx, newidx];
    end;
  end;
  blanks = sort(idx);
end;
len = max(diff(blanks)) - 1;                   % find longest string
start = find(diff(blanks) > 1);                % find start of strings
nstrings = length(start);                      % count number of strings
smat=setstr(ones(nstrings,len)*32);            % initialize filename matrix
for i = 1:nstrings,                            % break vector into matrix rows
  j = 1:(blanks(start(i)+1)-blanks(start(i))-1);
  smat(i,j) = svec(blanks(start(i))+1:blanks(start(i)+1)-1);
end
