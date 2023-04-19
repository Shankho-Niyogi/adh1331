%function coral_recvr_fun(data1,header1,waterlevel,a,timeshift);
% set waterlevel, scale, and a before running this script
%waterlevel=.1; a=pi/8; scale=50;
timeshift=-wind_width(1); scale=50;

% take data from CORAL in data1 (must be Z, R, channels) and calculate
% receiver functions.  The results are placed back in the (Radial) channel
% slots and the vertical channel is deleted.

[Ndata,Nsta]=size(data1);
WIN_INDEX=header1(5,:);
OUTPUT=setstr(Station(1:10,WIN_INDEX)');
STANAM=OUTPUT(:,1:6);
INDEX=find(diff(sort(strcmp2(STANAM,STANAM)))>0);
INDEX=[1;INDEX+1];

% Deconvolve the DOSW vertical from the radial channels
ind_Z=0;
INXEX_DOSW=find(strcmp2(STANAM,' DOSW '));
if length(INXEX_DOSW)>0
  for IJK=1:length(INXEX_DOSW)
    if OUTPUT(INXEX_DOSW(IJK),10)=='Z',  ind_Z=IJK; end
  end
end
if ind_Z==0, 
  disp(' vertical component for DOSW not available, quitting') 
  return
end

index_keep=[];
Nsta=length(INDEX);
for ista=1:Nsta
  jsta=INDEX(ista);
  index=find(strcmp2(STANAM,STANAM(jsta,:)));
  if length(index==2)
    ind_z=0; ind_r=0;
    if OUTPUT(index(1),10) == 'Z',
      ind_z=index(1);
    elseif OUTPUT(index(1),10) == 'R',
      ind_r=index(1);
    end
    if OUTPUT(index(2),10) == 'Z',
      ind_z=index(2);
    elseif OUTPUT(index(2),10) == 'R',
      ind_r=index(2);
    end
    if ind_r*ind_z > 0,
      disp([' Station: ' OUTPUT(ind_r,:) ' ' OUTPUT(ind_Z,:)])
%        PAD1=zeros(Ndata,1);
%        PAD2=zeros(Ndata+Ndata/2,1);
       PAD=zeros(2*Ndata,1);
%PAD=[];
%      length(Ndata/2)
%      length(Ndata)
%      length(PAD1)
%      length(PAD2)
      [r,cc]=decon1([data1(1:Ndata,ind_r);PAD], [data1(1:Ndata,ind_Z);PAD], ...
             waterlevel,a,timeshift,header1(6,ind_r));
      length(r);
%      plot(real(r)); print; pause;
%      receiver_function=r;
      r=r(1:Ndata);
%      plot(real(r));
      data1(:,ind_r)=zeros(size(data1(:,ind_r)));
      data1(1:Ndata,ind_r)=real(r);                % replace radial component with receiver function
      index_keep=[index_keep, ind_r];
    end
  end
end
% delete all but the receiver functions
Tdur=header1(2,:);
window=[index_keep*0;Tdur(index_keep);index_keep];
[data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1,window);

WIN_INDEX=header1(5,:);
Nsta=length(WIN_INDEX);

return

[sta_names,lat,lon,sta_number,das_number,corr]= ...
  read_station_loc('/u1/pullen/matlab/dassl/station_loc');

dist=(Loc(2,WIN_INDEX) + 123.0240)*cos(47*pi/180) * 111.1; % distance from DOSW in km
hold off
clf
self_scale=max(abs(data1));
data0=zeros(size(data1));
iii=1:4:Ndata;
i1=max(iii);
gra=sign(0.5-gray)*.4 + .4; colormap(gra);
for i=1:Nsta    
  t=[0:Ndata-1]'*header1(6,i) - timeshift;
  %  y=data1(1:Ndata,i)/self_scale(i);
  y0=data1(1:Ndata,i);
  data0(1:Ndata,i)=y0;
  x=t(iii);
  y=y0(iii)*scale;
  fill_seismogram(x,y,dist(i))

%  patch([t(1);t(iii);t(i1)],dist(i)+y*scale,y);
%  line(t,dist(i)+y0*scale);
  if i==1, hold on; end
end
axis ([min(t), max(t), -5, 110])
xlabel('time (s)');ylabel('distance(km)')
%colormap(round(gra));
return
colormap(jet);
%colormap(gray); gra=round(flipud(gray)*10)/10; 
%gra=flipud(gray)-.5; gra=round(gra*15)/10; gra=max(gra,-.5); gra=min(gra,.5)+.5;
%colormap(gra);
disp('type any character to continue')
pause
clf
iii=1:Nsta;
dec_fact=10;   % decimation factor for display
data00=data0(1:dec_fact:Ndata,iii); 
time00=[0:dec_fact:Ndata-1]*header1(6,1)-timeshift;
surf(time00,dist(iii),data00',data00');view(0,80);shading('interp')
hold on
for i=1:Nsta
  plot3(time00,dist(i)*ones(size(time00)),data00(:,i)+.2,'k')
end
xlabel('time(s)'); ylabel('distance (km)');
hold off

