function [x,y,z]=sph2xyz(r,colat,lon);
%   sph2xyz       convert spherical polar coordinates to cartesian coordinates
% usage  [x,y,z]=sph2xyz(r,colat,lon);
% input/output can be scalars or vectors
% r    =radius
% colat= colatitude (deg, 0=north pole, 180 = south pole)
% lon  = longitude  (deg, 0 to 360)
% x    = equator and longitude=0
% y    = equator and longitude=90
% z    = north pole
% see also XYZ2SPH

theta=colat*pi/180; phi=lon*pi/180;
x = r .* sin(theta) .* cos(phi);
y = r .* sin(theta) .* sin(phi);
z = r .* cos(theta);
