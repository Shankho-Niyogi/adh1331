function D=coralReadAH2(filename);
% read data from an ah file into the coral format
% USAGE: D=coralReadAH2(filename);

% written by Ken Creager   11-23-2004

% first read data into a different structure using a robust CMEX code
[h,D]=ah2struct(filename);
% then rename and modify the fields

D=D';
N=length(D);
for k=1:N;  % loop over seismograms
  D(k).data             = D(k).data';          % transpose data vector
  D(k).recStartTime     = D(k).recStartTime';  % transpose start time vector
  D(k).recComment       = D(k).recComments;    % rename recComment
  D(k).recSampInt       = D(k).recSinter;      % rename recSinter
  D(k).staCode          = h(k).staCode;
  D(k).staChannel       = h(k).staChannel;
  D(k).staType          = h(k).staType;        
  
  % decode network name, location code and quality code from staType if possible
  tmp1={'' '' ''};
  tmp = D(k).staType;
	ind=findstr(tmp ,'.');
  lenind=length(ind);
  if lenind>0; ind=[0 ind length(tmp)+1];
    for l=1:lenind+1;
      tmp1{l}=tmp(ind(l)+1:ind(l+1)-1);
    end;
  end;
  tmp1=deblank(tmp1);
  D(k).staNetworkCode   = tmp1{1};
  D(k).staLocationCode  = tmp1{2};
  D(k).staQualityCode   = tmp1{3};

  D(k).staLat           = h(k).staLat;
  D(k).staLon           = h(k).staLon;
  D(k).staElev          = h(k).staElev;
  
  D(k).staGain          = h(k).staGain;
  D(k).staNormalization = h(k).staNormalization;
  npoles                = h(k).staPoles(1);             % modify format of poles and zeros
  poles_tmp             = h(k).staPoles(2:npoles+1);
  D(k).staPoles         = poles_tmp(:);
  nzeros                = h(k).staZeros(1);
  zeros_tmp             = h(k).staZeros(2:nzeros+1);
  D(k).staZeros         = zeros_tmp(:);
  D(k).staRespType      = 'PZ';                         %New field
  
  D(k).eqLat            = h(k).eqLat;
  D(k).eqLon            = h(k).eqLon;
  D(k).eqDepth          = h(k).eqDepth;
  D(k).eqOriginTime     = h(k).eqOriginTime';          % transpose origin time vector
  D(k).eqComment        = h(k).eqComments;             % rename field
  D(k).extras           = h(k).extras';
  
  D(k).recNumData       = length(D(k).data);          % New field
  D(k).recMaxAmp        = max(abs(D(k).data));        % New field
  
end
D=rmfield(D,{'recComments','recSinter'});             % remove old fields that have been renamed
