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
OUTPUT=setstr(Station([2:6 13:14 7:10],WIN_INDEX)');
OUTPUT0=cut_string(sprintf('%3d \n',1:length(WIN_INDEX)),10);
AMAT=[Loc([1,2,4,5,6],WIN_INDEX) ; Delta(WIN_INDEX) ; Azim(WIN_INDEX); HEADER([1,2,6],:)];
OUTPUT1=cut_string(sprintf(' %7.2f%8.2f  %7.2f%8.2f%4.0f %7.2f%7.2f%9.2f%9.1f%8.3f  \n',AMAT),10);
disp('indx sta net chn st_lat  st_lon   ev_lat  ev_lon ev_dep delta  azim travel_t duration   sintr')
disp([OUTPUT0 OUTPUT OUTPUT1]);

if exist('keep_sta_info')==1,
  if strcmp(upper(keep_sta_info),'T');
    keep_sta_info
        Pick.StaName   =[];
        Pick.NetName   =[];
        Pick.ChanName  =[];
        Pick.PhaseName =[];
        Pick.DataSource=[];
        Pick.EqName    =[];
        Pick.Picker    =[];
        Pick.PickMethod=[];

        PHASES=deblank(phases);
        STR=datestr(datenum(date),2); 
        Pickdate = str2num(STR(7:8))*10000 + str2num(STR(1:2))*100 + str2num(STR(4:5));
        [temp,WHOAMI]=unix('whoami');
        WHOAMI=WHOAMI(1:end-1);
        if exist('fn'); % create event name 
          FN=fn;
        else
          temp=time_reformat(Loc(7:8,1)); 
          temp=sprintf('%4d%2d%2d_%2d%2d',temp(1:5)); 
          tmpi=findstr(' ',temp);   
          if length(tmpi)>0; temp(tmpi)='0'; end
          FN=temp;
        end
        for i=1:length(WIN_INDEX);
          Pick.StaName{i,1}  = deblank(setstr(Station([2:6],WIN_INDEX(i))'));
          Pick.NetName{i,1}  = deblank(setstr(Station([13:20],WIN_INDEX(i))'));
          Pick.ChanName{i,1} = deblank(setstr(Station([8:12],WIN_INDEX(i))'));
          Pick.PhaseName{i,1}= PHASES;
          Pick.DataSource{i,1}= 'FARM';
          Pick.EqName{i,1}    = FN;
          Pick.Picker{i,1}    = WHOAMI;
          Pick.PickMethod{i,1}= PickMethod;
        end
        Pick.EqLat    = Loc(4,WIN_INDEX)';
        Pick.EqLon    = Loc(5,WIN_INDEX)';
        Pick.EqDepth  = Loc(6,WIN_INDEX)';
        Pick.EqDate   = Loc(7,WIN_INDEX)';
        Pick.EqTime   = Loc(8,WIN_INDEX)';
        if length(FF)==length(WIN_INDEX);
          Pick.EqRadiation=FF';
        else
          Pick.EqRadiation=NaN+zeros(length(WIN_INDEX),1);
        end
        Pick.RecDate  = Record(1,WIN_INDEX)';
        Pick.RecTime  = Record(2,WIN_INDEX)';
        Pick.StaLat   = Loc(1,WIN_INDEX)';
        Pick.StaLon   = Loc(2,WIN_INDEX)';
        Pick.EqStaDist= Delta(WIN_INDEX)'; 
        Pick.EqStaAzim= Azim(WIN_INDEX)'; 
        Pick.PickDate = Pickdate + zeros(length(WIN_INDEX),1);   
  end
end
%clear HEADER WIN_INDEX OUTPUT OUTPUT1 AMAT




