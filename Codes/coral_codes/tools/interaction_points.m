function [lats,lons,icvals,delt,azimturn,stuff]=interaction_points(elat,elon,edep,slat,slon,phase);
%   interaction_points  compute where rays turn and intersect CMB and inner-core
% usage: [lats,lons,icvals,delt,azimturn,stuff]=interaction_points(elat,elon,edep,slat,slon,phase);
% [M,N]=size(sum_ev_sta); phase=[];for k=1:N, phase=[phase;'PKIKP '];end
% usage: [lats,lons,icvals,delt]=interaction_points(...
% sum_ev_sta(5,:)',sum_ev_sta(6,:)',sum_ev_sta(2,:)',...
% sum_ev_sta(3,:)',sum_ev_sta(4,:)',phase)
%
% input parameters:
%  elat  =  geographic event   latitude  (deg) (column vector)
%  elon  =  geographic event   longitude (deg) (column vector)
%  edep  =  event depth (km)                   (column vector)
%  slat  =  geographic station latitude  (deg) (column vector)
%  slon  =  geographic station longitude (deg) (column vector)
%  phase =  PKP phase name (6 characters)   (character matrix)
%
% output parameters:
%  lats  =  15 column matrix containing 15 geographic latitudes (deg)  
%  lons  =  15 column matrix containing 15 geographic longitudes(deg)
%  delt  =  15 column matrix containing 15 distances from the event (deg)
%  the 15 columns of delt, lats, and lons are measured with respect to the 
%            event, station, turning point, CMB1, CMB2, ICB1, ICB2,
%            7 points that are 5 degrees towards the turning point from the 
%            above points, except the point corresponding to the turning 
%            point which is 2.5 degrees towards the station. A 15th point
%            is 2.5 degrees from the turning point, towards the event.
%  icvals=  4 column matrix containing inner core
%            ray length (km), ray colatitude(xi), ray longitude, cos(xi)^2
%  azimturn=  column vector of azimuth at the turning point (deg)
%  stuff =  3 column array containing the approximate ray parameter (s/deg)
%            the event to station azimuth (deg)
%            and the station to event azimuth (deg)
%
% calls delaz,coortr,delts,echo_ml,rot,scrot,euler_trans,sph2xyz,xyz2sph

nn=length(elat);
icvals=zeros(nn,4);

% calculate epicentral distance and event-to-station azimuth 
[del,azim,bakazim]=delaz(elat,elon,slat,slon,0);
% interpolate existing ray tables to obtain event to interaction points distances
[delt,dtdd]=delts(edep,del,phase);
stuff=[dtdd',azim,bakazim];
delt=[zeros(nn,1),delt];

% for each element of the vector rotate coordinate system using euler angles to
% determine the latitude and longitude of interaction points
% lat  and lon  are geocentric lat and lon (deg)
% lat0 and lon0 are geocentric colat and lon (deg)
% lats and lons are geographic lat and lon (deg)
% calculate the azimuth at the turning point (deg)

for ii=1:nn
  delt_temp=[delt(ii,:),delt(ii,:)+[1 -1 -.5 1 -1 1 -1]*5,delt(ii,3)+.5*5];
  [lat(:,ii),lon(:,ii)] = rot(elat(ii),elon(ii),azim(ii),delt_temp');
end
lat=lat';lon=lon';
lat0=90-lat;      
lon0=lon+(lon<0)*360;
[lats,lons]=coortr(lat*pi/180,lon*pi/180,1);
[temp,azimturn]=delaz(lats(:,3),lons(:,3),lats(:,2),lons(:,2),0);

% if phase if PKIKP calculate ray angles and lengths through the inner core
% assuming the ray paths are straight. For PREM, no ray path changes
% angle by more than one degree during transit through the inner core.
% v(1,:) and v(2,:) are the cartesian coordinates of the points where the
% rays intersect the inner core boundary (the inner core is assumed to be a 
% unit sphere). The vector d=v(1,:)-v(2,:) , when scaled by the radius of the
% inner core, gives the ray length, and ray direction (colat and longitude)
% when converted back to spherical coordinates.  The ray direction can be given as
% its direction, or its antipodal direction. We choose to force the ray to always
% point into the northern hemisphere.

for ii=1:nn
  phs=phase(ii,:);
  if strcmp(phs,'PKP   ') | strcmp(phs,'PKIKP '), 
    v=zeros(2,3); 
    [v(:,1),v(:,2),v(:,3)]=sph2xyz(ones(2,1),lat0(ii,6:7)',lon0(ii,6:7)');
    d=v(1,:)-v(2,:);
    raylen=1221.5*sqrt(d*d');
    [rr,raycolat,raylon]=xyz2sph(d(1),d(2),d(3));
    % this can point up or down, force it to always point up
    if raycolat>90,
      raycolat=180-raycolat;
      raylon=raylon-180;
      raylon=raylon+(raylon<0)*360;
    end
    cosxi=cos(raycolat*pi/180);
    icvals(ii,:)=[raylen,raycolat,raylon,cosxi*cosxi];
  else
    lats(ii,6:7)=[0,0];lons(ii,6:7)=[0,0];
  end
end
