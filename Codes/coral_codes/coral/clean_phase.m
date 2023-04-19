function header=clean_phase(header,angle);
%   clean_phase   update coral header for new phase angle
% USAGE: header=clean_phase(header,angle);
% add phase angle (angle) stored in the row vector 'angle' to
% header.  The resulting angle is forced to lie in the range
% -89.9999 to 90.0001.  If it is outside this range, account for
% a 180 deg phase shift by changing the signe of the magnification
% stored in header.

phase=rem(angle(:)'+header(8,:), 360);  % force phase in range -360 -> 360
phase=phase - (phase>180)*360 + (phase<=-180)*360;% force phase in range -180 -> 180
flip=1-2*(phase>90.0001 | phase<-89.9999);
phase=phase - (phase>90.0001)*180 + (phase<-89.9999)*180;
header(7,:)=header(7,:).*flip;
header(8,:)=phase;

