function [M,delt_hypo,delt_time,Mw]=getcmt(cmt,qtime,qlat,qlon,qdep);
%   getcmt        read Harvard Centroid Moment Tensor Catalog and find matching earthquake
% USAGE: [M,delt_hypo,delt_time]=getcmt(filename,qtime,qlat,qlon,qdep);
%
% This routine can be called in one of two modes:
% If there is only one imput argument then the input argument should be a character 
% string containing the filename for the Harvard CMT catalog.  
% read in HARVARD CMT catalog from filename and find the event that is 
% closest in time and space to input event. return the resulting cmt solution
% in M and the difference in location in delt_hypo (km) and in time in 
% delt_time (s).
% if only two arguments are entered, the second contains earthquake location 
% for each seismogram contained in the standard format of Loc.  Test that 
% each seismogram comes from the same event, and find the cmt solutions 
% closest to that event.  
% if only one input argument is given, read the cmt catalog and return the whole catalog
% in the matrix M.  
% the file format is either the Harvard standard Harvard 4-line ascii format, or
% a Matlab .mat file if the filename ends in '.mat'
% 
% M is returned as a 23 element row vector containing the event's year, month,
% day, hour, minute, second, lat, lon, depth (of ISC or NEIC event location)
% columns 10:11 are body-wave and surface wave magnitudes
% columns 12:23 are moment tensor component/uncertainty pairs in the same 
% order and coordinate system as the Harvard CMT solution.
% 
% Mw is the moment magnitude as referenced below.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  if first input argument is a character string, it is a file name
%  containing focal mechanisms such as the Harvard CMT.  If it is a mat file, 
%  load the mat file to return the matrix called cmt.  Look on the current search path 
%  for this file (append .mat in the search if it is not explicitly in the input file 
%  name).  If it is not on the search path then look for it in in the quakes directory.
%  if the file is a mat file, load it 
%   otherwise call readcmt to read an ascii file in the standard 4-line per event
%   Harvard format.
%   Regardless of the details, this block of code simply returns the matrix called cmt.
%   if cmt is already a matrix containing the focal mechanisms, skip this block of code.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% initialize output parameters
M=[];
delt_hypo=Inf;
delt_time=Inf;
Mw=Inf;

if strcmp(class(cmt), 'char');  % first input parameter is a character string so assume it is a filename for a cmt catalog
  
  filename = cmt;
  clear cmt;
  fullFilename=[];
  if exist(filename,'file');  % filename exists on search path
    fullFilename=filename;
  elseif exist([filename '.mat'],'file');  % filename exist on search path if .mat is appended to the name
    fullFilename=[filename '.mat'];
  else                  % filename does does not exist on curent path, look in quakes directory
                        %  find the location of this program (getcmt) and look in its parent directory 
                        % for the quaeks directory, look in quakes directory for the requested focal mechanism file 
    directory = which('getcmt'); % directory containing the code for getcmt
    iind=findstr('tools/getcmt.m',directory);
    if length(iind)>0
      directory = [directory(1:iind-2) '/quakes']; % directory containing CMT catalogs
      if exist([directory '/' filename],'file');  % filename exists in quakes directory
        fullFilename = [directory '/' filename],;
      elseif exist([directory '/' filename '.mat'],'file');  % filename exists in quakes directory with .mat appended
        fullFilename = [directory '/' filename '.mat'];
      end
    end
  end
   
  if length(fullFilename)==0;
    disp(sprintf('error, GETCMT cannot find the file named %s or %s', filename, fullFilename'))
    return
  end
   
  % first parameter is a filename and fullFilename exists
  
  % matFile = 1 if fullFilename ends in .mat otherwise it is 0;
  matFile=0;
  isMat = findstr('.mat',fullFilename);
  if length(isMat)>=1
    if length(fullFilename)==isMat(end)+3;  
      matFile=1;
    end
  end
  
  % if fullFilename is a .mat file read it using load, otherwise use read_cmt
  if isMat;   
    eval (['load ' fullFilename]);            % load the entire cmt catalog from a .mat file
  else
    cmt=read_cmt(fullFfilename);               % read the ascii (4-line) harvard format cmt file
  end
end

%  Now we should have the matrix called cmt containing focal mechanisms for one or more earthquake

% if there is only one innput argument, there should be only one output argument
% in this case the input argument is a filename and the output is the whole cmt catalog that 
% was read in. there is no further information available to select a particular event
if nargin==1,
  if nargout==1,
    M=cmt;
    return
  else
    disp('error in GETCMT: if there in only one input argument there must be only one output argument')
  end
end



%%%%% REMOVE NFOLLOWING IF BLOCK   %%%%%

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
  end

if nargin==2,
  % if there are two arguments, the second arrument should be either a "Loc" 
  % matrix (from coral) or a data structure from the new version of coral. 
  % A Loc matrix contains eqrthquake lat, lon and depth in rows 4:6 and
  % earthquake origin time in rows 7 and 8 in the form YYYY.MMDD  HHMMSS.SSSS
  % If Loc has more than one column, the 4:8 elements of each column must be identical
  %
  % if the second argument is a structure from new coral format it must contain the fields
  % eqLat, eqLon, eqDepth, eqOriginTime    

  if strcmp(class(qtime), 'double');  % second input parameter is a matrix, so assume it contains the location of an earthquake

    a=qtime(4:8,:);
    [aRows,aCols] = size(a);
    if aCols > 1
      if sum( max(a')-min(a') ) > 0,
        disp('error in GETCMT, the seismograms come from different earthquakes')
        M=[]; delt_hypo=Inf; delt_time=Inf; Mw=Inf
        return
      end
    end
    a=qtime(:,1);qtime=a(7:8);qlat=a(4);qlon=a(5);qdep=a(6);
    
  elseif strcmp(class(qtime), 'struct');  % second input parameter is a structure, so assume it contains the location of an earthquake
    oneEq=1;
    a = [qtime(:).eqLat];       if max(a)-min(a)<1e-4;  qlat=a(1); else oneEq=0; end
    a = [qtime(:).eqLon];       if max(a)-min(a)<1e-4;  qlon=a(1); else oneEq=0; end
    a = [qtime(:).eqDepth];     if max(a)-min(a)<1e-2;  qdep=a(1); else oneEq=0; end
    b = [qtime(:).eqOriginTime];a=timediff(b); if max(a)-min(a)<1e-3;  qtime=time_reformat(b(:,1)); else oneEq=0; end
    if oneEq==0
      disp('error in GETCMT, the seismograms come from different earthquakes')
      M=[]; delt_hypo=Inf; delt_time=Inf; Mw=Inf;
      return
    end
  end  
        
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
