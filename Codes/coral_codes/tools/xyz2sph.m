function [r,colat,lon]=xyz2sph(x,y,z);
%   xyz2sph       convert cartesian coordinates to spherical polar coordinates
% usage  [r,colat,lon]=xyz2sph(x,y,z);
% input/output can be scalars or vectors
% r    =radius
% colat= colatitude (deg, 0=north pole, 180 = south pole)
% lon  = longitude  (deg, 0 to 360)
% x    = equator and longitude=0
% y    = equator and longitude=90
% z    = north pole
% see also SPH2XYZ

r2   = x.*x + y.*y + z.*z;
r    = sqrt(r2);
lon  = atan2(y,x)*180/pi;
lon  = lon + 360*(lon<0);

% avoid divide by zero when r=0
index0=find(r==0);
index1=find(r~=0);
colat=lon;  % set colat to vector with same dimensions as lon
colat(index1)=acos(z(index1)./r(index1))*180/pi;
colat(index0)=zeros(size(index0));
