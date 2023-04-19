function varargout=ReadUW(varargin);

% function [hdr,seis] = ReadUW(filename);
% function [hdr,seis] = ReadUW(filename,byteorder,datapath,pickpath);
% function [hdr,seis,masthdr] = ReadUW(...);
% 
% This function reads UW2 format data files (e.g. 05011611163W) (and,
% optionally, matching pick files) into Matlab. It uses Matlab's fopen,
% fread, fgetl, and fseek programs for reading binary data files and
% pickfiles. As such, NO UW interface libraries are required for this program
% to work!1!!1one
%
% Input arguments are the following:
%
% filename	String, e.g. '04093023532W'. This can be either a pickfile
% 		name, a datafile name, or a pickfile name that's missing the
% 		last letter (e.g. 04093023532). If this ends in a D or W,
% 		ReadUW will only read in the data file. If this ends in a
% 		lowercase letter, ReadUW will read in both the data file and
% 		the pickfile. If this ends in a digit, ReadUW will behave as
% 		follows: 
%		
%		1. Search datapath for first match to this filename ending in
%		a D or W. This will be read in as the data file.
%
%		2. Search pickpath for first match to this filename ending in
%		any lowercase letter. This will be read in as the pick file.
% 		
%
% byteorder	OPTIONAL. String to determine byte order in call to fopen(). 
%		If not specified, defaults to numeric format of whatever
%		machine you used to invoke MATLAB. Acceptable values are:
%
% 'cray' or 'c' 	Cray floating point, big-endian byte ordering
% 'ieee-be' or 'b' 	IEEE floating point, big-endian byte ordering
% 'ieee-le' or 'l' 	IEEE floating point, little-endian byte ordering
% 'ieee-be.l64' or 's'	IEEE floating point with big-endian byte ordering and
% 			64-bit long data type
% 'ieee-le.l64' or 'a'	IEEE floating point with little-endian byte ordering
% 			and 64-bit long data type
% 'native' or 'n' 	Numeric format of the machine on which MATLAB is
% 			running (Default)
% 'vaxd' or 'd' 	VAX D floating point and VAX ordering
% 'vaxg' or 'g' 	VAX G floating point and VAX ordering
%
% datapath	OPTIONAL. String name of environmental variable describing 
%		seismic data path search order. Defaults to the variable 
% 		name 'USER_DATA_PATH' used by the University of Washington
% 		seismology group. Type 'env' at a command prompt if you do
% 		not know this. 
%		
% pickpath	OPTIONAL. String name of environmental variable describing 
%		path to pick files. Defaults to your 'PATH' variable. Type 
%		'env' at a command prompt for details.
%		
%
% The function returns two (optionally three) structures: hdr, seis, and
% optionally masthdr, a structure with header info for all channels stripped
% from the data file. This is optional because I can't figure out what it's
% good for.
%
% hdr		UW2 channel headers and pickfile info. A cell structure
% 		referencing channel header values by channel number (set
% 		using  hdr.nchan). Variable names are generally the same as
% 		in uwdfif.* but are always referenced by channel number.
%
% seis		Seismograms. A cell structure referencing seismograms by
%		channel number: seis{1} = seismic data of channel 1, etc.
%
% masthdr	UW2 master header. A structure of master header
% 		values. Variable names are the same as in uwdfif.*
%		OPTIONAL because I don't see a use for this in Matlab.
%
%
% NOTES: 
%
% 1. Do not use this on totally unprocessed waveform data, unless you're
% absolutely certain that it contains a special channel structure at the end
% of the file. This channel structure must be there.
%
% 2. Beta version notice: This currently doesn't handle the time correction
% structure of type TC2, because I haven't yet figured out its actual
% structure. This incidentally causes 1., immediately above.
%
% Author: Josh Jones, josh@ess.washington.edu

% Parse varargin
filename = varargin{1};
if nargin > 3
  byteorder = varargin{2};
  datapath = varargin{3};
  pickpath = varargin{4};
elseif nargin > 2
  byteorder = varargin{2};
  datapath = varargin{3};
  pickpath = 'PATH';
elseif nargin > 1
  byteorder = varargin{2};
  datapath = 'USER_DATA_PATH';
  pickpath = 'PATH';
