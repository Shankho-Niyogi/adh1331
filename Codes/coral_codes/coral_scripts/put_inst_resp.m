% M file written for coral to put a generic broad band instrument
% response in for stations with missing response information.  A
% star is added to the station name to designate that the instrument response
% may be incorrect.  Of course the gain will be way off because a digital sensitivity 
% of 1 is used.
% Creager 10/8/93

m_data=length(Data(1,:));
keep_key=find(Calib(2,:)~=0);
if length(keep_key)~=m_data
  rm_key=find(Calib(2,:)==0);
  Generic_resp=get_inst_resp('b');
  for i=1:length(rm_key)
    ii=rm_key(i);
    Calib(:,ii)=Generic_resp;
    sta_temp=setstr(Station(1:6,ii)')
    sta_temp=deblank(sta_temp);
    sta_temp=[sta_temp '*'];
    Station(1:length(sta_temp),ii)=abs(sta_temp)';
    disp([Label(1:4,ii)' ' response replaced by Generic response']);
  end
  [Delta, Azim, Bakazim, Sintr, Tstart, Label, Header, Obs] = ...
  update_data(Data, Extras, Record, Comment, Calib, Loc, Station, label_key);
  clear data1 header1 label1 obs1 data2 header2 label2 obs2 data3 header3 label3 obs3
 Syn=[];
end

