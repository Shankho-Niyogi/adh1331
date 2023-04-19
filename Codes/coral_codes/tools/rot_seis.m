function   [Station,Loc,Calib,Comment,Record,Extras,Data]=...
   rot_seis(Station,Loc,Calib,Comment,Record,Extras,Data);
%   rot_seis      rotate seismic data
% USAGE:   [Station,Loc,Calib,Comment,Record,Extras,Data]=...
%  rot_seis(Station,Loc,Calib,Comment,Record,Extras,Data);
%
%  Rotate east and north components of a seismogram to radial and
%  transverse using the AH convention, (radial is towards event
%  and transverse is to right when viewed from the source.
%  the first two seismograms are rotated and replaced

% the first two channels must be the same station and the same
% band, one must be 'E' and the other 'N'
if ~strcmp(setstr(Station(1:9,1)'),setstr(Station(1:9,2)')) | ...
   ~(strcmp(setstr(Station(10,1:2)),'EN') | ...
     strcmp(setstr(Station(10,1:2)),'NE')) ,
  disp('ERROR in rot_seis:  cannot rotate these two channels:')
  disp(setstr(Station(:,1:2))');
  return
end

% force the order to be E then N.
if setstr(Station(10,1:2))=='NE' 
 [Data, Extras, Record, Comment, Calib, Loc, Station] = ...
 sort_ah(Data, Extras, Record, Comment, Calib, Loc, Station, [2,1]);
end 

% calculate backazimuth 
[Delta, Azim, Bakazim]=delaz(Loc(4,:),Loc(5,:),Loc(1,:),Loc(2,:),0);

% the second record is offset by 'offset' points
offset=round(timediff(Record(1:2,:))/Record(4,1));
offset=offset(2)

ds1=1;ds2=1;
nd1=Record(3,1);nd2=Record(3,2);
if offset>0,
  ds1=ds1+offset; nd1=nd1-offset;
  Record(1:2,1)=Record(1:2,2);
elseif offset<0,
  ds2=ds2-offset; nd2=nd2+offset;
  Record(1:2,2)=Record(1:2,1);
end
nd=min(nd1,nd2);
Record(3,1)=nd;Record(3,2)=nd;

e=Data(ds1:ds1-1+nd,1)/Calib(2,1);
n=Data(ds2:ds2-1+nd,2)/Calib(2,2);  

xi=Bakazim(1)*pi/180;
t=(+sin(xi)*n -cos(xi)*e)*Calib(2,1);
r=(+cos(xi)*n +sin(xi)*e)*Calib(2,2);
Record(5,1)=max(t);
Record(5,2)=max(r);
Data(:,1:2)=zeros(length(Data),2);
Data(1:nd,1)=t;
Data(1:nd,2)=r;
Station(10,1)=abs('T');
Station(10,2)=abs('R');