else
  byteorder = 'n';
  datapath = 'USER_DATA_PATH';
  pickpath = 'PATH';
end

% Use varargin{1} to set filenames
ext = (filename(length(filename)));
if strcmp(ext,'W') | strcmp(ext,'D') 
  disp('UW data file specified. Reading data file only.');
  df1 = findfile(filename,datapath);
elseif regexp(ext,'[a-z]')
  disp('UW pick file specified. Reading pick and data files.');
  if strcmp(ext,'d')
    dfname = strcat(filename(1:length(filename)-1),'D');
    df1 = findfile(dfname,datapath);
    pfname = filename;
    pf1 = findfile(pfname,pickpath);
  else
    dfname = strcat(filename(1:length(filename)-1),'W');
    df1 = findfile(dfname,datapath);
    pfname = filename;
    pf1 = findfile(pfname,pickpath);
  end  
elseif regexp(ext,'[0-9]')
  disp(['Generic UW file specified. Searching for data and pick files.']);
  dfext = {'D' 'W'};
  df1 = findfile(filename,datapath,dfext);
  pfext = {'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' ...
	   'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z'};
  pf1 = findfile(filename,pickpath,pfext);
end

% Open data file
fid=fopen(df1,'r',byteorder);

% Set number of expansion structures. Currently hard set to 1, as per uwdfif.c
no_expan_structs = 1;

% Get UW2 master header
masthdr.nchan 	= fread(fid,1,'int16');
masthdr.lrate 	= fread(fid,1,'int32');
masthdr.lmin 	= fread(fid,1,'int32');
masthdr.lsec 	= fread(fid,1,'int32');
masthdr.length 	= fread(fid,1,'int32');
masthdr.tapenum	= fread(fid,1,'int16');
masthdr.eventnum	= fread(fid,1,'int16');
masthdr.flags	= fread(fid,10,'int16');
masthdr.extra	= char(fread(fid,10,'char')); % hdr.extra(3) sets format
masthdr.comment	= char(fread(fid,80,'char'));

% Set masthdr time using lmin and lsec
[masthdr.yr, masthdr.mo, masthdr.dy, masthdr.hr, masthdr.mn, masthdr.sc] = ...
    datevec(datenum((masthdr.lmin/1440) + (masthdr.lsec/8.64e10)) + ...
	    datenum(1600,1,1));

% Set header comment correctly for Matlab
masthdr.comment = masthdr.comment';
masthdr.comment = strcat(masthdr.comment);

% Seek to end of file
fseek(fid, -4, 'eof');

% Get number of structures
nstructs=fread(fid,no_expan_structs,'int32');

% Set format of UW seismic data file
if strcmp(masthdr.extra(3),'2')
  uwformat = 2;
else
  uwformat = 1;
end

% Read in UW2 data structures to determine number of channels
if uwformat == 2
  fseek(fid,(-12*no_expan_structs)-4,'eof');
  for i1 = 1:1:no_expan_structs
    structtag = fread(fid,4,'char');
    struct1 = char(structtag);
    structtag = strcat([struct1(1) struct1(2) struct1(3) struct1(4)]);
    nstructs = fread(fid,1,'int32');
    byteoffset = fread(fid,1,'int32');
    if strcmp(structtag,'CH2')
      hdr.nchan = nstructs;
    elseif strcmp(structtag,'TC2')
      disp(['Time correction structure found at ' num2str(byteoffset) '! Not' ...
	    ' yet implemented. Don''t say I didn''t warn you.']);
    end
  end
else
  hdr.nchan = masthdr.nchan;
end

disp(['Processing ' num2str(hdr.nchan) ' channels.']);

