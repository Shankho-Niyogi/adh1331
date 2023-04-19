%input parameters:
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
%  R            =  radiation pattern
%  M0           =  moment
%  B            =  geometric spreading factor

phase_name=label1(17:28,:);            % phase names
p    = header1(10,:)*180/pi;           % ray parameter (s/rad)
dpdd = header1(11,:);                  % dray_parameter/ddelta (s/rad^2)
dtdh = header1(12,:);                  %dT/ddepth (km/s)
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
  rec_type(index)=upper(temp(3,:)); 
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

gammaT=zeros(size(p));gammaR=gammaT;gammaZ=gammaT;
index=find(rec_type=='P');
if length(index)>0, 
  gammaT(index)=zeros(size(index));
  gammaR(index)=sin(take_off_rec(index));
  gammaZ(index)=cos(take_off_rec(index));
end                
index=find(rec_type=='S');
if length(index)>0, 
  gammaT(index)=ones(size(index));
  gammaR(index)=cos(take_off_rec(index));
  gammaZ(index)=sin(take_off_rec(index));
end                

%if rec_type=='S';  
%  gammaT=1;   gammaR=cos(take_off_rec);  gammaZ=sin(take_off_rec);
%else 
%  gammaT=0;   gammaR=sin(take_off_rec);  gammaZ=cos(take_off_rec);
%end
mtemp=M(12:2:23);                       % moment tensor in spherical coordinates
mtemp1=[ mtemp(2) -mtemp(6)  mtemp(4)   % moment tensor in cartesian coordinates
        -mtemp(6)  mtemp(3) -mtemp(5)
         mtemp(4) -mtemp(5)  mtemp(1) ];
M0=sqrt(trace(mtemp1*mtemp1)/2);                          % scalar seismic moment
F=radpattern(M(12:2:23), take_off_src*180/pi, azim, 4);
Fcutoff=0.1; % do not let the radiation pattern take on values less than Fcutoff
ind=find(abs(F)<Fcutoff);
F(ind)=Fcutoff*sign(F(ind));


% multiply by 2 for surface effects
UZ=2e-22*M0*F(:,1)'.*gammaZ./R./temp;  % units are M S
UR=2e-22*M0*F(:,2)'.*gammaR./R./temp;
UT=2e-22*M0*F(:,3)'.*gammaT./R./temp;

phs_shift=zeros(size(p));
phase_nam=phase_name(1:8,:);                              
if component(1)=='Z' | component(1)=='R'
  %change phase by 180 degrees for pP and sS reflections
  idx=find( strcmp2(phase_nam(1:2,:)',['sS';'pP']) );
  if length(idx)>0, phs_shift(idx)=phs_shift(idx)+180; end

  % remove the p or s from the beginning of phase names
  idx=find(phase_nam(1,:)=='p' | phase_name(1,:)=='s');
  if length(idx)>0, phase_nam(:,idx)=[phase_nam(2:8,idx);blanks(length(p))]; end
 

  phs_90=['P''P''bc  ';'P''P''bc  ';'P''P''bc  ';'P''P''bc  ';... 
          'PKKSbc  ';'PKKSdf  ';'PKSab   ';'PP      ';'SKKSac  ';'SKPab   ';'SS      '];
  phs_180=['PKKPab  ';'PKSbc   ';'PKSdf   ';'SKPbc   ';'SKPdf   '];
  phs_270=['PKKPbc  ';'PKKPdf  ';'PKPab   ';'PS      ';'SKKPab  ';'SP      '];

  i90 =strcmp2(phase_nam',phs_90 )>0; 
  i180=strcmp2(phase_nam',phs_180)>0; 
  i270=strcmp2(phase_nam',phs_270)>0; 
  phs_shift=phs_shift + i90'*90 + i180'*180 + i270'*270;
  phs_shift=rem(phs_shift,360);
  phs_shift
  [data1,header1]=phase_shift_part(data1,header1,phs_shift);


%  phs_180=['SKPac   ';'SKPdf   ';'

%  idx=find(strcmp2(phase_name(1:2,:)','PP'));
%  if length(idx)>0, phase(idx)=phase(idx)+180+90; end

%  idx=find(strcmp2(phase_name(1:2,:)','SS'));
%  if length(idx)>0, phase(idx)=phase(idx)+180+90; end

%  idx=find(strcmp2(phase_name(1:2,:)','PS'));
%  if length(idx)>0, phase(idx)=phase(idx)+000+90; end

%  idx=find(strcmp2(phase_name(1:2,:)','SP'));
%  if length(idx)>0, phase(idx)=phase(idx)+000+90; end

%  idx=find(strcmp2(phase_name(1:3,:)','SKP'));
%  if length(idx)>0, phase(idx)=phase(idx)+180; end

%  idx=find(strcmp2(phase_name(1:3,:)','PKS'));
%  if length(idx)>0, phase(idx)=phase(idx)+180; end

%  idx=find(strcmp2(phase_name(1:4,:)','SKKS'));
%  if length(idx)>0, phase(idx)=phase(idx)+180+90; end

%  idx=find(strcmp2(phase_name(1:4,:)','PKKP'));
%  if length(idx)>0, phase(idx)=phase(idx)+180+90; end

%  idx=find(strcmp2(phase_name(1:5,:)','PKPab'));
%  if length(idx)>0, phase(idx)=phase(idx)+90; end

%  idx=find(strcmp2(phase_name(1:6,:)','PKKPab'));
%  if length(idx)>0, phase(idx)=phase(idx)+90; end

end

if     component(1)=='Z'; comp_key=1; UU=UZ; 
elseif component(1)=='R'; comp_key=2; UU=UR;
elseif component(1)=='T'; comp_key=3; UU=UT;
else                      comp_key=0;
end
FF=F(:,comp_key);
for i=1:length(UU);
  data1(:,i)=data1(:,i)/UU(i); 
  header1(7,i)=1/UU(i);
end
[data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1); % fix label
