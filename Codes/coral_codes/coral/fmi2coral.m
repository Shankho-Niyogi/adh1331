function [Station,Loc,Calib,Comment,Record,Extras,Data] = fmi2coral(seismogram,seisAttr,seisChanInfo,eventOrigin);
% convert objects from FMI to coral format
% USAGE: [Station,Loc,Calib,Comment,Record,Extras,Data] = fmi2coral(seismogram,seisAttr,seisChanInfo,eventOrigin);

nseis=length(seismogram);
ndata=zeros(nseis,1);

for k=1:nseis
  ndata(k)=length(seismogram{k});
end
Data = zeros(max(ndata),nseis);
for k=1:nseis
  Data(1:ndata(k),k) = seismogram{k};
end

Station = char(zeros(20,nseis)+32)';
Loc=zeros(8,nseis);
Calib=complex(zeros(62,nseis));
Comment=zeros(362,nseis);
Record=zeros(6,nseis);
Extras=zeros(21,nseis);

for k=1:nseis
  tmp=seisAttr(k).station;
  Station(k,1+[1:length(tmp)])=tmp;
  tmp=sprintf('%s  %s.%s.%s',seisAttr(k).channel, ...
  seisAttr(k).network,deblank(seisAttr(k).site),seisAttr(k).qualityFlag);
  Station(k,7+[1:length(tmp)])=tmp;
  
  Loc(1,k) = seisChanInfo(k).location.latitude;
  Loc(2,k) = seisChanInfo(k).location.longitude;
  Loc(3,k) = seisChanInfo(k).location.elevation;
  if any(strcmp('location',fields(eventOrigin))) 
    Loc(4,k) = eventOrigin.location.latitude;
    Loc(5,k) = eventOrigin.location.longitude;
    Loc(6,k) = eventOrigin.location.depth;
  else
    Loc(4,k) = eventOrigin.latitude;
    Loc(5,k) = eventOrigin.longitude;
    Loc(6,k) = eventOrigin.depth;
  end
  if any(strcmp('originTime',fields(eventOrigin))) 
    Loc(7:8,k) = time_reformat( str2time(eventOrigin.originTime)' );
  else
    Loc(7:8,k) = time_reformat( str2time(eventOrigin.time)' );
  end
  
  Record(1:2,k) = time_reformat( str2time(seisAttr(k).beginTime)' ); % Seismogram start time
  Record(3,k)   = ndata(k);
  if     strcmp(seisAttr(k).sampleIntvUnit , 'milliSECOND');   scal=.001;
  elseif strcmp(seisAttr(k).sampleIntvUnit , 'SECOND');    scal=1;
  else;  scal=0;
  end
  Record(4,k)   = seisAttr(k).sampleIntv * scal;
  Record(5,k)   = max(abs(seismogram{k}));
  
end
Station = abs(Station)';



