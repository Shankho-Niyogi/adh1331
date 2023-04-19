function coralWriteAH(filename,D,HH,DD);
% write data from coral format to an an file
% USAGE: coralWriteAH(filename,D);

% written by Ken Creager   11-23-2004

% rename and modify the fields


D=D';
N=length(D);
keep_index = zeros(N,1);  % only keep records with at least one sample of data
for k=1:N;  % loop over seismograms
  D(k).data             = D(k).data';          % transpose data vector
  D(k).recStartTime     = D(k).recStartTime';  % transpose start time vector
  D(k).recComments      = D(k).recComment;     % rename recComment
  D(k).recSinter        = D(k).recSampInt;     % rename recSinter
  
  h(k).staCode          = D(k).staCode;
  h(k).staChannel       = D(k).staChannel;
  h(k).staType          = D(k).staType;        
  
  h(k).staNetworkCode   = D(k).staNetworkCode;
  h(k).staLocationCode  = D(k).staLocationCode;

  h(k).staLat           = D(k).staLat;
  h(k).staLon           = D(k).staLon;
  h(k).staElev          = D(k).staElev;
  
  h(k).staGain          = D(k).staGain;
  h(k).staNormalization = D(k).staNormalization;
  tmp                   = zeros(1,30) + complex(0,0);
  n                     = length(D(k).staPoles);
  tmp(1:n+1)            = [n , reshape(D(k).staPoles,1,n)];
  h(k).staPoles         = tmp;
  h(k).staPoles(30)     = complex(0,eps);
  tmp                   = zeros(1,30) + complex(0,0);
  n                     = length(D(k).staZeros);
  tmp(1:n+1)            = [n , reshape(D(k).staZeros,1,n)];
  h(k).staZeros         = tmp;
  h(k).staZeros(30)     = complex(0,eps);
  
  h(k).eqLat            = D(k).eqLat;
  h(k).eqLon            = D(k).eqLon;
  h(k).eqDepth          = D(k).eqDepth;
  h(k).eqOriginTime     = D(k).eqOriginTime';          % transpose origin time vector
  h(k).eqComments       = D(k).eqComment;             % rename field
  h(k).extras           = D(k).extras';  
  
  if length(D(k).data)>0; keep_index(k)=1; end
  
end

keep_index=find(keep_index);
D=D(keep_index); 
h=h(keep_index);

% remove these fields from D , checking first to see if they exist
rm_fields = {'staCode',
'staChannel',
'staType',
'staNetworkCode',
'staLocationCode',
'staQualityCode',
'staLat',
'staLon',
'staElev',
'staGain',
'staNormalization',
'staPoles',
'staZeros',
'staRespType',
'eqLat',
'eqLon',
'eqDepth',
'eqOriginTime',
'eqComment',
'extras',
'recNumData',
'recMaxAmp',
'recComment',
'recSampInt'}';

key_fields=zeros(1,length(rm_fields));
FLDS = fields(D);
for k=1:length(rm_fields); if any(strcmp(rm_fields{k},FLDS)), key_fields(k)=1;end;end
rm_fields = rm_fields(find(key_fields));

D=rmfield(D,rm_fields);             % remove old fields that have been renamed
% then write the data into a an ah file  using a CMEX code

struct2ah(h,D,filename);
