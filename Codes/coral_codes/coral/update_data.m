function [Delta,Azim,Bakazim,Srate,Tstart,Label,Header,Obs] = ...
         update_data(Data,Extras,Record,Comment,Calib,Loc,Station,label_key);
%   updata_data   initialize coral headers 
% USAGE: [Delta,Azim,Bakazim,Srate,Tstart,Label,Header,Obs] = ...
%        update_data(Data,Extras,Record,Comment,Calib,Loc,Station,label_key);
%  updates derived parameters using data read from AH file

% calculate epicentral distance, azimuth, and back azimuth from source/receiver locations
[Delta, Azim, Bakazim]=delaz(Loc(4,:),Loc(5,:),Loc(1,:),Loc(2,:),0);

% remove roundoff error from Srate assuming Srate is either an integer, or the 
% inverse of an integer. if the new srate differs from the old by more than a factor of
% 1e-6, then use the original value of srate.
Srate=Record(4,:);
ind0 = find(Record(4,:)<=1);
ind1 = find(Record(4,:)> 1);
if (~isempty(ind0)), Srate(ind0)=1 ./round(1 ./ Record(4,ind0)); end
if (~isempty(ind1)), Srate(ind1)=round(Record(4,ind1));         end
check = (abs((Srate - Record(4,:)) ./ Record(4,:)) > 10e-6); 
Srate = Record(4,:).*check  +  Srate.*(1-check);

% calculate the travel time (min) from origin time to the first sample
Tstart = timediff(Record(1:2,:), Loc(7:8,:));
%if max(abs(ml_deltime(Record(1:2,:), Loc(7:8,:))-Tstart))>.0001
%  disp('CHECK TIMEDIFF ROUTINE, THERE MAY BE AN ERROR. SEE update_data.m')
%  ml_deltime(Record(1:2,:), Loc(7:8,:))-Tstart
%end 

[n,m]=size(Data); % m = number of seismograms, n = number of samples per seismogram

Tdur = Srate*(n-1); % time duration
Index=(1:m);        % index to data headers

% T0 and T1 are the time relative to the record start time of the 
% first and last non-zero data points.  if the first (or last) point is zero, but
% the next point is non-zero, then set T0 and T1 to the first (last) point.
T0=zeros(1,m);T1=T0; % initialize T0,T1
for i=1:m
  temp=find(Data(:,i)~=0);
  if length(temp)==0; 
    disp(sprintf('ERROR: the %dth seismogram contains all zeros delete it and reread the data',i))
    return
  end
  T0(i)=min(temp);
  T1(i)=max(temp);
end
T0=T0 - (T0==2); 
T1=T1 + (T0==(n-1));
T0=Srate.*(T0-1);
T1=Srate.*(T1-1);

Magnification = ones(1,m);
Phase_shift   =zeros(1,m); 
Modeltime     =zeros(1,m);
Rayparm       =zeros(1,m);
Dddp          =zeros(1,m);
Dtdh          =zeros(1,m);
Header=[Tstart;Tdur;T0;T1;Index;Srate;Magnification;Phase_shift;Modeltime;Rayparm;Dddp;Dtdh];

% make label
% columns station(5), delta(4), azim(4), bakazim(4), phase(6), resid(5), flip(2)
%          1:4        5:8       9:12    13:16      17:22       23:28    29:30
Label=setstr(zeros(30,m)+abs(' '));
Label(1:4,:)=setstr(Station(2:5,:));
Label(29,:)=setstr(zeros(1,m)+abs('+'));
for i=1:m;
  temp=num2str(round(Delta(i)));
  Label(5:8,i)=[blanks(4-length(temp)) temp]';
  temp=num2str(round(Azim(i)));
  Label(9:12,i)=[blanks(4-length(temp)) temp]';
  temp=num2str(round(Bakazim(i)));
  Label(13:16,i)=[blanks(4-length(temp)) temp]';
end
Obs=zeros(8,m)+NaN;

if min(abs(Extras(7,:)))>0,
  % assume extras 7-20 contain header info and fix data accordingly
  Header(7:12,:)=Extras(7:12,:);
  Obs=Extras(13:20,:);
  for i=1:m;   Data(:,i)=Data(:,i)*Header(7,i);  end
  Label(17:30,:)=setstr(Comment(161:174,:));
end
