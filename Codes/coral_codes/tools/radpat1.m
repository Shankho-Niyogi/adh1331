function [X,Y,Z]=radpat1(Mharvard,plotsel,fs_up_down,loc);
%   radpat1       plot moment tensor nodal lines
% usage: radpat1(Mharvard);
% plot nodal lines from input of Harvard-format moment tensor
% Mharvard=[-3.57 0.08 -0.87 0.11  4.43 0.12 -6.12 0.09 -2.66 0.09  2.47 0.10];

% define a grid of rays at a series of nxi azimuths (xi0 in radians) and 
% ni take-off angles (i0 in radians);
% there will be n=nxi*ni combinations of xi's and i's which are stored
% in vectors xi and i

if nargin<4,         loc=[];       end
if length(loc)==0,   loc=[0,0,1];  end
if length(loc)<3     loc(3)=1;     end
 
 
xi0=[0:30:360]'*pi/180; 
i0=[.5:89.5/8:90]'*pi/180;

nxi=length(xi0);ni=length(i0);n=nxi*ni;
[xi,i]=meshgrid(xi0,i0);
X=2*sin(i0/2) * sin(xi0') * loc(3) + loc(1);
Y=2*sin(i0/2) * cos(xi0') * loc(3) + loc(2);
 
if fs_up_down==2,
  i=pi-i;
end

radpat = radpattern( Mharvard(1:2:12), i*180/pi, xi*180/pi, plotsel );
Z=reshape(radpat,ni,nxi); 
h_surf=surf(X,Y,Z-1,Z);view(0,90);
A=ones(32,1);B=A*0;colormap([A,A,A;B,B,B])
%a=[2:32]*0+1;b=a*0;map=[b 1 a;b 1 b;a 1 b]';  % make a colormap
%colormap(hot(64));map=colormap;map(32,:)=[1 1 1];colormap(map);
axis('off');
axis('square'); 
axis('equal');
shading interp;
x=2*sin(pi/4);
hold on;plot(x*sin(xi0),x*cos(xi0),'w');
plot([0,0],[-1,1]*x,':w',[-1,1]*x,[0,0],':w')
hold off

