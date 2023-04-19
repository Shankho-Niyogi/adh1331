function [qtime,qloc]=choose_event(qtimes,qloc,index2);
%   choose_event  choose event time/location 
% USAGE: [qtime,qloc]=choose_event(qtimes,qloc,index2);
%
% qtimes and qloc are the event origin date/times (nx2) and locations 
%   (lat,lon,dep,mag, nx4) for an earthquake catalog. 
% index2 is a vector of indices pointing to events in qtimes and qloc 
%   that are candidate events.
% output is one event (qtime,qloc) chosen from the candidate events, 
% by entering values at the keyboard.

if length(index2)==0,
  disp('No event in the catalog read using ''quak'' can be associated with these ')
  disp('data. Enter year, month, day, hour, min, sec, lat, lon, dep, mag ')
  disp('for the event you are analyzing. eg: [92 3 13   16 1 1   52.24 -178.9  197   6.1]');
elseif length(index2)>1
  time=time_reformat(qtimes);
  for i=index2;
  disp(['[' int2str(time(1,i)) ' ' int2str(time(2,i)) ' ' int2str(time(3,i)) '   ' ...
        int2str(time(4,i)) ' ' int2str(time(5,i)) ' ' sprintf('%.6g',time(6,i)) '   ' ...
        sprintf('%.6g',qloc(1,i)) ' ' sprintf('%.6g',qloc(2,i)) '  ' sprintf('%.6g',qloc(3,i)) '   ' ...
        sprintf('%.6g',qloc(4,i)) ']']);
  end
  disp('More than one event is plausibly associated with the data read in.')
  disp('Choose the event of interest by entering');
  disp('year, month, day, hour, min, sec, lat, lon, dep, mag ')
  disp('eg: [92 3 13   16 1 1   52.24 -178.9  197 6.1]');
else
  qtime=qtimes;
  return
end
[temp]=input(':');
while length(temp)~=10,
  disp('you must enter 10 values--try again')
  [temp]=input(':');
end
qtime=time_reformat(temp(1:6)');qloc=temp(7:10)';


