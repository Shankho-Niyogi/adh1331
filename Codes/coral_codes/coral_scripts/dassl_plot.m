%function coral_recvr_fun(data1,header1,waterlevel,a,timeshift);

timeshift=-wind_width(1);scale=100;  % with synths use 100; with data use 1000

[Ndata,Nsta]=size(data1);
WIN_INDEX=header1(5,:);
Nsta=length(WIN_INDEX);

[sta_names,lat,lon,sta_number,das_number,corr]= ...
  read_station_loc('/u1/pullen/matlab/dassl/station_loc');

dist=(Loc(2,WIN_INDEX) + 123.0240)*cos(47*pi/180) * 111.1; % distance from DOSW in km
hold off
%clf
%self_scale=max(abs(data1));
data0=zeros(size(data1));
iii=1:2:Ndata;                  % plot every 2th point
colormap(gray);
for i=1:Nsta
  t=[0:Ndata-1]'*header1(6,i) - timeshift;
  y0=data1(1:Ndata,i);
  data0(1:Ndata,i)=y0;
  x=t(iii);
  y=y0(iii)*scale;
  fill_seismogram(x,y,dist(i))
  if i==1, hold on; end
end
axis ([min(t), max(t), -5, 110])
plot([0,0],[-5,110])
xlabel('time (s)');ylabel('distance(km)')
title(['Receiver functions: ' titl(1:length(titl)-3)])
%gtext('west');gtext('east');gtext('Seattle')
hold off
return
print_yn=input('Enter p<CR> to print, q<CR> to quit, <CR> to continue','s');
if strcmp(print_yn,'p')
  colormap(flipud(gray));
%  print -dps tonga
   print 
  colormap(gray);
elseif strcmp(print_yn,'q')
  return
end

%colormap(round(gra));
colormap(jet);
%colormap(gray); gra=round(flipud(gray)*10)/10; 
%gra=flipud(gray)-.5; gra=round(gra*15)/10; gra=max(gra,-.5); gra=min(gra,.5)+.5;
%colormap(gra);
%clf
iii=1:Nsta;
dec_fact=10;   % decimation factor for display
data00=data0(1:dec_fact:Ndata,iii); 
time00=[0:dec_fact:Ndata-1]*header1(6,1)-timeshift;
surf(time00,dist(iii),data00',data00');view(0,80);shading('interp')
hold on
hidden off
for i=1:Nsta
  plot3(time00,dist(i)*ones(size(time00)),data00(:,i),'k', ...
  'erasemode','none','linewidth',2)
end
xlabel('time(s)'); ylabel('distance (km)');
hold off

