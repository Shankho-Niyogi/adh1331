function [xi,midlat,midlon,midazim]=rayangle(eqlat,eqlon,stlat,stlon,flag);
%   rayangle      compute mid point lat and lon and ray angle with respect to spin axis 
% usage: [xi,midlat,midlon,midazim]=rayangle(eqlat,eqlon,stlat,stlon,flag);
%
%     compute midpoint (mid) latitude and longitude between earthquake (eq) and station (st)
%     midazim  = mid-point azimuth (deg) 
%     xi       = ray angle (deg) between ray at midpoint and spin axis
%
%     if input coordinates are geographic degrees   flag=0
%     if input coordinates are geocentric radians   flag=1
%    
%     input latitudes and longitudes can be scalars or column vectors
%     output vectors will have same dimensions as input vectors
%     midlat and midlon are geographic degrees if flag=0
%     and geocentric radians if flag=1
%
%     calls coortr.m, delaz.m and rot.m

% convert from geographic degrees to geocentric radians if necessary
if flag==0,   % convert geographic degrees to geocentric radians
  [eqlat,eqlon]=coortr(eqlat,eqlon,0); 
  [stlat,stlon]=coortr(stlat,stlon,0); 
end

% calculate epicentral distance and azimuth (deg)
[delt,azim]=delaz(eqlat,eqlon,stlat,stlon,1);

% calculate geocentric midpoint latitude and longitude (deg)
if length(eqlat)==1 & length(eqlon)==1;
   [midlat,midlon] = rot(eqlat*180/pi,eqlon*180/pi,azim,delt/2);
else 
  N=length(delt);
  midlat=zeros(N,1); midlon=zeros(N,1);
  for i=1:N;
    [midlat(i),midlon(i)] = rot(eqlat(i)*180/pi,eqlon(i)*180/pi,azim(i),delt(i)/2);
  end
end
midlat=midlat*pi/180;  % convert to geocentric radians
midlon=midlon*pi/180;

% calcluate azimuth at midpoint
[tmp,midazim]=delaz(midlat,midlon,stlat,stlon,1);

% calculate inner core ray angle (deg)
cosxi       = cos(midazim*pi/180) .* cos(midlat);
xi          = acos(abs(cosxi))*180/pi;

if flag==0,   % convert geocentric radians to geographic degrees if necessary
  [midlat,midlon]=coortr(midlat,midlon,1);
end
%lons=[eqlon ; stlon; midlon];
%lats=[eqlat ; stlat; midlat];
%lons = lons + 360*(lons<0);
%mapp(-1); hold on;
%plot([eqlon ; stlon; midlon], [eqlat ; stlat; midlat],'o')
%plot(lons,lats,'o');

