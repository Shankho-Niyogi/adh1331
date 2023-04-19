function c=radpat(Mharvard,plotsel,fs_up_down);
%   radpat        plot moment tensor nodal lines
% usage: radpat(Mharvard);
% plot P-wave nodal lines from input of Harvard-format moment tensor
% Mharvard=[-3.57 0.08 -0.87 0.11  4.43 0.12 -6.12 0.09 -2.66 0.09  2.47 0.10];

% define a grid of rays at a series of nxi azimuths (xi0 in radians) and 
% ni take-off angles (i0 in radians);
% there will be n=nxi*ni combinations of xi's and i's which are stored
% in vectors xi and i

xi0=[0:15:360]'*pi/180; 
i0=[.5:89.5/15:90]'*pi/180;
nxi=length(xi0);ni=length(i0);n=nxi*ni;
xi=reshape(vec2mat(xi0,ni)',1,n);
i =reshape(vec2mat(i0,nxi),1,n);
if fs_up_down==2,i=pi-i;end

% define gamma as a set of n column vectors, where each column
% vector has 3 components representing the direction of the ray. 

radpat = radpattern( Mharvard(1:2:12), i*180/pi, xi*180/pi, plotsel );
% contour radpat on its square grid
clevel=[-.1 0 .1]*max(abs(radpat));
radpat=reshape(radpat,ni,nxi); 
c=contourc( xi0, i0,radpat,clevel)';
