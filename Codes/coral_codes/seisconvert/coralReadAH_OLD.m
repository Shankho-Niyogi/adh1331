function data=coralReadAH(ahfilename);
% readah    read data from an ah file into coral structure
% USAGE: data=coralReadAH(ahfilename);

itest=0;

if itest==2;  % determine number of seismograms and number of points in each seismogram
  tic
  fid=fopen(ahfilename);

  [X,count] = fread(fid,660,  'uchar'); % skip 760 characters
  i=0; checkCount = 0;
  while checkCount==0;
    i=i+1;
    N(i)=fread(fid,1,  'int32');          % read number of data in ith record
    [X,count] = fread(fid,1080-4+N(i)*4,  'uchar'); % skip to next record (number of data)
    checkCount = 1080-4+N(i)*4  -  count;
  end
  Nseis=i;
  toc
end


fid=fopen(ahfilename);    % open an ah file

for i=1:10e10;   % loop over each seismogram

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% read station information     536 bytes
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% skip 4 bytes and read station name (8 characters);  %break when at end of file
	[X,count] = fread(fid,4,  'uchar'); 
	if count~=4; break; end; 
	[X,count] = fread(fid,8 ,'uchar'); i1=min(find(X==0)); if length(i1)~=1; i1=length(X)+1; end
	D.staCode = char(X(1:i1-1)');
	
	% skip 4 bytes and read channel code (8 characters)
	[X,count] = fread(fid,4,  'uchar'); 
	[X,count] = fread(fid,8 ,'uchar'); i1=min(find(X==0)); if length(i1)~=1; i1=length(X)+1; end
	D.staChannel=char(X(1:i1-1)');
	
	% skip 4 bytes and read station type (8 characters)
	[X,count] = fread(fid,4,  'uchar'); 
	[X,count] = fread(fid,8 ,'uchar'); i1=min(find(X==0)); if length(i1)~=1; i1=length(X)+1; end
	D.staType = char(X(1:i1-1)');
  % decode network name, location code and quality code from staType if possible
  tmp1={'' '' ''};
  tmp = D.staType;
	ind=findstr(tmp ,'.');
  lenind=length(ind);
  if lenind>0; ind=[0 ind length(tmp)+1];
    for k=1:lenind+1;
      tmp1{k}=tmp(ind(k)+1:ind(k+1)-1);
    end;
  end;
  tmp1=deblank(tmp1);
  D.staNetworkCode   = tmp1{1};
  D.staLocationCode  = tmp1{2};
  D.staQualityCode   = tmp1{3};

	% read 5 real numbers containing staLat staLon staElev staGain staNormalization
	[X,c]=fread(fid,5,  'float32'); % read 5 real numbers
	[D.staLat,D.staLon,D.staElev,D.staGain,D.staNormalization] = deal(X(1),X(2),X(3),X(4),X(5));
	
	% read 120 real numbers that are later interpreted as complex vectors of staPoles and staZeros
	[X,c]=fread(fid,120,'float32'); 
  nPoles = X(1); Poles = complex(X(5:4:end),X(6:4:end)); 
  nZeros = X(3); Zeros = complex(X(7:4:end),X(8:4:end)); 
	D.staPoles = Poles(1:nPoles);
	D.staZeros = Zeros(1:nZeros); 
	%D.staPoles = complex(X(1:4:end),X(2:4:end)); 
	%D.staZeros = complex(X(3:4:end),X(4:4:end)); 
  D.staRespType = 'PZ';
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% read earthquake information    120 bytes  %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if itest==1;
    if exist('fid'); fclose(fid); end;  % close file if it is open
    fid=fopen(ahfilename);
    [X,count] = fread(fid,536,'uchar'); 
	end
	
	% read 3 real numbers containing eqLat eqLon eqDepth
	[X,c]=fread(fid,3,  'float32'); 
	[D.eqLat,D.eqLon,D.eqDepth] = deal(X(1),X(2),X(3));
	
	% read 5 integers, then 1 real number containing earthquake year, month, day, hour, minute, second
	[X,c]=fread(fid,5,  'int32'); 
	[X1,c]=fread(fid,1, 'float32'); 
	D.eqOriginTime = [X(:); X1];
	
	% skip 4 bytes and read earthquake comment (80 characters)
	[X,count] = fread(fid,4  ,'uchar'); 
	[X,count] = fread(fid,80 ,'uchar'); i1=min(find(X==0)); if length(i1)~=1; i1=length(X)+1; end
	D.eqComment=char(X(1:i1-1)');
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% read record information        336 bytes  %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if itest==1;
    if exist('fid'); fclose(fid); end;  % close file if it is open
    fid=fopen(ahfilename);
    [X,count] = fread(fid,536+120,'uchar'); 
	end
	
	% read 2 integers containing dataTypeFlag and numData
	[X,count] = fread(fid,2,'int32');
	dataTypeFlag = X(1);
	D.recNumData = X(2);
	
	% read 2 reals containing sampleInterval and maxAmp
	[X,count] = fread(fid,2,'float32');
	D.recSampInt = X(1);
	D.recMaxAmp  = X(2);
	
	% read 5 integers, then 1 real number containing start time of seismogram year, month, day, hour, minute, second
	[X, c]=fread(fid,5, 'int32'); 
	[X1,c]=fread(fid,1, 'float32'); 
	D.recStartTime = [X(:); X1];
	
	% read 1 real containing rmin but do not keep it
	[X,c]=fread(fid,1, 'float32'); 
	
	% skip 4 bytes and read record comment (80 characters)
	[X,count] = fread(fid,4,  'uchar'); 
	[X,count] = fread(fid,80 ,'uchar'); i1=min(find(X==0)); if length(i1)~=1; i1=length(X)+1; end
	D.recComment=char(X(1:i1-1)');
  % decode instrument dip and azimuth and units for instrument response if possible
  % should look like: Comp azm=0.0,inc=-90.0; Disp (m);

  azm=NaN;
  inc=NaN;
  k1=findstr('Comp',D.recComment);  % look for key string 'Comp'
  if length(k1)>0;
    k4=[ findstr(';',D.recComment)  findstr(',',D.recComment) ]; % numbers should end with ; or ,
    if length(k4)>0;
      k2=findstr('azm=',D.recComment);     % look for key string 'azm='
      if length(k2)>1; k2=k2(end); end;    % if more than one take the last one
      if length(k2)==1;
        kind = find(k4>k2);                % find the first terminator (; or ,) after the key word
        kend = min(k4(kind));
        [tmp, count, err]  = sscanf(D.recComment(k2+4:kend-1),'%f'); % interpret the string as a number 
        if count == 1 & length(err)==0; 
          azm  =  tmp;
        else
          disp(err);
        end
      end
      
      k2=findstr('inc=',D.recComment);     % look for key string 'inc='
      if length(k2)>1; k2=k2(end); end;    % if more than one take the last one
      if length(k2)==1;
        kind = find(k4>k2);                % find the first terminator (; or ,) after the key word
        kend = min(k4(kind));
        [tmp, count, err]  = sscanf(D.recComment(k2+4:kend-1),'%f'); % interpret the string as a number 
        if count == 1 & length(err)==0; 
          inc  =  tmp;
        else
          disp(err);
        end
      end
      
    end
  end
  D.recAzimuth = azm;
  D.recDip     = inc;
  
	% skip 4 bytes and read record log comment (202 characters)
	[X,count] = fread(fid,4  ,'uchar'); 
	[X,count] = fread(fid,204,'uchar'); i1=min(find(X==0)); if length(i1)~=1; i1=length(X)+1; end
	D.recLog = char(X(1:i1-1)');
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% read extras                    88  bytes  %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if itest==1;
    if exist('fid'); fclose(fid); end;  % close file if it is open
    fid=fopen(ahfilename);
    [X,count] = fread(fid,536+120+336,'uchar'); 
	end
	
	% skip 4 bytes and read extras (21 reals) 
	[X,count] = fread(fid,4  ,'uchar'); 
	[X,c]=fread(fid,21, 'float32');
	D.extras=X(:);
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% read data                      88  bytes  %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	if itest==1;
    if exist('fid'); fclose(fid); end;  % close file if it is open
    fid=fopen(ahfilename);
    [X,count] = fread(fid,536+120+336+88,'uchar'); 
	end
	
	% read data
	[X,c]=fread(fid,D.recNumData, 'float32');
	D.data = X(:);
	
	data(i)=D;
	clear D
end
fclose(fid);
