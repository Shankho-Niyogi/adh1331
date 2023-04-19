function c=radplt(c);
%   radplt        plot focal mechanism nodal lines
% Usage: c=radplt(c);

hold on;
axis('square');
radius=2*sin(pi/4);
box=radius*1.05;
V=[-box box -box box];
axis(V);

% plot circle and cross-hairs around focal sphere
ind=[0:pi/180:2*pi];
xx=radius*cos(ind);yy=radius*sin(ind);
plot(xx,yy,'k');
plot([0,0;-box,box]',[-box,box;0,0]',':k');

% plot contours on an equal area projection (see contour) 
hold on
n0=1;
while (n0<length(c));
  nn=c(n0,2);
  clevel=c(n0,1);
  xi1=c(n0+1:n0+nn,1);
  i1 =c(n0+1:n0+nn,2);
  r=2*sin(i1/2);
  phi=pi/2-xi1;
  x=r.*cos(phi);
  y=r.*sin(phi);
  if clevel==0, 
    plot(x,y,'k')
  elseif clevel<0
    plot(x,y,'-.b')
  else
    plot(x,y,'--r')
  end
  hold on
  n0=n0+nn+1;
end
