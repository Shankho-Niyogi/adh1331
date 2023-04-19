function pltsym(x,y,siz,symbol);
%   pltsym        plot symbols
% usage: pltsym(x,y,siz,symbol);
% x      = column vector of x values
% y      = column vector of y values
% siz    = matrix containing 2 columns.  first column contains
%          symbol size in x direction, second column is y size.
%          if only one column is given, x and y sizes will be the same
% symbol = column vector of symbol types (1=blue o, 2=red +)

% separate symbol 1 and 2 vectors
ind1=find(symbol==1); ind2=find(symbol==2);
x1=x(ind1); x2=x(ind2);
y1=y(ind1); y2=y(ind2);
if length(siz(1,:))==1, siz=[siz siz]; end
s1=siz(ind1,:); s2=siz(ind2,:);

% plot o's
if length(ind1)>0,
  m=length(ind1);                     % m points to plot
  n=20;                               % n points per circle
  theta=[0:(n-1)]'/(n-1)*2*pi;
  cx=cos(theta)/2;                    % cx and cy are coordinates for unit circle
  cy=sin(theta)/2;
  xx1=vec2mat(x1,n)+s1(:,1)*cx';      % xx1 and yy1 are arrays of coordinates for
  yy1=vec2mat(y1,n)+s1(:,2)*cy';      % ellipses centered at x1,y1, scaled by s1
  plot(xx1',yy1','-b');
end

% plot +'s
if length(ind2)>0,
  if length(ind1)>0,
    hold on
  end
  xx1=[x2-s2(:,1)/2 x2+s2(:,1)/2]';
  yy1=[y2            y2           ]';
  xx2=[x2            x2           ]';
  yy2=[y2-s2(:,2)/2 y2+s2(:,2)/2]';
  plot (xx1,yy1,'-r',xx2,yy2,'-r');
end

hold off