% Read all UW2 channel headers
if uwformat == 2
  fseek(fid,(-56*hdr.nchan)-(12*no_expan_structs)-4,'eof');
  for i1=1:hdr.nchan
    hdr.chlen(i1) 	= fread(fid,1,'int32');
    hdr.offset(i1) 	= fread(fid,1,'int32');
    hdr.start_lmin(i1) 	= fread(fid,1,'int32');
    hdr.start_lsec(i1)	= fread(fid,1,'int32');
    % Set time for each trace
    [hdr.yr(i1), hdr.mo(i1), hdr.dy(i1), hdr.hr(i1), hdr.mn(i1), hdr.sc(i1)] = ...
	datevec(datenum((hdr.start_lmin(i1)/1440) + (hdr.start_lsec(i1)/8.64e10)) + ...
		datenum(1600,1,1));    
    hdr.Fs(i1) 		= fread(fid,1,'int32')/1000; % Samples per 1,000 seconds?
						     % What the f...?
    hdr.expan1(i1)	= fread(fid,1,'int32');
    hdr.lta(i1)		= fread(fid,1,'int16');
    hdr.trig(i1)	= fread(fid,1,'int16');
    hdr.bias(i1)	= fread(fid,1,'int16');
    hdr.fill(i1)	= fread(fid,1,'int16');

    name		= char(fread(fid,8,'char')); 
    name = name'; hdr.name{i1} = strcat(name);
    
    tmp			= char(fread(fid,4,'char')); 
    for j1=1:length(tmp)
      if strcmpi(tmp(j1),'f') 
	fmt{i1} = 'float32';
      elseif strcmpi(tmp(j1),'l') 
	fmt{i1} = 'int32';
      elseif strcmpi(tmp(j1),'s') 
	fmt{i1} = 'int16';
      end
    end
 
    compflg		= char(fread(fid,4,'char'));
    compflg = compflg'; hdr.compflg{i1} = strcat(compflg);
    
    chid		= char(fread(fid,4,'char'));
    chid = chid'; hdr.chid{i1} = strcat(chid);
    
    expan2		= char(fread(fid,4,'char'));
    expan2 = expan2'; hdr.expan2{i1} = strcat(expan2);    
  end
end

% Read all UW2 data
if uwformat == 2
  for i1=1:hdr.nchan
    fseek(fid,hdr.offset(i1),'bof');    
    seis{i1} = fread(fid,hdr.chlen(i1),fmt{i1});	
  end
end

% Close file
fclose(fid);

% Done
disp('Done reading data file.');

