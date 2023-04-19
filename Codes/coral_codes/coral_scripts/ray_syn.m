phase_name=label1(17:23,:);
Fcutoff=.1;
[FF,R,phs_shift,gamma,UU,take_off_src,take_off_rec,src_type,rec_type,vsrc,vrec] ...
=ray_syn_fun(M,header1,Loc,Azim,Delta,Station,phase_name,Fcutoff);

% modify data unless CHANGE_DATA exists and equals 'F'
% if CHANGE_DATA == 'R' then flip data (reverse) and apply phase shifts, but
% do not change amplitude

UUU=UU;
MODIFY_DATA='T';
if exist('CHANGE_DATA')==1
 if strcmp(CHANGE_DATA,'F') 
   MODIFY_DATA='F';
 elseif strcmp(CHANGE_DATA,'R') 
   MODIFY_DATA='R';
   UUU=sign(UUU);
 end
end

if strcmp(MODIFY_DATA,'T') | strcmp(MODIFY_DATA,'R')
  [data1,header1]=phase_shift_part(data1,header1,phs_shift); % apply phase shift to data
  for i=1:length(UU);
    data1(:,i)=data1(:,i)/UUU(i);
    header1(7,i)=header1(7,i)/UUU(i);
  end
  [data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1); % fix label
end
CHANGE_DATA='T';
