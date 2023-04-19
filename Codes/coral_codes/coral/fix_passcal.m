function  [Station,Loc,Calib,Comment,Record,Data] = ...
          fix_passcal(Station,Loc,Calib,Comment,Record,Data);
%   fix_passcal   fill in headers if not complete
% Usage:  [Station,Loc,Calib,Comment,Record,Data] = ...
%          fix_passcal(Station,Loc,Calib,Comment,Record,Data);
%
% fill in headers of PASSCAL station for DASSL experiment
%

% add dassl_path to the path name if it is not already there
%dassl_path='/home/kiev/kcc/matlab/dassl';
dassl_path='/u1/pullen/matlab/dassl';
P=path;
if length( findstr(dassl_path,P) ) == 0
  path(P,dassl_path);
  P=path;
end
if length( findstr(dassl_path,P) ) == 0
  error('Station header information is missing, fill in AH headers and try again')
end

station_file=[dassl_path '/station_loc'];
eval(' [sta_names,lat,lon,sta_number,das_number,corr]=read_station_loc(station_file);' )
s=setstr(Station');
N=size(s,1);

for i=1:N;               % loop over all stations 
% get station name
  if s(i,3)=='.'
    s(i,3)=' ';            
    s(i,1:6)=upper(s(i,1:6));  % convert station name to upper case
    sta=[s(i,4:6) ' '];
    j=strcmp2(sta,sta_names); 
    if j==0, j=[]; end
  else
    x=sscanf (s(i,1:6),'%d');
    j=find(das_number==x);
    if length(j)==1,
      s(i,3:6)=sta_names(j,:);
    end
  end
% get location
  if length(j)==1,
    Loc(1:2,i)=[lat(j);lon(j)];
  end
% get orientation
  if     s(i,12)=='1'
    orientation='Z';
  elseif s(i,12)=='2'
    orientation='N';
  elseif s(i,12)=='3'
    orientation='E';
  elseif s(i,12)=='t';
    orientation='T';
  elseif s(i,12)=='r';
    orientation='R';
  else
    orientation='?';
  end
% get band
  if abs(Record(4,i)-.05)<.01,
    band='B';
  elseif (Record(4,i)-.02)<.005,
    band='B';
  elseif (Record(4,i)-.10)<.005,
    band='B';
  elseif (Record(4,i)-1)<.1,
    band='L';
  else
    band='?';
  end
  chan=[band 'H' orientation '  '];
% update channel
  s(i,8:12)=chan;

% fix gain for TTW, SEAL, and SEAW
% if station is TTW multiply data by 5.6
% if station is SEAW multiply Z by 5.6 and
% multiply horizontals by 5.6 if before 3/7/94 and
% divide by 5.6 after that time
% if station is SEAL change polarity and divide by 32
% this is clearly needed on 3/31, as other data are 
% analyzed the appropriate dates should be set
  new_gain=0;
  if strcmp(s(i,3:6),'SEAL')
    if Record(1,i)==1994.0331
      new_gain=-1/32;
    end
  end
  if strcmp(s(i,3:6),'SEAW')
    if orientation=='Z',                        % vertical channel
      new_gain=5.6;
    elseif length(findstr('NERT',orientation)), % horizontal channel
      if Record(1,i)>1994.0307 & Record(1,i)<=1994.0330, % gain changed on 3/7/94 and then back sometime in march
        new_gain=1/5.6;
      else
        new_gain=5.6;
      end
    end
  end
  if strcmp(s(i,4:6),'TTW')
    new_gain=5.6;
  end
  if new_gain~=0;
    Data(:,i)=Data(:,i)*new_gain;
  end

end
setstr(s)
Station=abs(s');
