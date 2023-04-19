if exist('view_no')~=1,
  view_no=1;
end
if view_no>=1 & view_no<=3,
  eval(['HEADER=header' num2str(view_no) ';']);
elseif view_no==0,
  eval('HEADER=Header;');
else
  disp('retry: view_no must be 0, 1, or 2');
  return
end

WIN_INDEX=HEADER(5,:);
OUTPUT=setstr(Station(1:10,WIN_INDEX)');
AMAT=[Loc([1,2,4,5,6],WIN_INDEX) ; Delta(WIN_INDEX) ; Azim(WIN_INDEX); HEADER([1,2,6],:)];
OUTPUT1=cut_string(sprintf('  %.2f  %.2f  %.2f  %.2f  %.2f  %.2f  %.2f  %.2f  %.2f  %.2f  \n',AMAT),10);
disp(' sta  chan st_lat  st_lon  ev_lat  ev_lon ev_dep  delta   azim  travel_t duration  sintr')
disp([OUTPUT OUTPUT1]);
if exist('keep_sta_info')==1,
  if strcmp(upper(keep_sta_info),'T');
    keep_sta_info
        MY_DB.StaName=[];
        for i=1:length(WIN_INDEX);
          MY_DB.StaName{i,1}=setstr(Station([2:5],WIN_INDEX(i))');
        end
        MY_DB.EqLat    = Loc(4,WIN_INDEX)';
        MY_DB.EqLon    = Loc(5,WIN_INDEX)';
        MY_DB.EqDepth  = Loc(6,WIN_INDEX)';
        MY_DB.EqDate   = Loc(7,WIN_INDEX)';
        MY_DB.EqTime   = Loc(8,WIN_INDEX)';
        MY_DB.RecDate  = Record(1,WIN_INDEX)';
        MY_DB.RecTime  = Record(2,WIN_INDEX)';
        MY_DB.StaLat   = Loc(1,WIN_INDEX)';
        MY_DB.StaLon   = Loc(2,WIN_INDEX)';
        MY_DB.EqStaDist= Delta(WIN_INDEX)'; 
        MY_DB.EqStaAzim= Azim(WIN_INDEX)'; 
  end
end
%clear HEADER WIN_INDEX OUTPUT OUTPUT1 AMAT




