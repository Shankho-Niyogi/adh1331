function comp=strcmp2(s1,s2);
%   strcmp2       compare two character string arrays
% usage: comp=strcmp2(s1,s2);
% The input parameters are 2 character string arrays s1 and s2.  The number 
% of columns of s1 and s2 must be the same.  Each string is stored as a 
% row vector of s1 or s2.  s2 is assumed to contain a unique set of strings.  
% Compare each string in s1 with all the strings in s2.  If a string in s1 
% does not match any string in s2 a 0 is returned, otherwise, the row 
% number of the string in s2 is returned as an element in the column 
% vector 'comp'.  'comp' contains one element per row of s1.

[n1,m1]=size(s1);
[n2,m2]=size(s2);
comp=zeros(n1,1);
if (m1~=m2),
  disp(' the two string arrays in STRCMP2 must have the same number of columns')
elseif m1==1;   % only one column  
  for i=1:n2
    index=findstr(s2(i),s1');   % find indices where the strings are identical
    len=length(index);             % if there are any matches, update comp
    if len>0
      comp(index)=i*ones(len,1);
    end
    if min(comp)>0, return, end   % if all strings have been matched return
  end
else;           % multiple columns
  a1=abs(s1)';  % convert character strings to arrays of numbers for fast comparison
  a2=abs(s2)';
  for i=1:n2
    aa=vec2mat(a2(:,i),n1);        % make an array with ith string of s2 repeated n1 times
    index=find(sum(a1==aa)==m1);   % find indices where the strings are identical
    len=length(index);             % if there are any matches, update comp
    if len>0
      comp(index)=i*ones(len,1);
    end
    if min(comp)>0, return, end   % if all strings have been matched return
  end
end
 
