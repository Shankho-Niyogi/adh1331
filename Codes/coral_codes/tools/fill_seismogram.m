function fill_seismogram(x,y,y_offset,colors);
% draw lines with solid fill for positive values
% USAGE: fill_seismogram(x,y,y_offset,colors);
% x and y must be column vectors
% y_offset (scalar) offsets the data in the y direction
%        default is 0
% colors is a two character string defining the colors 
%        of the filled regions for positive and negative values
%        default is 'wm' for white and magenta

if nargin<=2, y_offset=0; end
if nargin<=3, colors='wm'; end

N=length(x); 
y=[-eps;eps;y;-eps;eps];     % add points at beginning and end 
x=[x(1);x(1);x;x(N);x(N)];   % to force filling at ends

i=find(diff(y>0));           % find all zero crossings
xi = x(i) - y(i) .* (x(i+1)-x(i)) ./ (y(i+1)-y(i));
for k=1:length(i)-1
  ii=i(k)+1:i(k+1);
  xxx=[xi(k); x(ii); xi(k+1)];
  yyy=[0    ; y(ii); 0      ];
  if yyy(2)>0, color=colors(1); else, color=colors(2); end
%  patch(xxx,y_offset+yyy,(yyy(2)>0)*1+1);
  patch(xxx,y_offset+yyy,color);
end 
line(x,y_offset+y);


