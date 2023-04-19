function [ok,station,loc,calib,comment,record,extras,data,ray_stuff] = ...
                        sac2coral(filename,icut,twind,ismelt);
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
       disp(['SAC2CORAL - Invalid Cut Index ',int2str(icut)])
       disp('No cut window - Full file will be read')
     end
   end
end

if nargin<3
   twind=[0 0];
   if icut(1)~=0
     disp('SAC2CORAL - Cannot cut without a cut window')
     disp('Full file will be read')
     icut=0;
   end
else
   if length(twind)~=2
     disp('SAC2CORAL - Cut window must have two elements')
     disp('Full file will be read')
     icut=0;
   elseif  twind(1)>twind(2);
     disp('SAC2CORAL - Invalid cut window twind(1)>=twind(2)')
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

%Set values
station(2:6)=chdr(1:5);
station(8:12)=chdr(161:165);
if ~ismelt
   station(13:20)=chdr(185:192);
else
   site=str2num(chdr(2:3)); type=meltsiteowner(site);
   if type==1;
     station(13:20)='WHOI ONR';
   elseif type==2;
     station(13:20)='SIO ONR ';
   elseif type==3;
     station(13:20)='SIO Webb';
   elseif type==4;
     station(13:20)='SIO IGPP';
   else
     station(13:20)='Unknown ';
   end
end
station=station(:);

loc(1:2)=hdr(32:33); loc(3)=(hdr(34)-hdr(35))/1000;
loc(4:5)=hdr(36:37); loc(6)=(hdr(39)-hdr(38))/1000;
loc(7:8)=timeadd( [1970.0101;0.0] , tref+hdr(8) ); % coral code
%[loc(7),loc(8)]=secnds2coral(tref+hdr(8));  % same thing with sac2coral code
loc=loc(:);

if ~ismelt
   calib=1;
   % Your on your own here
else
   cchan=chdr(161:164);
   if abs(cchan)==abs('DPG '); chan=4; else; chan=1; end;
   [pole,zero,gain]=meltpolezero(site,chan);
   calib(1)=1; calib(2)=gain;
   calib(3)=length(pole); calib(4:calib(3)+3)=pole(:);
   calib(33)=length(zero); calib(34:calib(33)+33)=zero(:);
   calib=calib(:);
end

comment=char(zeros(1,362)+abs(' '));
comment(1:32)=chdr(1:32); comment(33:64)=chdr(161:192);
comment=comment(:);

record=zeros(6,1);
record(1:2)=timeadd( [1970.0101;0.0] , t0 ); % coral code
%[record(1),record(2)]=secnds2coral(t0);% same thing with sac2coral code
record(3)=nt; record(4)=hdr(1); record(5)=hdr(3); record(6)=0;
record=record(:);

extras=zeros(21,1);

ok=1;