% Find pickfile if one is specified
if exist('pf1','var')

  % Does the pickfile exist?
  ftest=exist(pf1,'file');
  if ftest == 2
    dopf = 1;
  end

  % If so, we continue
  if exist('dopf','var')
    disp('Reading pickfile');
    pfid=fopen(pf1,'r',byteorder);

    % Process Acard line
    acard = nextline(pfid,'A');

    if length(acard) == 75 | length(acard) == 12
      y2k = 0;
    else
      y2k = 2;
    end
    
    % Set offset as necessary
    hdr.type = acard(2);
    %hdr.yr = str2num(acard(3:4+y2k));
    %hdr.mo = str2num(acard(5+y2k:6+y2k));
    %hdr.dy = str2num(acard(7+y2k:8+y2k));
    %hdr.hr = str2num(acard(9+y2k:10+y2k));
    %hdr.mn = str2num(acard(11+y2k:12+y2k));

    if length(acard) > (14+y2k)
      %hdr.sc = str2num(acard(13+y2k:18+y2k));
      hdr.lat = str2num(acard(19+y2k:21+y2k)) + ...
	  (str2num(acard(23+y2k:24+y2k)))/60 + ...
	  (str2num(acard(25+y2k:26+y2k)))/6000;
      latcode = acard(22+y2k);
      if strcmp(latcode,'S')
	hdr.lat = -hdr.lat;
      end
      hdr.lon = str2num(acard(27+y2k:30+y2k)) + ...
	  (str2num(acard(32+y2k:33+y2k)))/60 + ...
	  (str2num(acard(34+y2k:35+y2k)))/6000;
      loncode = acard(31+y2k);
      if strcmp(loncode,'W')
	hdr.lon = -hdr.lon;
      end
      hdr.z = str2num(acard(36+y2k:41+y2k));
      hdr.fix = acard(42+y2k);
      hdr.mag = str2num(acard(43+y2k:46+y2k));
      hdr.numsta = str2num(acard(47+y2k:49+y2k));
      hdr.numpha = str2num(acard(51+y2k:53+y2k));
      hdr.gap = str2num(acard(54+y2k:57+y2k));
      hdr.dmin = str2num(acard(58+y2k:60+y2k));
      hdr.rms = str2num(acard(61+y2k:65+y2k));
      hdr.err = str2num(acard(66+y2k:70+y2k));
      hdr.q = acard(71+y2k:72+y2k);
      hdr.velmodel = acard(74+y2k:75+y2k);
    elseif length(acard) > 12+y2k
      hdr.region = acard(14+y2k);
    end
    
    % Done processing Acard line
    
    % Process error line
    fseek(pfid,0,'bof');
    eline = nextline(pfid,'E');    
    
    if eline ~= -1
      hdr.MeanRMS = str2num(eline(12:17));
      hdr.SDabout0 = str2num(eline(18:23));
      hdr.SDaboutMean = str2num(eline(24:29));
      hdr.sswres = str2num(eline(30:37));
      hdr.ndfr = str2num(eline(38:41));
      hdr.fixxyzt = eline(42:45);
      hdr.SDx = str2num(eline(46:50));
      hdr.SDy = str2num(eline(51:55));
      hdr.SDz = str2num(eline(56:60));
      hdr.SDt = str2num(eline(61:65));
      hdr.SDmag = str2num(eline(66:70));
      hdr.MeanUncert = str2num(eline(76:79));
    else
      fseek(pfid,0,'bof');
    end
    
    % Process alternate magnitude line
    fseek(pfid,0,'bof');
    sline = nextline(pfid,'S');

    if sline ~= -1
      disp('Alternate magnitude found! WARNING: Supercedes coda magnitude.');
      hdr.mag = str2num(sline(1:5));
      hdr.magtype = sline(6:8);
    else
      fseek(pfid,0,'bof');
    end

    % Process focal mechanism line
    fseek(pfid,0,'bof');    
    m1 = 0;
    mline = nextline(pfid,'M');
    while mline ~= -1
      m1=m1+1;
      hdr.mech{m1,1}=str2num(mline(5:7));
      hdr.mech{m1,2}=str2num(mline(9:10));      
      hdr.mech{m1,3}=str2num(mline(14:16));
      hdr.mech{m1,4}=str2num(mline(18:19));
      hdr.mech{m1,5}=str2num(mline(23:25));
      hdr.mech{m1,6}=str2num(mline(27:28));
      hdr.mech{m1,7}=str2num(mline(32:34));
      hdr.mech{m1,8}=str2num(mline(36:37));      
      hdr.mech{m1,9}=str2num(mline(41:43));
      hdr.mech{m1,10}=str2num(mline(45:46));
      hdr.mech{m1,11}=str2num(mline(50:52));
      hdr.mech{m1,12}=str2num(mline(54:55));
      mline = nextline(pfid,'M');
    end
    
    % Process pick lines
    fseek(pfid,0,'bof');   
    m1 = 0;
    pline = nextline(pfid,'.');
    while pline ~= -1    
      m1=m1+1;
      pline = pline(2:length(pline));
      sta = pline(1:3);
      cmp = pline(5:7);
      
      for j1=1:length(hdr.name)
	if strcmpi(hdr.name{j1},sta) & strcmpi(hdr.compflg{j1},cmp)
	  [tmp,rem] = strtok(pline);
	  while 1
	    [tmp,rem] = strtok(rem,')');
	    [dummy,tmp] = strtok(tmp,'(');
	    if isempty(rem) | isempty(tmp)
	      break
	    end

	    if strcmp(tmp(2),'P')
	      [tmp,dummy] = strtok(tmp(2:length(tmp)));
	      [ptype,dummy] = strtok(dummy);
	      [ppol,dummy] = strtok(dummy);
	      [ptime,dummy] = strtok(dummy);
	      [pqual,dummy] = strtok(dummy);
	      [punc,dummy] = strtok(dummy);
	      [perr,dummy] = strtok(dummy,')');
	      if strcmp(ptype,'P')		
		hdr.P(j1) = str2num(ptime);
		hdr.Ppol{j1} = ppol;
		hdr.Pqual(j1) = str2num(pqual);
		hdr.Punc(j1) = str2num(punc);
		hdr.Perr(j1) = str2num(perr);
	      elseif strcmp(ptype,'S')
		hdr.S(j1) = str2num(ptime);
		hdr.Spol{j1} = ppol;
		hdr.Squal(j1) = str2num(pqual);
		hdr.Sunc(j1) = str2num(punc);
		hdr.Serr(j1) = str2num(perr);
	      end
	    elseif strcmp(tmp(2),'D')
	      [tmp,dummy] = strtok(tmp(2:length(tmp)));
	      [dur,dummy] = strtok(dummy);
	      hdr.dur(j1) = str2num(dur);
	    end	    
	  end
	end
      end
      pline = nextline(pfid,'.');
    end
    
    % Close pickfile
    fclose(pfid);
    
    % Done
    disp('Done reading pickfile.');
    
    % Postprocess
    % Step 1: Insure that all events have a P, S, and duration
    if isfield(hdr,'P') && length(hdr.P) < length(hdr.name)
      hdr.P(length(hdr.P)+1:length(hdr.name)) = 0;
    elseif ~isfield(hdr,'P')
      hdr.P(1:length(hdr.name)) = 0;
    end
    
    if isfield(hdr,'S') && length(hdr.S) < length(hdr.name)
      hdr.S(length(hdr.S)+1:length(hdr.name)) = 0;
    elseif ~isfield(hdr,'S')
      hdr.S(1:length(hdr.name)) = 0;
    end
    
    if isfield(hdr,'dur') && length(hdr.dur) < length(hdr.name)
      hdr.dur(length(hdr.dur)+1:length(hdr.name)) = 0;
    elseif ~isfield(hdr,'dur')
      hdr.dur(1:length(hdr.name)) = 0;
    end
    
    % Step 2: If a pick is zero, make sure it has obvious polarity, quality,
    % uncertainty, and error values
    for j1=1:length(hdr.P)
      if hdr.P(j1) == 0
	hdr.Ppol{j1} = [];
	hdr.Pqual(j1) = 4;
	hdr.Punc(j1) = 1;
	hdr.Perr(j1) = 10;
      end
      if hdr.S(j1) == 0
	hdr.Spol{j1} = [];
	hdr.Squal(j1) = 4;
	hdr.Sunc(j1) = 1;
	hdr.Serr(j1) = 10;
      end
    end
  else
    disp('Skipped reading pickfile due to invalid path or filename.');
  end
