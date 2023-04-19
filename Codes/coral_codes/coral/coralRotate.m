function [data, ierr] = coralRotate(data,opt);
%   coralRotate    rotate seismograms in coral structure
% USAGE: [data, ierr] = coralDemean(data,opt);
%
% opt  = 'GCP'  :  rotate to the great circle path. component R is (positive away from source) while
%                  T is oriented 90 deg clockwize from R. 
%      = number :  rotate the 'N' or 'R' channel to this azimuth and the 'E' or 'T' channel to this azimuth+90
%
% See coral for explanation of data structure
%      = 0 if no errors
%      = 1 if data has something other than 2 seismograms
%      = 2 the component dip is not 0
%      = 3 the azimuth of the horizontals disagree by more than 90 degrees
%
% Assumptions:
%   there are exactly 2 seismograms, each with the same start time, number of data, sample interval and instrument response
%   they are both horizontal and one of them is at an azimuth 90 deg greater than than the other.
%   for internal purposes we call them y (azimuth=xi) and x (aximuth=xi+90)
%   For example if they are E and N, we call them E->x and N->y xi=0;
%   
% Options:
%   rotate to Transverse and Radial: x is rotated to T; y is rotated to R;
%   rotate to East and North:        x is rotated to E; y is rotated to N;
%   rotate to phi+90 and phi  :      x is rotated to 1; y is rotated to 2;
%
%
%  required fields: data, recAzimuth, recDip, eqlat, eqLon, staLat, staLon, recLog
%
% K. Creager  kcc@ess.washington.edu   5/27/2005; modified 5/10/2006

ierr=0;
ndata = length(data);
if ndata ~= 2;              % must be exactly 2 seismograms
  ierr = 1;
  return
end

if nargin<2;
  opt='GCP';  % default is to orient to source location
end

if strcmp(lower(opt(1)),'g')
  [delta, azim, backazim]=delaz([data.eqLat], [data.eqLon], [data.staLat], [data.staLon], 0);
  phi = backazim(1) - 180;
  phi = phi + 360*(phi<360);
  labels={'T' 'R'};
  reclog = 'rotate GCP;';
else
  phi=opt;
  if phi==0;
    labels={'E' 'N'};
  else
    labels={'1' '2'};
  end
  reclog = sprintf('rotate %d;',round(phi)); 
end


recAzimuth = [data.recAzimuth];
recDip     = [data.recDip];
if ~all(recDip==0);   % dip must be 0
  ierr=2
else
  diffAzimuth = recAzimuth(2) - recAzimuth(1);
  diffAzimuth = diffAzimuth + 360*(diffAzimuth<0);  % force diffAzimuth to be > 0.
  if abs(diffAzimuth - 270) <1; % they are ordered as E N, all is well
  elseif abs(diffAzimuth - 90) <1; % data are ordered as N E, change order
    if size(data,1)==1; ind =[2,1]; else; ind=[2,1]'; end
    data=data(ind);
  else
    ierr=3;
    return
  end
  % SHOULD CHECK THAT SEISMOGRAMS HAVE SAME START TIME AND DURATION AND GAIN.
  x=data(1).data;  %Data(ds1:ds1-1+nd,1)/Calib(2,1);
  y=data(2).data;  %Data(ds2:ds2-1+nd,2)/Calib(2,2);

  % rotate the "N" channel TO the azimuth PHI by a rotating both channels through the angle XI = PHI - original azimuth on "N" channel

  xi = phi - data(2).recAzimuth;
  data(1).data = -sin(xi*pi/180)*y + cos(xi*pi/180)*x;
  data(2).data = +cos(xi*pi/180)*y + sin(xi*pi/180)*x;
  for k=1:2;
    newAzim = data(k).recAzimuth + xi;
    newAzim = newAzim + 360*(newAzim<0) - 360*(newAzim>360); % force to be in range 0->360;
    data(k).recAzimuth   = newAzim;
    data(k).staChannel(3)= labels{k};
    data(k).recLog       = [data(k).recLog reclog]
  end
  if abs(diffAzimuth - 90) <1; % change order back to the way it was coming in.
    data=data(ind);
  end

end





