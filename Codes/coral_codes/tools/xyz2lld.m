function [lat,lon,dep]=xyz2lld(lat0,lon0,dep0,x,y,z);
%   xyz2lld       convert cartesian coordinates to latitude, longitude, and depth
% usage: [lat,lon,dep]=xyz2lld(lat0,lon0,dep0,x,y,z);
% consider a reference event at location (lat0,lon0,dep0, all scalars)
% and a set of points whose positions are described by a cartesian 
% coordinate system with the origin at the reference event and 
% x=north,y=east,z=down all in km.  Return these locations in geographic
% latitude, longitude (in degrees), and depth (in km). x,y,z,lat,lon,and dep
% are all column vectors.
% see also lld2xyz

z=(6371-dep0) - z;                           % move origin to earth center
[radius,delta,azeqst]=xyz2sph(x,y,z);        % to spherical, pole at epicenter
dep=6371-radius;                             % radius to depth
[lat0,lon0]=coortr(lat0,lon0,0);             % geographic to geocentric, pole at epicenter
[lat,lon]=rot(lat0*180/pi,lon0*180/pi,azeqst,delta); % to geocentric
[lat,lon]=coortr(lat*pi/180,lon*pi/180,1);   % geocentric to geographic