end

% Clean up hdr structure
hdr = rmfield(hdr,'offset');
hdr = rmfield(hdr,'chlen');

% Set output arguments
varargout{1} = hdr;
varargout{2} = seis;
if nargout > 2
  varargout{3} = masthdr;
end

% End main program
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function tmpstring = nextline(pfid,ch)
tmpstring = fgetl(pfid);
while tmpstring(1) ~= ch
  tmpstring = fgetl(pfid);
  if tmpstring == -1
    break
  end
end
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function fname = findfile(varargin);
filename = varargin{1};
path = getenv(varargin{2});
rem = '';
if nargin == 3
  ext = varargin{3};
end
% Try to find data file in current directory
if nargin == 2
  fname = fullfile(pwd,filename);
  test1 = exist(fname,'file');
else
  for j1=1:length(ext)
    filename1 = strcat(filename,ext{j1});
    fname = fullfile(pwd,filename1);
    test1 = exist(fname,'file');
    if test1 == 2
      break
    end
  end
end

% Try to find and open data file in other path directories if this fails
while test1 ~= 2
  if ~isempty(path)
    [path,rem] = strtok(rem,':');
    if nargin == 2
      fname = fullfile(path,filename);
      test1 = exist(fname,'file');      
    else
      for j1=1:length(ext)
	filename1 = strcat(filename,ext{j1});
	fname = fullfile(path,filename1);
	test1 = exist(fname,'file');
	if test1 == 2
	  disp(['Found ' strcat(filename,ext{j1}) ' in path ' path]);
	  break
	end
      end
    end
  else
    if nargin == 3
      if strcmp(ext{1},'a')
	disp(['No file matching ' filename '[a-z] found in path ' ...
	      getenv(varargin{2})]);
      elseif strcmp(ext{1},'G')
	disp(['No file matching ' filename '[G,W] found in path ' ...
	      getenv(varargin{2})]);
      end
    end
    errcode = 1;
    break
  end
end

if exist('errcode','var') ~= 1
  disp(['Matching file found at ' fname]);
end
% --------------------------------------------------------------------
