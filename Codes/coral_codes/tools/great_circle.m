function [lats,lons] = great_circle(eqlat,eqlon,stlat,stlon,deltas,flag);
%   great_circle  compute latitudes and longitudes along a great circle
% usage: [lats,lons] = great_circle(eqlat,eqlon,stlat,stlon,deltas,flag);
%
%     compute latitudes (lats) and longitudes (lons) of points along a 
%     great circle from (eqlat,eqlon) towards (stlat,stlon) at angular
%     distances (deltas) from (eqlat,eqlon).
%     
%     if input coordinates and deltas are geographic degrees   flag=0
%     if input coordinates and deltas are geocentric radians   flag=1
%
%     input latitudes and longitudes must be scalars
%     deltas may be a scalar or a column vector
%     output coordinates and units are same as inputs as given by flag    
%   
%     calls coortr.m and delaz.m

% convert from geographic degrees to geocentric radians if necessary
% convert to spherical polar coordinates in radians (lat -> colatitude)

if flag==0,   % convert geographic degrees to geocentric radians
  [eqlat,eqlon]=coortr(eqlat,eqlon,flag); 
  [stlat,stlon]=coortr(stlat,stlon,flag); 
  deltas=deltas*pi/180;
end

% calculate angular distance and azimuth

[delta, azim] = delaz(eqlat,eqlon,stlat,stlon,1);
delta=delta*pi/180;
azim =azim*pi/180; 

eqcolat=pi/2-eqlat;
stcolat=pi/2-stlat;

sin_del=sin(deltas);
cos_del=cos(deltas);
cos_eq=cos(eqcolat);
sin_eq=sin(eqcolat);

% calculate theta and phi in spherical coordinates

cos_the = sin_del*sin_eq*cos(azim) + cos_eq*cos_del;
theta  = acos(cos_the);
sin_the=sin(theta);
if     eqcolat==0,
  phi=zeros(size(cos_the)) + azim;
elseif stcolat==0;
  phi=zeros(size(cos_the));
else
  sin_phi=sin_del*sin(azim)./sin_the;
  cos_phi=(cos_del - cos_eq * cos_the) ./ (sin_eq*sin_the);
  phi = eqlon + atan2(sin_phi,cos_phi);
end

% make sure phi is in the inverval 0 -> 2*pi
phi=phi+(phi<0)*2*pi;
phi=phi-(phi>2*pi)*2*pi;

%convert theta from colatitude to latitude
theta=pi/2-theta;
% convert back to geogrphic coordinates in degrees if flag==0
if flag==0,
  [theta,phi]=coortr(theta,phi,1);
end
lats = theta;
lons = phi;

