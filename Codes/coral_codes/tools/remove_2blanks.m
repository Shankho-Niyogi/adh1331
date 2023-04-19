function string_out=remove_2blanks(string_in);
%   remove_2blanks  remove pairs of blanks from string
% usage: string_out=remove_2blanks(string_in);
%
% input a string vector (string_in) and output a string
% vector (string_out) after removing all pairs of adjacent blanks

ai=find(string_in==' ');          % find index of all blanks
aj=ai(find(diff(ai)==1));         % find index of all pairs of adjacent blanks
na=length(string_in);             % length of input string      
ak=(1:na);
for iii=1:length(aj)
  ak=ak(ak~=aj(iii));             % index array that is compliment of aj
end
string_out=string_in(ak);
