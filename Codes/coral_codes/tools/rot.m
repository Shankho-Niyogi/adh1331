function [slat,slon] = rot(elat,elon,azim,delt);
%   rot           calculate latitude, longitude from reference location, azimuth, distance
% usage: [slat,slon] = rot(elat,elon,azim,delt);
%
% input parameters:
%
%   elat = geocentric event latitude in degrees (scalar)
%   elon = geocentric event longitude in degrees (scalar)
%   azim = event to station azimuth in degrees (column vector or scalar)
%   delt = event to station distances in degrees (column vector)
%
% outout parameters:
%
%   slat = geocentric station latitudes in degrees (column vector)
%   slon = geocentric station longitudes in degrees (column vector)
%
% calls scrot and euler_trans
% see also lld2xyz and xyz2lld

f  = pi/180;
e2 = (elat-90)*f;
e3 =-(elon+90)*f;
phi=zeros(size(delt));

%  need to loop over each distinct azimuth because the rotation matrix can
%  handle multiple distances, but must be reevaluated for each new azimuth.

n=length(azim);
if n==1,
  e1 = (azim-90)*f;
  [th2,ph2,az0]=scrot(euler_trans(e1,e2,e3), delt*f, phi*f);
else
  th2=zeros(size(delt));ph2=th2;az0=th2;
  temp=sort(azim);
  nnn=sum(diff(temp)~=0)+1;            % number of distinct values of azim
  if nnn/n<.8,                         % if more than 20% of azimuths are repeated then
    AZIM=temp([1;find(diff(temp))+1]); % make a list of distinct values of azim
    for i=1:nnn                        % and calculate only one rotation matrix for 
      az1=AZIM(i);                     % each distinct azimuth
      e1 = (az1-90)*f;
      ii=find(azim==AZIM(i));
      [th2(ii),ph2(ii),az0(ii)]=scrot(euler_trans(e1,e2,e3), delt(ii)*f, phi(ii)*f);
    end
  else                                 % else loop over all azimuths
    for ii=1:n
      az1=azim(ii);
      e1 = (az1-90)*f;
      [th2(ii),ph2(ii),az0(ii)]=scrot(euler_trans(e1,e2,e3), delt(ii)*f, phi(ii)*f);
    end
  end
end
slat=90-th2/f;
slon=ph2/f;
