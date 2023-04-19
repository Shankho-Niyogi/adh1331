function [FF,R,phs_shift,gamma,UU,take_off_src,take_off_rec,src_type,rec_type,vsrc,vrec] ... 
         =ray_syn_fun(M,header1,Loc,Azim,Delta,Station,phase_name,Fcutoff);
%  phase_name
%  component
%  ray_parameter
%  dtdh
%  ev_depth
%  delta
%  azim
%  model_name 
%  Moment tensor
%
%output_parameters:
%  src_type  =  'P' or 'S' depending on whether the phase is an S or P leaving the source
%  take_off     =  take_off angle (deg) > 90 if going up 
%  vsrc      =  P or S velocity at source
%  FF           =  radiation pattern
%  M0           =  moment
%  R            =  geometric spreading factor
%
%  called by ray_syn
%
% K. Creager, 1995
%
% Note that this routine has several crude approximations and has not been 
% carefully checked.  It should be used as a guide to interpretation only.  
% The primary deficiencies are that the reflection/refraction coefficients 
% are not included and the correction for surface reflection at the receiver 
% is handled by multiplying by 2.
% 
% Note that this code is written to be general and work for many different phases.
% However, it is only checked carefully for each phase as it is analyzed for a special
% study.  As of 3/1/2000 there are known errors in the conventions for SV waves.
% Also, the variable labeled dpdd is consistently mislabeled here and throughout coral.
% It is really dddp.  This is an error in documentation of this parameter only. This 
% routine returns the correct geometric spreading factor.  This parameter
% is spread throughout coral, so it should be fixed in many places. (KCC 3/1/00)

