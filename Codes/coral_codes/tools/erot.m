function yMat = erot( lon1, lat1, az );
%   erot          make rotation matrix
% usage: yMat = erot( lon1, lat1, az );
%
%    Given a point lon1 and lat1 in geocentric radians and an
%    azimuth az (in degrees) to a second point. erot returns the
%    rotation matrix yMat which will rotate the given point to
%    the equator at the prime meridian (0,0). Any point which lies
%    along the azimuth az from the given point will be rotated to
%    the equator east of the given point.

phi = lon1; t = (pi/2 - lat1); gam = (az-90)*pi/180;

yMat = zeros(3,3);
yMat(1,:) = [ cos(phi)*sin(t),    sin(phi)*sin(t),   cos(t) ];
yMat(2,1) =  cos(phi)*cos(t)*sin(gam) - cos(gam)*sin(phi);
yMat(2,2) =  cos(t)*sin(gam)*sin(phi) + cos(gam)*cos(phi);
yMat(2,3) = -sin(gam)*sin(t);
yMat(3,1) = -cos(gam)*cos(phi)*cos(t) - sin(gam)*sin(phi);
yMat(3,2) = -cos(gam)*cos(t)*sin(phi) + cos(phi)*sin(gam);
yMat(3,3) = cos(gam)*sin(t);

         
