function varargout = uw2coral(varargin);
% Read a UW file and rearrange headers and data for Coral. Do "help ReadUW"
% for details and input arguments.
%
% Possible outputs are:
%
% D = uw2coral(...);		Outputs data matrix D in Coral format.
% [D,masthdr] = uw2coral(...);	Outputs data matrix D and UW format master
%				data header.
% [D,masthdr,hdr] = ... ;	Outputs data matrix, UW master header, and UW
% 				channel headers.
% [D,masthdr,hdr,seis] = ... ;	Outputs all of the above, plus a cellstruct
% 				containing the seismic data in SEIS.

% Literally the same parsing of varargin as ReadUW.m. I cut and pasted.
% There is one added argument: Filename with the station elevations in UW format.
filename = varargin{1};
if nargin > 4
  byteorder = varargin{2};
  datapath = varargin{3};
  pickpath = varargin{4};
  stafile = varargin{5};
elseif nargin > 3
  byteorder = varargin{2};
  datapath = varargin{3};
  pickpath = varargin{4};
  stafile = '/stor/seis/wash.sta';
elseif nargin > 2
  byteorder = varargin{2};
  datapath = varargin{3};
  pickpath = 'PATH';
  stafile = '/stor/seis/wash.sta';
elseif nargin > 1
  byteorder = varargin{2};
  datapath = 'USER_DATA_PATH';
  pickpath = 'PATH';
  stafile = '/stor/seis/wash.sta';
else
  byteorder = 'n';
  datapath = 'USER_DATA_PATH';
  pickpath = 'PATH';
  stafile = '/u0/josh/wash.sta';
end

% Call to ReadUW
[hdr,seis,masthdr] = ReadUW(filename,byteorder,datapath,pickpath);

% Set number of stations
nst = length(hdr.name);

% Rearrange
for j=1:nst
  D(j).data = seis{j};
  D(j).recNumData = length(seis{j});
  D(j).staCode = hdr.name{j};
  D(j).staChannel = hdr.compflg{j};
  D(j).staNetwork = 'UW';
  D(j).recSampInt = 1/hdr.Fs(j);
  D(j).recLog = 'readUW';
  D(j).staLocationCode='';
  D(j).staQualityCode='';
  D(j).staInstType='';

  % Get station coordinates from station file
  eval(['[status,coordline] = system(''grep ' D(j).staCode ' ' stafile ...
	' | head -1'');']);
  if status == 0
    [tmp,rem] = strtok(coordline);
    [lat,rem] = strtok(rem);
    [latm,rem] = strtok(rem);
    [lats,rem] = strtok(rem);
    D(j).staLat = str2num(lat) + (str2num(latm)/60) + (str2num(lats)/3600);
    [lon,rem] = strtok(rem);
    [lonm,rem] = strtok(rem); 
    [lons,rem] = strtok(rem); 
    D(j).staLon = -(str2num(lon) + (str2num(lonm)/60) + (str2num(lons)/3600));
    [tmp,rem] = strtok(rem);
    D(j).staElev = str2num(tmp)*1000;
  else
    disp(['Could not find ' D(j).staCode ' in ' stafile ... 
	  '! Not setting this station''s coordinates!']);
  end
  
  D(j).recStartTime = [hdr.yr(j) hdr.mo(j) hdr.dy(j) hdr.hr(j) hdr.mn(j) hdr.sc(j)]';
  
  % Set component dip and azimuth
  cmp = D(j).staChannel(length(D(j).staChannel));
  if strcmpi(cmp,'z')
    D(j).recDip = -90; D(j).recAzimuth= 0;
  elseif strcmpi(cmp,'n')
    D(j).recDip =   0; D(j).recAzimuth= 0;
  elseif strcmpi(cmp,'e')
    D(j).recDip =   0; D(j).recAzimuth= 90;
  else
    disp(['Warning! Station ' D(j).staCode ' component ' D(j).staChannel ...
	  'appears not to be seismic data! Dip and Azimuth set to 0!']);
    D(j).recDip =   0; D(j).recAzimuth= 0;
  end  
end

varargout{1} = D;
if nargout > 1
  varargout{2} = masthdr;
  if nargout > 2
    varargout{3} = hdr;
    if nargout > 3
      varargout{4} = seis;
    end
  end
end