%phase_name=label1(17:28,:);            % phase names
p    = header1(10,:)*180/pi;           % ray parameter (s/rad)
dpdd = header1(11,:);                  % dray_parameter/ddelta (s/rad^2)
dtdh = header1(12,:);                  % dT/ddepth (km/s)
index1=header1(5,:);                   % index to Data0
depth= Loc(6,index1);                  % event depth (km)
rad_src=6371-depth;                    % source radius (km)
rad_rec=6371*ones(size(rad_src));      % receiver radius (km)
delta=Delta(index1)*pi/180;            % epicentral distance (rad)
azim = Azim(index1);                   % eq-to-station azimuth (deg)
junk = left_justify(setstr(Station(7:12,index1))');
component=junk(:,3);                   % data orientation (Z,R,T)
up_down=sign(dtdh);                    % -1=ray leaving the source down, +1=up

[vp_src,vs_src,rho_src]=iasp91(rad_src);     % P and S velocity at source depths
[vp_rec,vs_rec,rho_rec]=iasp91(rad_rec);     % P and S velocity at receiver depths
src_type=upper(phase_name(1,:));             % P or S leaving source
temp=left_justify(fliplr(phase_name'))';     % P or S entering receiver
rec_type=upper(temp(1,:));
index=find(rec_type~='P' & rec_type~='S');   % if PKPdf,SKSac, use letter 3rd from end
if length(index)>0,
  rec_type(index)=upper(temp(3,index)); 
  index=find(rec_type=='''');                % if P'P'df, etc use letter 4th from end
  if length(index)>0, rec_type(index)=upper(temp(4,:)); end
end
vsrc=zeros(size(src_type));                  % vsrc is the P or S velocity at the source
vrec=zeros(size(rec_type));                  % vrec is the P or S velocity at the receiver
index=find(src_type=='P'); 
if length(index)>0, vsrc(index)=vp_src(index); end
index=find(src_type=='S');
if length(index)>0, vsrc(index)=vs_src(index); end
index=find(rec_type=='P'); 
if length(index)>0, vrec(index)=vp_rec(index); end
index=find(rec_type=='S');
if length(index)>0, vrec(index)=vs_rec(index); end

take_off_src = asin(p.*vsrc./rad_src);
index=find(up_down>0);
if length(index)>0, take_off_src(index)=pi-take_off_src(index); end
take_off_rec = asin(p.*vrec./rad_rec);
% R = geometric spreading factor (Aki and Richards problem 4.3)
R = rad_src.*rad_rec./vsrc .* sqrt(abs(cos(take_off_rec).*cos(take_off_src).*sin(delta).*dpdd./p));
temp=4*pi*sqrt(rho_src.*rho_rec.*vrec.*(vsrc.^5));

% gamma accounts for the angle between particle motion and the station component% Note that take_off_rec should always be in the range 0->pi/2 and that the
% ray approaching the receiver is defined such that the P-wave is positive
% up (away), SH is positive to the right (as viewed from the source), and radial
% is positive up (towards the source).  (See Figure 4.20 of Aki and Richards).
% As a result the radial needs to be reversed in sign as is done below.
gamma=zeros(size(p));
rp=rec_type=='P'; rs=rec_type=='S';
sp=src_type=='P'; ss=src_type=='S';
compZ=component=='Z'; compR=component=='R'; compT=component=='T';
idx=find(rp&compZ'); if length(idx)>0, gamma(idx)= cos(take_off_rec(idx)); end
idx=find(rp&compR'); if length(idx)>0, gamma(idx)=-sin(take_off_rec(idx)); end
idx=find(rp&compT'); if length(idx)>0, gamma(idx)= zeros(size(idx));       end
idx=find(rs&compZ'); if length(idx)>0, gamma(idx)= sin(take_off_rec(idx)); end
idx=find(rs&compR'); if length(idx)>0, gamma(idx)=-cos(take_off_rec(idx)); end
idx=find(rs&compT'); if length(idx)>0, gamma(idx)= ones(size(idx));        end


mtemp=M(12:2:23);                       % moment tensor in spherical coordinates
mtemp1=[ mtemp(2) -mtemp(6)  mtemp(4)   % moment tensor in cartesian coordinates
        -mtemp(6)  mtemp(3) -mtemp(5)
         mtemp(4) -mtemp(5)  mtemp(1) ];
M0=sqrt(trace(mtemp1*mtemp1)/2);                          % scalar seismic moment
F=radpattern(M(12:2:23), take_off_src*180/pi, azim, 4);
% do not let the radiation pattern take on values less than Fcutoff
ind=find(abs(F)<Fcutoff);
F(ind)=Fcutoff*sign(F(ind));
FF=zeros(size(p));
idx=find(sp);                  if length(idx)>0, FF(idx)=F(idx,1); end; % P -radiation
idx=find(ss & (compR|compZ)'); if length(idx)>0, FF(idx)=F(idx,2); end; % SV-radiation
idx=find(ss & compT');         if length(idx)>0, FF(idx)=F(idx,3); end; % SH-radiation

% multiply by 2 for reflection at receiver (not always a good approximation)
UU=2e-22*M0*FF.*gamma./R./temp;       % units are M S

% phs_shift gives the phase shift owing to reflection/transmission coefficients 
% and to touching caustics.  The amplitude effects of the coefficients are not
% included and the phase shifts are calculated for near vertical incidence only
phs_shift=zeros(size(p));
phase_nam=phase_name(1:7,:);                              
if component(1)=='T'
  % all reflections off the free surface and the CMB have unit reflection coefficients
  % only need to phase shipt SS by -90
  phs_270=['SS     ';'sSS    '];
  i270=strcmp2(phase_nam',phs_270)>0;
  phs_shift=phs_shift + i270'*270;

elseif component(1)=='Z' | component(1)=='R'
  %change phase by 180 degrees for pP, sS, sP, and pS reflections
  idx=find( strcmp2(phase_nam(1:2,:)',['sS';'pP';'sP';'pS']) );
  if length(idx)>0, phs_shift(idx)=phs_shift(idx)+180; end

%%%%%%%%%%%%%
%
% My adittion
%
%%%%%%%%%%%%%

  %change phase by [phase_angle_degrees] degrees for PKiKP
  idx=find( strcmp2(phase_nam(1:5,:)',['PKiKP']) );
  phase_angle_ares;
  if length(idx)>0, phs_shift(idx) = (-1)*(phase_angle_degrees(idx))'; %keyboard;
  
  clear ares_C; end

%%%%%%%%%%%%%

  % remove the p or s from the beginning of phase names
  idx=find(phase_nam(1,:)=='p' | phase_name(1,:)=='s');
  if length(idx)>0, phase_nam(:,idx)=[phase_nam(2:7,idx);blanks(length(idx))]; end
 
  phs_90=['P''P''bc ';'P''P''bc ';'P''P''bc ';'P''P''bc ';... 
          'PKKSbc ';'PKKSdf ';'PKSab  ';'PP     ';'SKKSac ';'SKPab  ';'SS     '];
  phs_180=['PKKPab ';'PKSbc  ';'PKSdf  ';'SKPbc  ';'SKPdf  '];
  phs_270=['PKKPbc ';'PKKPdf ';'PKPab  ';'PS     ';'SKKPab ';'SP     '];

  i90 =strcmp2(phase_nam',phs_90 )>0; 
  i180=strcmp2(phase_nam',phs_180)>0; 
  i270=strcmp2(phase_nam',phs_270)>0; 
  phs_shift=phs_shift + i90'*90 + i180'*180 + i270'*270;
  phs_shift=rem(phs_shift,360);
end
return
% return without actually modifying the data.  Correct for propagation effects
% by the following commands
[data1,header1]=phase_shift_part(data1,header1,phs_shift); % apply phase shift to data

for i=1:length(UU);
  data1(:,i)=data1(:,i)/UU(i); 
  header1(7,i)=1/UU(i);
end
[data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1); % fix label
