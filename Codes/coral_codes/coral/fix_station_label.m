function [Station]=fix_station_label(Station);
%   fix_station_label  change station channel name to SEED convention
% Usage: [Station]=fix_station_label(Station);

% change the label for radial and transverse channels to SEED conventions
% If the last character of the channel field (row 12) is the
% character r or t, then replace the third character of the 
% channel field (row 10) with R or T.  This stands for radial
% and transverse and converts the ahrot convention to the SEED
% convention for channel labeling.

index=find (setstr(Station(12,:))=='t');
n=length(index);
if n>0, 
  Station(10,index)=abs('T')+zeros(1,n); 
end
 
index=find (setstr(Station(12,:))=='r');
n=length(index);
if n>0, 
  Station(10,index)=abs('R')+zeros(1,n); 
end


