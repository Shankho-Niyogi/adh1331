function h = arrow(start,stop,scale,headAngle,colStyle)
%  ARROW(start,stop,scale,headAngle,colStyle)  draw a line with an arrow 
%                           pointing from start to stop
%  Draw a line with an  arrow at the end of a line
%  start is the x,y point where the line starts
%  stop is the x,y point where the line stops
%  Scale is an optional argument that will scale the size of the arrows
%  It is assumed that the axis limits are already set
% 
%  Input arguments
%    headAngle: an optional argument which allows the user to set the angle
%               of the arrowhead. The argument must be given in radians.
%               (default: pi/6)
%    colStyle:  an optional argument which allows the user to set the color
%               and line style of the arrow and arrow head using the usual
%               Matlab expressions (e.g. 'r:' for a dotted red line).
%               (default: 'b')
%  Return value
%    h: the handle to the created arrow.

%       8/4/93    Jeffery Faneuff
%       Copyright (c) 1988-93 by the MathWorks, Inc.
%
%    headAngle, colStyle and h added by John Winchester.


if nargin==2
  xl = get(gca,'xlim');
  yl = get(gca,'ylim');
  xd = xl(2)-xl(1);        % this sets the scale for the arrow size
  yd = yl(2)-yl(1);        % thus enabling the arrow to appear in correct 
  scale = (xd + yd) / 2;   % proportion to the current axis
end

if nargin < 4
  headAngle = pi/6;
end
if nargin < 5
  colStyle = 'b';
end

hold on
axis(axis)

xdif = stop(1) - start(1);
ydif = stop(2) - start(2);

if xdif ~= 0
  theta = atan(ydif/xdif);  % the angle has to point according to the slope
else
  theta = atan(Inf);
end

if(xdif>=0)
  scale = -scale;
end

xx = [start(1), stop(1),(stop(1)+0.02*scale*cos(theta+headAngle)), ...
	NaN, stop(1), (stop(1)+0.02*scale*cos(theta-headAngle))]';
yy = [start(2), stop(2), (stop(2)+0.02*scale*sin(theta+headAngle)), ...
	NaN, stop(2), (stop(2)+0.02*scale*sin(theta-headAngle))]';

h = plot(xx,yy,colStyle);

hold off
