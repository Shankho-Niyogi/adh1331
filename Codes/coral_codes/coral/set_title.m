function titl=set_title(loc,station,mag);
%   set_title     define title for coral display
% usage: titl=set_title(loc,station,mag);
% make a title (string) consisting of event date/time latitude, longitude, depth, 
% magnitude and channel name
% loc is a vector containing 8 numbers (date/time are in compressed format)
% loc=[station lat, lon, elev; event lat, lon, depth; origin date, time];
% station is a character string containing station name, then blanks, then
% component name (eg SHZ), then more blanks, then network name
% mag is a vector or scalar. The first element is used for the title

otime    =time_reformat(loc(7:8));   % origin time (year,mon,day, hour,min,sec)
temp     =cut_string(setstr(station)');
component=cut_string(temp(2,:));     % component (eg BHZ).
if loc(4)<0, ns='S'; else, ns='N';end
if loc(5)<0, ew='W'; else, ew='E';end

titl=sprintf('%d/%d/%d %d:%d:%d %.1f%c %.1f%c %.0fkm %3.1f %s',...
round(otime)',abs(loc(4)),ns,abs(loc(5)),ew,loc(6),mag,component);
disp(['titl = ' titl])
