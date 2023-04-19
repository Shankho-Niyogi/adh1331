function [seis,nt,dt,id,t0,hdr,chdr,tref,ray_stuff] = ...
                           sac2mat(filename,icut,twind,ismelt)
%function [seis,nt,dt,id,t0,hdr,chdr,tref,ray_stuff] = ...
%                          sac2mat(filename,icut,twind,ismelt)
%                                             *    *      *    Optional
%Reads a MELT SAC seismogram from file FILENAME into Matlab.
%If input arguements ICUT and TWIND are specified, data is returned
%for a window from times from TWIND(1) to TWIND(2) where the window
%times are specified w.r.t. to a time determined by  ICUT
%If ICUT is a scalar then it is the index of a SAC header time
%(6-9, 11-21) or it is 0 which returns the full file
%If ICUT is a vector it is interpreted as the integer values for
%ASCII name of IASPEI phase (e.g., abs('P ')
%If TWIND(1)=TWIND(2) and they are positive then the 1st TWIND(1) secs
%of data are returned
%If TWIND(1)=TWIND(2) and they are negative then the last -TWIND(1) secs
%of data are returned
%ISMELT is a logical to identify MELT data so headers can be fixed
%
%SEIS - Seismogram
%NT   - Number of samples
%DT   - Sample interval
%ID   - Instrument ID
%T0   - Time of 1st sample (Unix time)
%HDR  - 110 element vector of real, int, and logical parts of SAC header
%CHDR  - 192 character string of character part of SAC header
%TREF  - Reference Unix time of file (Time in SAC header)
%RAY_STUFF  -  If windowing is based on an IASPEI phase then this is
%              [traveltime p d(delta)/dp d(time)/d(depth)]'
%              Otherwise this is set to [0 0 0 0]'
%
% Files are opened as big-endian (i.e., Written on a Sun not a Dec-Alpha)
% Files are opened as little-endian (i.e., Written on Linux)

if nargin==0; error('Must specify SAC filename'); end;
if isstr(filename)==0; error('SAC filename must be a string'); end;
if nargin<3; icut=0;  end;
if nargin<4; ismelt=0;end;
seis=[];


% First try reading sac file assuming it is in big endian format (e.g. Sun or Mac)
% Read the header, if the start year of the data makes sense go on, otherwise assume the
% data are little endian (linux) and try again.
computerformat = 'ieee-be';   
correctformat  = 0;
while correctformat == 0
  fid=fopen(filename,'r',computerformat); 
  if fid<=0; disp('SAC2MAT - Sac file failed to open'); return; end
  [hdr,count]=fread(fid,70,'float32');
  if count~=70;
    disp('SAC2MAT - Sac header read failed'); fclose(fid);  return;
  end
  [ihdr,count]=fread(fid,40,'long');
  if count~=40;
    disp('SAC2MAT - Sac header read failed'); fclose(fid); return;
  end
  if (ihdr(1)<0 | ihdr(1)>2100) & ihdr(1)~=-12345  % this is the year, if outside this range, try other machine format.
    fclose(fid);
    if strcmp(computerformat,'ieee-le');
      disp('SAC2MAT - Sac header read failed, data year outside range 0 to 2100'); return;
    end
    computerformat = 'ieee-le'; 
  else
    correctformat  = 1;
  end
end

[khdr,count]=fread(fid,192,'char');
if count~=192;
   disp('SAC2MAT - Sac header read failed'); fclose(fid); return;
end
hdr=[hdr' ihdr']; chdr=setstr(khdr)';
dt=hdr(1); 
nt=ihdr(10);
%  tref is the reference time given in ihdr(1:6) [Year, JulianDay, Hour, Minute, Second, Millisecond] minus [1970,1,1,0,0,0] in seconds
%  if any of ihdr(1:6) equal the default value (-12345) then set tref to 0
if any(ihdr(1:6)==-12345);  % ihdr(1:6) specify a reference time
  tref=0;
else
  tref = timediff([ihdr(1);1;ihdr(2);ihdr(3);ihdr(4);ihdr(5)+ihdr(6)/1000] , [1970;1;1;0;0;0] ); %use coral time code
end
% tref=date2secnds(ihdr(1),ihdr(2),ihdr(3),ihdr(4),ihdr(5)+ihdr(6)/1000);  % sac2mat code
t0=tref+hdr(6);
if ismelt
   [hdr,chdr]=meltfixsac(filename,hdr,chdr,tref);
end

%Select data window
ray_stuff=[0 0 0 0]';
if length(icut)==0
   tcut=0
elseif length(icut)==1
   if icut(1)~=0
     if hdr(icut(1))==-12345.00
       disp(['Cannot cut on SAC header value ' int2str(icut(1)) 'It is not set']);
       disp('Full file will be returned')
       tcut=0;
     else
       tcut=tref+hdr(icut(1));
     end
   else
     tcut=0;
   end
else
   if icut(1)~=0
     phase=deblank(setstr(icut));
     delta=delaz(hdr(36),hdr(37),hdr(32),hdr(33),0);
     depth=(hdr(39)-hdr(38))/1000;
     if depth>800; depth=depth/800; end;
%Ken Creager's modified version - Includes individual branches
     if length(phase)==3;
       if abs(phase)==abs('PKP')
         phase='PKPab';
       end
     end
     [tcut,p,dddp,dtdh]=get_ttt(phase,depth,delta);
     if ~length(tcut); tcut=Inf; end;
     if all(tcut==Inf)
       disp(['SAC2MAT: Call to get_ttt for phase ', phase , ' failed']);
       disp(['Phase name must be invalid or inappropriate for DELTA = ', int2str(delta)])
       disp('Full file will be returned')
       tcut=0;
     else
       [tcut,i]=min(tcut);
       ray_stuff=[tcut p(i) dddp(i) dtdh(i)]';
       tcut=tref+hdr(8)+tcut;
     end
   else
     tcut=0;
  end
end

if tcut
   if twind(1)==twind(2)
     if twind(1)>0
       n1=1; n2=round(twind(1)/dt);
     elseif twind(1)<0
       n2=nt; n1=nt-round(twind(1)/dt)+1;
     end
   else
     tstart=twind(1)+tcut; n1=ceil((tstart-t0)/dt)+1;
     tdiff=twind(2)-twind(1); n2=n1+round((tdiff)/dt)-1;
   end
   if n1>nt
     disp('        SAC2MAT - Cut window starts after last sample')
     disp('        Full file will be returned')
     n1=1; n2=nt;
   elseif n2<1
     disp('        SAC2MAT - Cut window ends before first sample')
     disp('        Full file will be returned')
     n1=1; n2=nt;
   elseif n1<1;
     disp('        SAC2MAT - Cut window starts before first sample')
     disp('        Only some of data requested will be returned')
     n1=1;
   elseif n2>nt;
     disp('        SAC2MAT - Cut window end after last sample')
     disp('        Only some of data requested will be returned')
     n2=nt;
   end
else
   n1=1; n2=nt;
end

%Read Seismogram
if n1>1; fseek(fid,(n1-1)*4,0); end
nt=n2-n1+1;
[seis,n]=fread(fid,nt,'float32');
if n~=nt;
   ('SAC2MAT - Sac data read failed')
   seis=[]; fclose(fid); return;
end;
fclose(fid);

hdr(6)=hdr(6)+(n1-1)*dt;
t0=t0+(n1-1)*dt;
id=chdr(1:8)'; id=sscanf(id(2:3),'%i');
