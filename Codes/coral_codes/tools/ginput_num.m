function [num] = ginput_num
%   ginput_num    get number typed into graphics window
%  USAGE [num] = ginput_num;
%
%  gets a number typed into the the graphics window, 
%  returns it to the calling routine
%  type <CR> to end input

tempin = [];
tempstr = [];
lcount = 0;
[x, y, tempin] = ginput(1);
while length(tempin)>0,
  %echo_ml(setstr(tempin), '-n');
% if found a backspace, adjust string accordingly, else cat character
%   to end of string if number, '+', '-', or decimal point...
  if tempin == 8 & lcount > 0,
    lcount = lcount - 1; tempstr = tempstr(1:lcount);
  elseif (tempin <= 57 & tempin >= 48) | tempin == 43 | tempin == 45 | ...
          tempin == 46,
    tempstr = [tempstr(1:lcount) tempin]; lcount = lcount + 1;
  elseif tempin ~= 8,
    disp('Non-integer input, use <CR> to end input, try again...');
    temp = [];
    tempstr1 = [];
    lcount = 0;
  else,
    disp(' Backspace only allowed after input...');
  end
  disp(setstr(tempstr));
  [x, y, tempin] = ginput(1);
end
disp(' ');
len = lcount;
string = setstr(tempstr);
num = str2num(string);
