function [y,m,d]=ymd(date);
%   ymd           convert date format 
% usage: [y,m,d]=ymd(date);

y=floor(date/10000);
md=date-y*10000;
m=floor(md/100);
d=md-100*m;
