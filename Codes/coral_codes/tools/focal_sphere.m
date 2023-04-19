function focal_sphere(plot_type,data_array,top_title,bottom_title,scaling);
%   focal_sphere  plot point data on a focal sphere
% USAGE: focal_sphere(plot_type,data_array,top_title,bottom_title,scaling);
%
%  Plot travel time residuals or polarities on a focal sphere.
%  You must clear a previous plot before running this, unless you want
%  to add data to an existing plot.
%  The first two arguments are required and the others are optional.
% 
% REQUIRED INPUT PARAMETERS:
%  plot_type = 1 to plot a residual sphere
%            = 2 to plot polarities
%  data_array has 5 columns which contain:
%            take-off angles (deg), azimuths (deg), travel-time residuals (s),
%            travel-time residual uncertainties (s) and polarities (+-1)
% OPTIONAL INPUT PARAMETERS:
%  top_title
%  bottom_title
%  scaling = row vector containing up to 3 scaling parameters
%            (1) scale:  ratio of size of residual sphere circle to size of
%                        circle for 1 s residual
%            (2) cutoff: residuals are clipped at cutoff (s)
%            (3) edge:   outer edge of focal sphere corresponds to a 
%                        take-off angle of edge (deg)

% set default parameters where needed
if nargin == 5
  if length(scaling) == 1,
    scaling=[scaling 5 90];
  elseif length(scaling) == 2,
    scaling=[scaling 90];
  end
else
  scaling=[25 5 90];
end
if nargin < 4, bottom_title=' '; end  
if nargin < 3, top_title=' '   ; end  
if nargin < 2,
  disp('function FOCAL_SPHERE requires at least 2 arguments ');
  return
end

% interpret scaling
scale =scaling(1);
cutoff=scaling(2);
edge  =scaling(3);
radius=2*sin(edge*pi/180/2);

% interpret data_array
theta   =data_array(:,1);  % take-off angle (deg)
azim    =data_array(:,2);  % event-to-receiver azimuth (deg)
dt      =data_array(:,3);  % travel-time residual (s)
sigma   =data_array(:,4);  % uncertainty of dt (s)
polarity=data_array(:,5);  % polarity (+ or -1)

% construct projection: 
theta=(theta<=90).*theta + (theta>90).*(180-theta); % force theta < 90
r=2*sin(theta*pi/180/2);
phi=(90-azim)*pi/180;
x=r.*cos(phi);
y=r.*sin(phi);

% make plot of travel times or polarities
if plot_type == 1,
  data=dt;
elseif plot_type == 2,
  data=polarity;
end

siz=[abs(data) abs(data)]; % set symbol size in x and y directions
symbol=(data>=0)+1;        % set symbol type = 1 if data<0, 2 if data>0

%  set maximum size for symbols and set symbol scale
siz=(siz>cutoff)*cutoff + (siz<=cutoff).*siz;
cutoff=-cutoff;
siz=(siz<cutoff)*cutoff + (siz>=cutoff).*siz;
siz=siz*2*radius/scale;

%  set axis slightly larger than focal sphere
hold on;
axis('square')
box=radius*1.05;
V=[-box box -box box];
axis(V)

%  plot residuals
hold on
pltsym(x,y,siz,symbol)
hold on

% plot circle and cross-hairs around focal sphere
ind=[0:pi/180:2*pi];
xx=radius*cos(ind);yy=radius*sin(ind);
plot(xx,yy,'w');
plot([0,0;-box,box]',[-box,box;0,0]',':w');

% plot a key for residual spheres
if plot_type == 1,
  xx=[-1,1,1,-1,-1];yy=[.5,.5,-.5,-.5,.5];
  x0=[-.45;.45];y0=[0;0];
  siz0=[.7,.7;.7,.7];sym0=[1;2];
  s=2*radius/scale/.7;
  xx=xx*s;yy=yy*s;x0=x0*s;y0=y0*s;siz0=siz0*s;
  ox=box-xx(2);oy=box-yy(2);
  xx=xx+ox;yy=yy+oy;x0=x0+ox;y0=y0+oy;
  plot(xx,yy);               % draw a box
  hold on
  pltsym(x0,y0,siz0,sym0);   % plot + and o symbols for 1 sec residual
  hold on
end

%  title and label plot
title(top_title);
if plot_type == 1,
  xlabel(bottom_title);
elseif plot_type == 2
  xlabel(bottom_title);
  %xlabel(['polarity plot  ' bottom_title]);
end
  
axis('normal')
hold off
