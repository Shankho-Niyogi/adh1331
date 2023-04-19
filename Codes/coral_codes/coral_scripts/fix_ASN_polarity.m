% script to read the file of polarity reversals of the Alaska Seismic Network
% and flip data in the D0 buffer of Coral
% run this right after reading in data.  Do not run it twice!!
% modified 11-21-01 KCC for new file format to fix Y2K

DATE=Loc(7,1);                             % get the date of the event
if DATE < 100; DATE=DATE+1900; end
DATE=round(DATE*10000);
STA_FLIP=find_flipped(DATE);               % get list of flipped stations for that day
OUTPUT=left_justify(setstr(Station(1:4,:)')); % get list of stations with data
INDEX=find(strcmp2(upper(OUTPUT),upper(STA_FLIP)));       % find indices of stations with data
if length(INDEX)>0,                         % that are flipped and flip them in Data
  Data= flip_trace(Data, INDEX);            % flip data
  Header(7,INDEX)=-Header(7,INDEX);         % fix header
  if exist('Label')>0,                      % fix labels
    for III=1:length(INDEX)
      if Header(7,INDEX(III))>0,
        Label(29,INDEX(III))='+'; 
      else
        Label(29,INDEX(III))='-'; 
      end
     end
   end
end
