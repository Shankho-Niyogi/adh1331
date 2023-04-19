function [M,delt_hypo,delt_time,Mw]=getcmt(filename,qtime,qlat,qlon,qdep);
%   getcmt        read Harvard Centroid Moment Tensor Catalog and find earthquake
% USAGE: [M,delt_hypo,delt_time]=getcmt(filename,qtime,qlat,qlon,qdep);
%
% read in HARVARD CMT catalog from filename and find the event that is 
% closest in time and space to input event. return the resulting cmt solution
% in M and the difference in location in delt_hypo (km) and in time in 
% delt_time (s).
% if only two arguments are entered, the second contains earthquake location 
% for each seismogram contained in the standard format of Loc.  Test that 
% each seismogram comes from the same event, and find the cmt solutions 
% closest to that event.  
% if only one input argument is given, the filename is assumed to be in the 
% standard Harvard 4 line format, and it is assumed that there is only one 
% event in the file.
% otherwise the format is the standard Harvard 4-line ascii format, or
% a Matlab .mat file if the filename ends in '.mat'
% 
% M is returned as a 23 element row vector containing the events year, month,
% day, hour, minute, second, lat, lon, depth (of ISC or NEIC event location)
% columns 10:11 are body-wave and surface wave magnitudes
% columns 12:23 are moment tensor component/uncertainty pairs in the same 
% order and coordinate system as the Harvard CMT solution.
% 
% Mw is the moment magnitude as referenced below.

if nargin==1,
  cmt=read_cmt(filename);                 % read the ascii (4-line) harvard format cmt file
  if size(cmt,1)==1,
    M=cmt; delt_hypo=0; delt_time=0;
	diags    =M(:,12:2:16);
	off_diags=M(:,18:2:22);
	temp=diags.*diags + 2*off_diags.*off_diags;
	Mo=sqrt(sum(temp')/2);  
	% equation for Mw is from [Hanks, T. C., and H. Kanamori, 
	% A moment Magnitude Scale, J. Geophys. Res, 84, 2348-2350, 1979]
	% See also CMR Fowler's book eq 4.23:
	Mw = round(10*((2/3) * log10(Mo) - 10.7))/10;
  else
    disp('error in getcmt: must have more than one input argument')
    disp('or only one event in the earthquake catalog')
    M=0; delt_hypo=0; delt_time=0;
  end
  return
end

if nargin==2,
  a=qtime(4:8,:);
  [aRows,aCols] = size(a);
  if aCols > 1
    if sum( max(a')-min(a') ) > 0,
      disp('error in getcmt, the seismograms come from different earthquakes')
      M=0; delt_hypo=0; delt_time=0;
      return
    end
  end
  a=qtime(:,1);qtime=a(7:8);qlat=a(4);qlon=a(5);qdep=a(6);
end
lenfil=length(filename);
if filename(lenfil-3:lenfil)=='.mat',
  eval (['load ' filename]);            % load the entire cmt catalog from a .mat file
else
  cmt=read_cmt(filename);                 % read the ascii (4-line) harvard format cmt file
end
times=time_reformat(cmt(:,1:6)');       % reformat the date/time

% calculate differential time in sec between desired event and all cmt events
dtimes=timediff([qtime times]);  dtimes=dtimes(2:length(dtimes(1,:)))';

% get the latitude, longitude, and depth of each event 
dlat=abs(cmt(:,7)-qlat);
dlon=rem(abs(cmt(:,8)-qlon),360); dlon=abs(360*(dlon>180)-dlon);
ddep=abs(cmt(:,9)-qdep);

% x is the approximate squared distance from the desired event to all the events in 
% the catalog where a characteristic velocity v (seismic wave speed) relates time 
% to distance.
clat=cos(cmt(:,7)*pi/180);clat2=clat.*clat;
v=5;    %km/s.
x=v*v*dtimes.*dtimes + ddep.*ddep + 111*111*(dlat.*dlat + clat2.*dlon.*dlon); 
index=find(x==min(x));                    % find index of closest event
M=cmt(index,:); 
delt_time=dtimes(index);
delt_hypo=sqrt(x(index)-v*v*dtimes(index).*dtimes(index));
% find Mw:
diags    =M(:,12:2:16);
off_diags=M(:,18:2:22);
temp=diags.*diags + 2*off_diags.*off_diags;
Mo=sqrt(sum(temp')/2);  
Mw = round(10*((2/3) * log10(Mo) - 10.7))/10;
