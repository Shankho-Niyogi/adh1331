function [header,data]=sac2struct(filename,icut,twind,ismelt);
%function [ok,station,loc,calib,comment,record,extras,data,ray_stuff] =  ...
%                      sac2coral(filename,icut,twind,ismelt);
%                                           *    *    *      Optional
%
%Loads a single SAC seismogram in file FILENAME into Ken Creager's Coral format
%Inputs
%FILENAME  Sac file name
%ICUT -    If a scalar or empty
%            Index of the SAC time to cut around (6-9, 11-21)
%            0 or [] returns the full file (irrespective of TWIND);
%          If a vector
%            Integer values for ASCII name of IASPEI phase
%TWIND -   Two elements define data window to return (seconds)
%          [0 0] or twind(1)>twind(2) returns all data
%          twind(1)=twind(2) returns first twind(1) seconds of data
%          if twind(1) is positive or last -twind(1) seconds if
%          twind(1) is negative
%ISMELT -  Identifies the data as from the MELT experiment so that the
%          correct instrument responses can be added to calib (SAC
%          files do not include the instrument response)
%
%Outputs
%OK        1 if file loads correctly
%STATION -> DATA   Coral data
%RAY_STUFF  -  If windowing is based on an IASPEI phase then this is
%              [traveltime p d(delta)/dp d(time)/d(depth)]'
%              Otherwise this is set to [0 0 0 0]'


%Check inputs
if nargin<2
   icut=0;
else
   if length(icut)==0
     icut=0;
   elseif length(icut)==1 & icut(1)~=0;
     if icut<6 | icut==10 | icut>21
       disp(['SAC2STRUCT - Invalid Cut Index ',int2str(icut)])
       disp('No cut window - Full file will be read')
     end
   end
end

if nargin<3
   twind=[0 0];
   if icut(1)~=0
     disp('SAC2STRUCT - Cannot cut without a cut window')
     disp('Full file will be read')
     icut=0;
   end
else
   if length(twind)~=2
     disp('SAC2STRUCT - Cut window must have two elements')
     disp('Full file will be read')
     icut=0;
   elseif  twind(1)>twind(2);
     disp('SAC2STRUCT - Invalid cut window twind(1)>=twind(2)')
     disp('Full file will be read')
     icut=0;
   end
end
if nargin<4; ismelt=0; end;

%Read data
[data,nt,dt,id,t0,hdr,chdr,tref,ray_stuff]=sac2mat(filename,icut,twind,ismelt);
if isempty(data)
   ok=0; return;
end


staType='';
staNetworkCode='';
staLocationCode='';
staQualityCode='';
staGain       =1;
staNormalization=1;
staPoles      =complex(zeros(30,1));
staZeros      =complex(zeros(30,1));
eqComment     ='';
extras = zeros(21,1);

%Set values

header.staCode           = deblank(chdr(1:6));
header.staChannel        = deblank(chdr(161:163));
header.staType           = staType;
header.staNetworkCode    = staNetworkCode;
header.staLocationCode   = staLocationCode;
header.staQualityCode    = staQualityCode;
header.staLat            = hdr(32);
header.staLon            = hdr(33);
header.staElev           = (hdr(34)-hdr(35));
header.staGain           = 0;
header.staNormalization  = 0;
header.staPoles          = staPoles;
header.staZeros          = staZeros;
header.eqLat             = hdr(36);
header.eqLon             = hdr(37);
header.eqDepth           = (hdr(39)-hdr(38))/1000; %(km)
header.eqOriginTime      = timeadd( [1970;1;1;0;0;0] , tref+hdr(8) );
header.eqComment         = eqComment;
header.numData           = nt;
header.extras            = extras;

data.data         = data;
data.recSampInt   = dt;
data.recMaxAmp    = max(abs(data.data));
data.recStartTime = timeadd([1970;1;1;0;0;0],t0);

data.recComment   = [chdr(1:32) chdr(161:192)];
% decode instrument dip and azimuth and units for instrument response if possible
% should look like: Comp azm=0.0,inc=-90.0; Disp (m);

azm=NaN;
inc=NaN;
data.recAzimuth = azm;
data.recDip     = inc;
data.recLog = 'Read from sac files';
ok=1;
