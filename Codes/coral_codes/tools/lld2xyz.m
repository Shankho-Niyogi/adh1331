function [x,y,z]=lld2xyz(lat0,lon0,dep0,lat,lon,dep);
%   lld2xyz       convert latitude, longitude, depth to cartesian coordinates
% usage: [x,y,z]=lld2xyz(lat0,lon0,dep0,lat,lon,dep);
% consider a reference event at location (lat0,lon0,dep0, all scalars)
% and a set of events at locations (lat,lon,dep, all column vectors)
% depth is in km, lat and lon are geographic latitude and longitude in deg
% determine the positions of the events with respect to the 
% reference event using a cartesian coordinate system with
% the origin at the reference event and x=north,y=east,z=down all in km
% see also xyz2lld.

lat0=zeros(size(lat))+lat0;   
lon0=zeros(size(lon))+lon0; 
[delta,azeqst]=delaz(lat0,lon0,lat,lon,0);  % geographic to geocentric, pole at epicenter
[x,y,z]=sph2xyz(6371-dep,delta,azeqst);     % spherical to cartesian
z=(6371-dep0) - z;                          % cartesian, origin at hypocenter

