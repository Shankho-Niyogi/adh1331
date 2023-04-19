function string_out=left_justify(string_in);
%   left_justify  left justify strings in a character string matrix
% USAGE: string_out=left_justify(string_in);
% leaves size of string matrix identical

[n,m]=size(string_in);
index=[m:-1:1];
string_out=setstr(zeros(n,m)+32);
for i=1:n
 str=deblank(string_in(i,index));
 len_str=length(str);
 if len_str>0,
   string_out(i,[1:len_str])=str([len_str:-1:1]);
 end
end
