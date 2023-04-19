function string=make_label(vector,formt);
%   make_label    convert numbers to a string
% usage: string=make_label(vector,formt);
%
% vector is a vector of numbers
% formt  contains a format acceptable to sprintf (See a C manual)
%
% string is a character string array containing the numbers in 'vector' in
% its rows:
%
% eg.   sting=make_label([1.222 4.330 14],'%5.1f')

string=[];
for i=1:length(vector),
  string=[string sprintf(formt,vector(i)) ','];
end
string=cut_string(string,',');

