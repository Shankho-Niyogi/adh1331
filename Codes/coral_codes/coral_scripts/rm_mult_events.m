% check origin time of earthquakes in DATA0, determine the earliest
% earthquake, find indices for all seismograms corresponding to all
% later earthquakes, and remove data from DATA0 for later events.

TDIFF=timediff([Loc([7,8],1),Loc([7,8],:)]); % find origin time diff wrt first record
TDIFF=TDIFF(2:end);
TDIFF=TDIFF-min(TDIFF);
keep_key=find(TDIFF<.1);
if length(keep_key)<size(Loc,2),
  [Data, Extras, Record, Comment, Calib, Loc, Station] = ...
  sort_ah(Data, Extras, Record, Comment, Calib, Loc, Station, keep_key);
  [Delta, Azim, Bakazim, Sintr, Tstart, Label, Header, Obs] = ...
  update_data(Data, Extras, Record, Comment, Calib, Loc, Station, label_key);
  clear data1 header1 label1 obs1 data2 header2 label2 obs2 data3 header3 label3 obs3
  Syn=[];
end
