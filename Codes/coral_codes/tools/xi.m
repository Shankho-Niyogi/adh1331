function [xi,mid_lat,mid_lon,mid_azim,cos2xi]=xi(eq_lat,eq_lon,st_lat,st_lon,flag);
% USAGE: [xi,mid_lat,mid_lon,mid_azim,cos2xi]=xi(eq_lat,eq_lon,st_lat,st_lon,flag);
%
% Calculate rayangle xi (angle between ray direction and
% Earth's spin axis) of rays at their turning point. Useful for
% studies of inner core anisotropy.
% 
%
% Input:
% ------
% eq_lat = latitude of event
% eq_lon = longitude of event
% st_lat = latitude of station
% st_lon = longitude of station
% flag   = 0 for lat,lon in geographic coords (deg)
%        = 1 for lat,lon in geocentric coords (rad)
%
%
% Output:
% -------
% xi       = rayangle (deg)
% mid_lat  = latitude of turning point
% mid_lon  = longitude of turning point
% mid_azim = ray azimuth at turning point (deg)
% cos2xi   = (cos(xi))^2

for i = 1:length(eq_lat),
 [delta(i)]           = delaz(eq_lat(i),eq_lon(i),st_lat(i),st_lon(i),0);
 [mid_lat(i),mid_lon(i)] = great_circle(eq_lat(i),eq_lon(i),st_lat(i),st_lon(i),delta(i)/2,0);

 [delt(i),az(i)]         = delaz(mid_lat(i),mid_lon(i),st_lat(i),st_lon(i),0); % az = ray azimuth at mid point
 cosxi(i)             = cos(az(i)*pi/180) .* cos(mid_lat(i)*pi/180);
 cosxi(i)             = abs(cosxi(i));
 cos2xi(i)            = cosxi(i).^2;
 mid_azim(i)          = az(i);
 xi(i)                = acos(cosxi(i))*180/pi;
end

xi       = xi(:);
mid_lat  = mid_lat(:);
mid_lon  = mid_lon(:);
if flag ==0,
 j = find(mid_lon>180);
 mid_lon(j) = mid_lon(j)-360;
end
mid_azim = mid_azim(:);
cos2xi   = cos2xi(:);
