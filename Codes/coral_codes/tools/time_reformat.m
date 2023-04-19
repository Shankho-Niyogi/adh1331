function DT=time_reformat(DT);
%   time_reformat reformat time array
% USAGE: DT=time_reformat(DT);
%
% Function to change format of time matrix
%
% Input parameters:
%      DT = (6xN) or (2xN) array of date/times in the format illustrated below.
%           If six rows they contain year, month, day, hour, minute, sec
%           If two rows they contain (year,month,day) (hour,minute,sec)
%
% Output parameter:
%      DT = (6xN) or (2xN) array of date/times in the format that is different from 
%           the format used for input.
%     
%   Format of DT:
%
%   DT  =  [ YEAR1    YEAR2    ...  YEARN   |
%          | MONTH1   MONTH2   ...  MONTHN  |
%          | DAY1     DAY2     ...  DAYN    |
%          | HOUR1    HOUR2    ...  HOURN   |
%          | MINUTE1  MINUTE2  ...  MINUTEN |
%          | SECOND1  SECOND2  ...  SECONDN ]
%
%   or 
%
%   DT  =  [ DATE1    DATE2    ...  DATEN   | 
%          | TIME1    TIME2    ...  TIMEN   ]
%
%   where DATE=YYYY.MMDD; TIME = HHMMSS.SSSSSS;
%   eg. 1990.0321, 140623.0245  =  3/21/1990 14:06:23.0245
%
 
%
% K. Creager    9/10/92
%

[m,n]=size(DT);
if m==2,
  % date/time are entered in compressed format, convert to 6 vectors
  temp  =DT(1,:)+4000*eps;
  year  =floor(temp); temp=(temp-year)*100;
  month =floor(temp); temp=(temp-month)*100;
  day   =round(temp);
  temp  =DT(2,:)/10000+200*eps;
  hour  =floor(temp); temp=(temp-hour)*100;
  minute=floor(temp); 
  sec   =(temp-minute)*100;
% now stuff this back into DT in long format
  DT=zeros(6,n);
  DT(1,:)=year; DT(2,:)=month;  DT(3,:)=day;
  DT(4,:)=hour; DT(5,:)=minute; DT(6,:)=sec;
else
  % date/time are entered in long format, convert to compressed format
  year=DT(1,:); month =DT(2,:); day=DT(3,:);      % convert date/time array to 6 vectors
  hour=DT(4,:); minute=DT(5,:); sec=DT(6,:);
  DT=zeros(2,n);
  DT(1,:)=year+month/100+day/10000;               % stuff into compressed format
  DT(2,:)=hour*10000+minute*100+sec;
end
