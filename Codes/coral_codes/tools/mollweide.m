function [x,y]=mollweide(lat,lon,R);
%   mollweide       convert lat, lon into x,y for mollweide projection
%
% input lat (deg),  lon(deg) as numbers, vectors or a matrices
% R is an optional scaling parameter, default is 180/pi
% output x and y as arrays with the same dimensions as lat and lon
% x =0 corresponds to lon=180

if nargin <3; R=180/pi; end

X     = [-1:.01:1]'*pi/2;
Y     = 2*X + sin(2*X);

lon=lon+360*(lon<0);    % convert longitude to range 0->360
phi   = lat(:)*pi/180;
lamda = (lon(:)-180)*pi/180;

alpha = interpol(Y,X,pi*sin(phi));

x     = 2*sqrt(2)/pi*R*lamda .* cos(alpha);
y     = sqrt(2)*R*sin(alpha);

[n,m]=size(lat);
x     = reshape(x,n,m);
y     = reshape(y,n,m);
