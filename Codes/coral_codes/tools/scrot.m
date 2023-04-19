function [th2,ph2,az0]=scrot(cxfmat,th1,ph1);
%   scrot         rotation of spherical coordinates
% usage: [th2,ph2,az0]=scrot(cxfmat,th1,ph1);
%
%  input parameters:
%    cxfmat (3x3) transformation matrix (computed using 'euler_trans')
%    th1,ph1      initial coordinates (scalars or column vectors)
%
%  output parameters:
%    th2,ph2  coordinates in rotated system 
%    az0      azimuth in rotated system of northward-directed meridian 
%             in initial system
%   
%  dimensions of th2,ph2,az0 match those of th1,ph1
%  see also ROT, EULER_TRANS, and XYZ2LLD

cth1 = cos(th1);
sth1 = sin(th1);
sph1 = sin(ph1);
cph1 = cos(ph1);
x    = [sth1.*cph1, sth1.*sph1, cth1];
dxdt = [cth1.*cph1, cth1.*sph1,-sth1];
xp   = (cxfmat*x')';
dxpdt= (cxfmat*dxdt')';
temp = sqrt(xp(:,1).*xp(:,1)+xp(:,2).*xp(:,2));
th2  = atan2(temp,xp(:,3));
ph2  = atan2(xp(:,2),xp(:,1));
ph2  = ph2 - 2*pi*sign(ph2).*(abs(ph2)>pi);  % set range to -pi -> pi
az0  = atan2(-xp(:,1).*dxpdt(:,2)+xp(:,2).*dxpdt(:,1) , -dxpdt(:,3));
