%    Coral version 2.1     5/31/97  - modified for MATLAB5
%   coral     MATLAB script to analyze seismogram record sections 
%   written by Ken Creager, Tom McSweeney, John Winchester, and John Castle
%   Geophysics Program 
%   Box 351650
%   University of Washington
%   Seattle, WA 98195-1650
%   kcc@geophys.washington.edu,      tjm@iris.washington.edu 
%   winch@geophys.washington.edu, or castle@iris.washington.edu 

global h_plot h_tt

%  initialize some parameters
if ~exist('n_phase'),         n_phase=1;                         end
if ~exist('phases'),          phases='P       ';                 end
if ~exist('wind_width'),      wind_width=[-120 600];             end
if ~exist('label_key'),       label_key=['station delta azim'];  end
if ~exist('plot_scale'),      plot_scale=[-.1 0.2 1.0 0.];       end
if ~exist('yaxis'),           yaxis='e';                         end
if ~exist('titl'),            titl=' ';                          end
if ~exist('titl_flag'),       titl_flag='a';                     end
if ~exist('tt_label'),        tt_label='off';                    end
if ~exist('orientation'),     orientation='tall';                end
if ~exist('s_fill'),          s_fill='';                         end
if ~exist('opt_save'),        opt_save=['coral' setstr(0)];      end
if ~exist('Syn_label'),       Syn_label='';                      end
if ~exist('window'),          window='';                         end
if ~exist('w_index'),         w_index='';                        end

disp('              Coral      Version 2.1      2/18/97')
disp(' Type ''help'' or ''help all'' for description of coral commands and organization')
disp(' Type ''eval help coral_scripts'' for a help on external scripts') 

format compact

handles=get(0,'Children');
exist_coral_fig=0;
for iii=1:length(handles);
  if strcmp(get(handles(iii),'Name'),'Coral'),
    h_main=handles(iii);
    exist_coral_fig=1;
    break
  end
end
if exist_coral_fig==0,  % open a new plot window
  h_main=figure('Position',[1 450 500 400],'NumberTitle','off','Name','Coral');
  orient(orientation);
end
figure(h_main);  % make this the current figure

opt='xxxx';  
STOP=0;
n_new_opt=0;
 
%  begin main loop of prompting for keyboard input

while STOP==0, 
 if n_new_opt==0,
   opt=input('Enter command: ', 's');
 else
   opt=new_opt(i_new_opt,:);
   disp(opt);
   if i_new_opt==n_new_opt; n_new_opt=0; end
   i_new_opt=i_new_opt+1;
 end
 if length(opt)<4, opt=[opt blanks(4-length(opt))]; end; % force opt to have a length >3
 if abs(opt(1:2))~=abs('m '),
   opt_save=[opt_save opt setstr(0)]; % save commands to write to a file after quitting
 end

 if abs(opt(1:4))==abs('stop')
   STOP=1;

 elseif abs(opt(1:4))==abs('exit')
   STOP=1;

 elseif abs(opt(1:4))==abs('help')
   % read in coral.man and print the whole thing, just the command names, or 
   % details of one command to the screen
   [smat,n_smat]=cut_string(opt);
   if n_smat>3,
     disp('help must have zero of one argument, try again');
   else
     if n_smat==1,  
       command_name=[];
     else 
       command_name=smat(2,:);
     end
     coral_help('/u0/iris/MATLAB/coral/coral.man',command_name);
   end

 elseif abs(opt(1:4))==abs('quak')
   % read in an earthquake catalog contained in an ASCII file containing
   % month day year hour minute second latitude longitude depth and magnitude.
   % on each line. each line must contain 10 numbers separated by spaces, no blank lines.
   % store event origin times in 'qtimes' and location/magnitude in 'qloc'
   [smat,n_smat]=cut_string(opt);
   if n_smat>3 | n_smat<2,
     disp('quak must have one or two arguments, filename [format]: try again'); 
   else
     filename=cut_string(smat(2,:));
     if exist(filename)==0
       disp(['the file: ' filename ' does not exist, try again']);
     else
       disp(['reading catalog from file ' filename]);
       if n_smat==3,
        if smat(3,1:3)=='cmt',
         MM=read_cmt(filename);
         qtimes=time_reformat(MM(:,1:6)');
         qloc=[MM(:,7:9)' ; max(MM(:,10:11)')];
        end
       else 
         eval(['load ' filename ' -ascii;']);      % filename exists so read it
         [temp,n_temp]=cut_string(filename,'/');   % strip directory name from filename  
         temp1=cut_string(temp(n_temp,:));         % then remove suffix after '.' to 
         temp=cut_string(temp1,'.');               % get variablename
         variablename=temp(1,:);
         eval(['temp1=' variablename '(:,[3,1,2,4,5,6])'';']);
         qtimes=time_reformat(temp1);
%        qtimes(1,:) = qtimes(1,:)+1900*(qtimes(1,:)<100);
         eval(['qloc  =' variablename '(:,[7:10])'';']);
         eval(['clear temp1 ' variablename]); 
       end
     end
   end

 elseif abs(opt(1:4))==abs('read')
   % read in an AH file
   [smat,n_smat]=cut_string(opt);
   if n_smat~=2,
     disp('read must have one argument, (AH file name) try again'); 
   else
     filename=cut_string(smat(2,:));
     file_read='t';
     if exist(filename)==0
       if exist([filename '.mat'])==0
         file_read='f';
         disp(['the file: ' filename ' does not exist, try again']);
       else
         disp(['reading data from file ' filename '.mat']);
         temp=['load ' filename ';']; eval(temp);  % filename.mat exists so read it
         Station=Station_out;Loc=Loc_out;Calib=Calib_out;Comment=Comment_out;
         Record=Record_out;Extras=Extras_out;Data=Data_out;
         clear Station_out Loc_out Calib_out Comment_out Record_out Extras_out Data_out
         clear Mag
       end
     else
       disp(['reading data from file ' filename]);
       [Station,Loc,Calib,Comment,Record,Extras,Data] = ah2ml(filename);
       CC=setstr(Comment); 
       CC(  1:80 ,:)=left_justify(CC(  1: 80,:)')';
       CC( 81:160,:)=left_justify(CC( 81:160,:)')';
       CC(161:362,:)=left_justify(CC(161:362,:)')';
       Comment=abs(CC);
       clear CC

%       if any(Loc(1,:)==0&Loc(2,:)==0),  % if any station lat and long both equal zero then
       if setstr(Station(14:20,1))'=='passcal',  % if any station lat and long both equal zero then

         [Station,Loc,Calib,Comment,Record,Data] = fix_passcal(Station,Loc,Calib,Comment,Record,Data);
       end
       % left justify Station name
       indx=2:6;  Station(indx,:) = abs(left_justify( setstr( Station(indx,:)' ) )' );
       %indx=7:12; Station(indx,:) = abs(left_justify( setstr( Station(indx,:)' ) )' );
       %indx=13:20;Station(indx,:) = abs(left_justify( setstr( Station(indx,:)' ) )' );
       %JCC  
       clear Mag
     end
     if file_read=='t'
       if (max(Loc(7,:))-min(Loc(7,:)) +  max(Loc(8,:))-min(Loc(8,:))) > 0,
         diff_event_time='t';  %event origin time for traces varies
       else
         diff_event_time='f';  %event origin time is the same for all traces
       end
       if (Loc(7,1)==0 | Loc(7,1)==1900) & Loc(8,1)==0,
         if exist('qtimes')==1,
           disp('no event origin time given in AH header')
           disp('event location chosen from catalog you entered')
           %  determine stime and etime which are the minimum and maximum times
           %  on any of the seismograms that were just read in
           stimes=Record(1:2,:);
           dif_stimes=timediff(stimes);
           ind=min(find(min(dif_stimes)==dif_stimes));
           stime=stimes(:,ind);
           etimes=timeadd(stimes,Record(3,:).*Record(4,:));
           dif_etimes=timediff(etimes);
           ind=min(find(max(dif_etimes)==dif_etimes)); 
           etime=etimes(:,ind);

           % choose event from catalog
           [index,index2]=pick_event(stime,etime,qtimes,-3600);  
           % if auto choice is ambiguous, ask from help from keyboard
           if length(index2)>1 | length(index)==0,
             plot_data_dist(stimes,etimes,qtimes,index2);
             [ev_time,ev_loc]=choose_event(qtimes,qloc,index2);  
           else
             ev_time=qtimes(:,index);
             ev_loc=qloc(:,index);
             disp([int2str(index) 'th event chosen from catalog'])
           end
           n_records=length(Loc(1,:));
           Loc(7:8,:)=vec2mat(ev_time,n_records);
           Loc(4:6,:)=vec2mat(ev_loc(1:3),n_records);
           Mag(1,:)=vec2mat(ev_loc(4),n_records);
         else
           disp('event location must be in AH header or read in from an event catalog')
           disp('using command ''quak''. data read unsuccessful--retry')
% JCC1
	   stimes=Record(1:2,:);
           dif_stimes=timediff(stimes);
           ind=min(find(min(dif_stimes)==dif_stimes));
           stime=stimes(:,ind);datetmp=stime(1,1)*10000; 
	   disp(' ')
	   disp('Using time of first record,')
	   disp('Date [YYYYMMDD] -->'), disp (datetmp);
	   format bank;
	   disp('Time [HHMMSS.SS] -->'),disp(stime(2,1));
	   format short;
	   disp('and location lat=0, lon=0, depth=0')
	   n_records=length(Loc(1,:));
           Loc(7:8,:)=vec2mat(stime,n_records);
           Loc(4:6,:)=vec2mat([0 0 0]',n_records);
           Mag(1,:)=vec2mat(20,n_records);
	   file_read='t'; 
	% file_read='f';
% JCC2
           
         end
       end
       if file_read=='t';
%        [Station,Loc,Calib,Comment,Record,Extras,Data]=...
%        rot_seis(Station,Loc,Calib,Comment,Record,Extras,Data);
         Station=fix_station_label(Station);
         [Delta, Azim, Bakazim, Sintr, Tstart, Label, Header, Obs] = ...
         update_data(Data, Extras, Record, Comment, Calib, Loc, Station, label_key);
         if titl_flag=='a'; % update titl
           if exist('Mag')~=1,Mag=Loc(1,:)*0; end
           titl=set_title(Loc(:,1),Station(:,1),Mag(:,1));
         end
         Syn=[];
         clear data1 header1 label1 obs1 data2 header2 label2 obs2 data3 header3 label3 obs3
       else
         clear Station Loc Calib Comment Record Extras Data Mag
       end
     end
   end

% JCC1
 elseif abs(opt(1:4))==abs('orig')
   % change source location and time (origin)
   [smat,n_smat]=cut_string(opt);
   if n_smat~=11,
     disp('Origin needs 10 arguments,');
     disp('LAT LON DEPTH YYYY MM DD HH MM SS.SS MAG')
     disp('Current source parameters are:')
     disp('    lat    lon    depth  year mn dy  hr mn sec    mag')
     disp( sprintf('%8.2f%8.2f%6.1f%7d%3d%3d%4d%3d%6.2f%5.1f',Loc(4:6,1), ...
           time_reformat(Loc(7:8,1)),Mag(1,1)))
   else
     n_records=length(Loc(1,:));
     Loc(4,:)=vec2mat(str2num(cut_string(smat(2,:))),n_records);  % latitude
     Loc(5,:)=vec2mat(str2num(cut_string(smat(3,:))),n_records);  % longitude
     Loc(6,:)=vec2mat(str2num(cut_string(smat(4,:))),n_records);  % depth
     date_time_temp=time_reformat( sscanf(smat(5:10,:)','%f') );
     Loc(7,:)=vec2mat(date_time_temp(1)             ,n_records);  % date
     Loc(8,:)=vec2mat(date_time_temp(2)             ,n_records);  % time
     Mag(1,:)=vec2mat(str2num(cut_string(smat(11,:))),n_records); % event magnitude
     [Delta, Azim, Bakazim, Sintr, Tstart, Label, Header, Obs] = ...
     update_data(Data, Extras, Record, Comment, Calib, Loc, Station, label_key);
     if exist('Mag')~=1,Mag=Loc(1,:)*0; end
     titl=set_title(Loc(:,1),Station(:,1),Mag(:,1));
     clear data1 header1 label1 obs1 data2 header2 label2 obs2 data3 header3 label3 obs3
     Syn=[];
   end
% JCC2
     
 elseif abs(opt(1:4))==abs('writ')
   % write out D1 into an AH file
   [smat,n_smat]=cut_string(opt);
   if n_smat~=2 & n_smat~=3,
     disp('write must have one or two arguments, (AH file name) try again'); 
   else
     out_filename=cut_string(smat(2,:));
     if exist(out_filename)~=2 | n_smat==3
       disp(['writing data to ah file ' out_filename]);
       [Data_out,Extras_out,Record_out,Comment_out,Calib_out,Loc_out,Station_out]= ...
       prepare_out(Data,Extras,Record,Comment,Calib,Loc,Station,data1,header1,label1,obs1);
       ml2ah(Station_out,Loc_out,Calib_out,Comment_out,Record_out,Extras_out,... 
             Data_out,out_filename);
       %temp=['save ' out_filename ' Data_out Extras_out Record_out Comment_out '];
       %temp=[temp 'Calib_out Loc_out Station_out;'];
       %disp(temp);
       %eval(temp);
     else
       disp(['the file: ' out_filename ' already exists'])
       disp('overwrite by reentering command with a third argument');
     end
   end

% JCC1
   elseif abs(opt(1:4))==abs('save')
   % write out D0 and D1 and ah info into a mat file
   [smat,n_smat]=cut_string(opt);
   if n_smat~=2,
      disp('save must have one argument, (MAT file name) try again'); 
   else
     out_filename=cut_string(smat(2,:));
     eval (['save ',out_filename,' Azim Bakazim Calib Comment Data Delta Extras Header Label Loc Mag Obs Record STOP Sintr Station Syn Tstart data1 header1 label1 obs1 titl label_key index w_index'])
   end
% JCC2    

 elseif abs(opt(1:2))==abs('m ')
   % read in and execute a matlab command file
   [smat,n_smat]=cut_string(opt);
   if n_smat~=2,
     disp('m must have one argument, (name of command file) try again'); 
   else
     c_filename=cut_string(smat(2,:));
     if exist(c_filename)==0
       disp(['the file: ' c_filename '.m does not exist, try again']);
     else
       disp(['reading commands from file ' c_filename]);
       eval(c_filename);
       n_new_opt=length(new_opt(:,1));
       i_new_opt=1;
     end
   end

 elseif abs(opt(1:4))==abs('eval')
   % execute a matlab command
   [smat,n_smat]=cut_string(opt);
   if n_smat<2,
     disp('eval must have one argument, (name of matlab script or command) try again'); 
   else
     [smat2,n_smat2]=cut_string(smat(2,:),'(');
     command_name=cut_string(smat2(1,:)),   % remove trailing blanks
%     if exist(command_name)==0 & command_name(1)~='!'
%       disp([command_name ' does not exist, try again']);
%     else
       eval_command=opt(6:length(opt))
       eval(eval_command);
%     end
   end

 elseif abs(opt(1:4))==abs('phas')
   % enter names of phases to be processed
   [smat,n_smat]=cut_string(opt);
   if n_smat==1,
     disp(' phase requires at least one argument (phase names) default=''none''')
   else
     temp=smat(2:n_smat,:);
     [n_phase,n]=size(temp);
     if n<8
       phases=[temp setstr(zeros(n_phase,8-n)+abs(' '))];
     elseif n>8
       disp('phase names truncated at 8 characters')
       phases=temp(:,1:8);
     end
     disp('the following phases were entered')
     disp(phases)
   end

 elseif abs(opt(1:2))==abs('tt')
   % enter names of phases to add to synthetics
   [smat,n_smat]=cut_string(opt);
   if n_smat==1,
     disp(' tt requires at least one argument (phase names) default=''none''')
   else 
     temp=smat(2:n_smat,:);
     [n_tt,n]=size(temp);
     if n<8
       phases_tt=[temp setstr(zeros(n_tt,8-n)+abs(' '))];
     elseif n>8
       disp('phase names truncated at 8 characters')
       phases_tt=temp(:,1:8);
     end
     if phases_tt(1,1:4)=='none',
       Syn=[];Syn_label=[];
     elseif phases_tt(1,1:5)=='label' & n_smat==3
       if phases_tt(2,1:2)=='on'
         tt_label='on ';
       elseif phases_tt(2,1:3)=='off'
         tt_label='off';
       else
         disp('type tt label on or tt label off to turn travel-time labels on and off')
       end
     else
       disp('the following phases were added to the synthetics')
       disp(phases_tt)
       depth=Loc(6,1);
       temp = get_ttt(phases_tt,depth,Delta)';
       %indx=find(min(isinf(Syn')));  % find indices of phases with no times
       %if length(indx)>0,
       %  temp=temp( 
       Syn = [Syn;temp];
       Syn_label=[Syn_label;phases_tt];
     end
   end

 elseif abs(opt(1:4))==abs('widt')
   % enter window width
   [smat,n_smat]=cut_string(opt);
   if n_smat~=3,
     disp('width of window requires two arguments (time (s) before and after phase)')
   else
     wind_width=str2num(smat(2:3,:))';
     disp(['window width set to ' num2str(wind_width(1)) ', ' ...
           num2str(wind_width(2)) ' s'])
   end

 elseif abs(opt(1:4))==abs('sort')
   % sort seismograms
   [smat,n_smat]=cut_string(opt);
   sort_from=-1;
   if     n_smat==2,
     temp=smat(2,:);
     sort_from=0;
   elseif n_smat>=3,
     temp=smat(2,:);
     if     strcmp(temp(1),'0'),  
        sort_from=0;
     elseif strcmp(temp(1),'1'),   
        sort_from=1;
     else, 
        sort_from=-1;
        disp(' if sort has two arguments the first must be 0 or 1')
     end
     temp=smat(3,:);
   else
     disp(' sort requires at least one argument (sort parameter) ')
   end
   if sort_from>=0
     sort_key=[];
     temp1=[];
     if     findstr(temp,'delta'); 
        temp1=Delta;
     elseif findstr(temp,'azim');
        [temp1,sort_key]=sort(Azim);temp1=Azim;
     elseif findstr(temp,'back');
       [temp1,sort_key]=sort(Bakazim);temp1=Bakazim;
     elseif findstr(temp,'index')
        if n_smat==4
          sort_key=eval(smat(4,:));
        else
          disp('sort by index requires 4 arguments: sort 1 index [1:3,5,7:9]')
        end
     else
       disp([' sort does not recognize the sort_key= ' sort_key]);
       disp(' use delta azim or backazim ');
     end
     if length(temp1)>0 | length(sort_key)>0
       if sort_from==1 & length(temp1)>0
         temp1=temp1(header1(5,:));
       end
       if length(sort_key)==0
         [temp1,sort_key]=sort(temp1);
       end
       if sort_from==0,
         [Data, Extras, Record, Comment, Calib, Loc, Station] = ...
         sort_ah(Data, Extras, Record, Comment, Calib, Loc, Station, sort_key);
         [Delta, Azim, Bakazim, Sintr, Tstart, Label, Header, Obs] = ...
         update_data(Data, Extras, Record, Comment, Calib, Loc, Station, label_key);
         clear data1 header1 label1 obs1 data2 header2 label2 obs2 data3 header3 label3 obs3
         Syn=[];
       else
         data1=data1(:,sort_key); header1=header1(:,sort_key);
         obs1=obs1(:,sort_key);   label1=label1(:,sort_key);
       end
     end
   end


% JCC1
% elseif abs(opt(1:4))==abs('mapp')
%   % plot a map of stations and source
%   % default = color, black and white if input is 2
%   [smat,n_smat]=cut_string(opt);
%   if n_smat==2;
%     num = str2num(smat(2,:))
%   else
%     num = 1;
%   end
%  k=figure;
%  mapp(Loc,titl,num);
% JCC2

% JCC1
 elseif abs(opt(1:4))==abs('beam')
   % plot a map of stations and source
   % default = color, black and white if input is 2
   make_beam(data1,header1);
% JCC2
   
 elseif strcmp(opt(1:2),'rm') | strcmp(opt(1:4),'keep')  
   % remove seismograms from Data 0 or data1
   if exist('header1'),
     if length(header1)==0,
       keep_key=[];
       rm_from=[];
     else
       [keep_key,rm_from]=rm_sta(opt,Calib,Label,header1,Delta,Azim,Bakazim);
     end
   else
     [keep_key,rm_from]=rm_sta(opt,Calib,Label,[],Delta,Azim,Bakazim);
   end
   if rm_from==0,
     m_data=size(Data,2);
     if length(keep_key)<m_data & length(keep_key)>0
       [Data, Extras, Record, Comment, Calib, Loc, Station] = ...
       sort_ah(Data, Extras, Record, Comment, Calib, Loc, Station, keep_key);
       [Delta, Azim, Bakazim, Sintr, Tstart, Label, Header, Obs] = ...
       update_data(Data, Extras, Record, Comment, Calib, Loc, Station, label_key);
       clear data1 header1 label1 obs1 data2 header2 label2 obs2 data3 header3 label3 obs3
       Syn=[];
     end
   elseif rm_from==1,
     m_data=size(data1,2);
     if length(keep_key)<m_data & length(keep_key)>0
       data1=data1(:,keep_key);  header1=header1(:,keep_key);
       label1=label1(:,keep_key); obs1=obs1(:,keep_key);
     end
   end

 elseif abs(opt(1:4))==abs('corr')
   % correct data for source polarity, hilbert transformation, attenuation or scale
   [smat,n_smat]=cut_string(opt);
   if n_smat>2,
     disp(' corr requires zero or one argument (file name of cmt file) ')
   elseif n_smat==2,
     cmt_file_name=smat(2,:);
   else
     cmt_file_name='/u0/iris/MATLAB/quakes/cmt.mat';
   end
 
   if exist('header1')==1,
     if length(header1)>0,
       w_index=header1(5,:);
     else
       w_index=[1:length(Loc(1,:))];
     end
   else 
     w_index=[1:length(Loc(1,:))];
   end
   [M,delt_hypo,delt_time,Mw]=getcmt(cmt_file_name,Loc(:,w_index));
   if delt_hypo>500 | abs(delt_time)>300,
     disp ('No event in the CMT catalog is within 300 km and 300 s of your event.  No Moment Tensor was read')
     M=[];
   end
   if (Mag(1,1)==0 & ~isempty(M))
     Mag(1,1) = Mw;       % set magnitude = moment magnitude
     titl=set_title(Loc(:,1),Station(:,1),Mag(1,1));
   end
   % get component, take-off angle, azimuth
   % calculate radiation pattern
   % correct data for radiation pattern

 elseif abs(opt(1:4))==abs('rcmt')
% read the cmt solution for an ascii file in the 4-line Harvard format
% the file should contain only one CMT solution, for the event of interest
% both the moment tensor and the event time/location are read from this file.
% this will overwrite data read in using the quak command.
   [smat,n_smat]=cut_string(opt);
   if n_smat~=2,
     disp('rcmt must have one argument, (cmt filename) try again');
   else
     filename=cut_string(smat(2,:));
     M=getcmt(filename);             % read in event location and Moment tensor
     qtimes=time_reformat(M(1:6)');
     qloc=[M(7:9) max(M(10:11))]';
   end

 elseif abs(opt(1:3))==abs('cut')
   % cut seismograms
   [smat,n_smat]=cut_string(opt);
   if n_smat<2,
    disp('cut must have one argument (0 to cut from D0 and 1 to cut from D1)')
   else
    cut_from=str2num(smat(2,1));
    if cut_from~=0 & cut_from~=1,
     disp('cut must have one argument (0 to cut from D0 and 1 to cut from D1)')
    else
     if (max(abs(Loc(6,:)-Loc(6,1)))) > 0,
       disp('event depths must all be the same, cut not performed');
     else
       depth=Loc(6,1);
       if n_smat>2,
         chan_choice=smat(3,1:3);
         if cut_from==0,
           channels=setstr(Station(8:10,:))';
           i=find(strcmp2(channels,chan_choice));
           data=Data(:,i);header(:,i)=Header(:,i);label=Label(:,i);obs=Obs(:,i);
         else
           channels=setstr(Station(8:10,header1(5,:)))';
           i=find(strcmp2(channels,chan_choice));
           data=data1(:,i);header=header1(:,i);label=label1(:,i);obs=obs1(:,i);
         end
       else
         if cut_from==0,
           data=Data;header=Header;label=Label;obs=Obs;
         else
           data=data1;header=header1;label=label1;obs=obs1;
         end
       end
       [n,m]=size(data);
       tstart=header(1,:);
       sintr=header(6,:);
       tend=tstart+n*sintr;
       delta=Delta(header(5,:));
       if abs(phases(1:1)>=45) & abs(phases(1:1)<=57), % phases = number (phase velocity)
         temp=str2num(phases);
         if length(temp)==2,
           temp=[temp;1];
         elseif length(temp)==1,
           temp=[temp;0;1];
         end
         phase_vel=temp(1);
         t_offset=temp(2);
         cn=temp(3:length(temp)); % earth circuit number
         nn=length(cn);nd=length(delta);
         ddelta= vec2mat(floor(cn/2)*360,nd)' + ...
                 vec2mat(2*rem(cn,2)-1,nd)' .* vec2mat(delta',nn)
         timmat=t_offset+ddelta*111.111/phase_vel;
         pmat=timmat*0;dddpmat=pmat;dtdhmat=pmat;
         n_phase=nn;
       else
         [timmat,pmat,dddpmat,dtdhmat] = get_ttt(phases,depth,delta);
         if exist('time_offset')==1; timmat=time_offset'; end % kluge for stacking short-period array data
       end
       window=[];ray_stuff=[];phase_names=[];
       for iph=1:n_phase
         phs_nam=phases(iph,:)     %force pha_nam to be 6 characters long
         len_phs=length(phs_nam);
         if len_phs<6
           phs_nam=[phs_nam blanks(6-len_phs)];
         end
         phs_nam=phs_nam(1:6);
         tim0=timmat(:,iph)';
         index=find(tim0~=inf); % check for existence of phase
         time=tim0(index);
         wstart=time+wind_width(1);wend=time+wind_width(2);
         keep=find(tstart(index)<wend & tend(index)>wstart);
         index=index(keep);
         time=tim0(index)-tstart(index)+wind_width(1);
         duration=zeros(1,length(time))+wind_width(2)-wind_width(1);
         windows=[time;duration;index];
         for i=1:length(time); phase_names=[phase_names;phs_nam]; end
         temp=[timmat(index,iph)'; pmat(index,iph)'; ...
               dddpmat(index,iph)'; dtdhmat(index,iph)'];
         ray_stuff=[ray_stuff temp]; 
         window=[window windows];
       end
       if length(window)>0
         [data1,header1,label1,obs1]=apply_window(data,header,label,obs, ...
                              window,ray_stuff,phase_names');
       else
         disp('No data are in the requested window--retry')
         disp('Type: eval disp_sta_info   to help determine the problem')
       end
       clear data header label obs
     end
    end
   end

elseif abs(opt(1:4))==abs('tape')
 % apply a cosine taper to data in buffer #1
   [smat,n_smat]=cut_string(opt);
   if n_smat~=2
     disp(' taper requires one argument (eg tape 0.05 gives a 5% cosine taper) ');
   else
     taper_amount=str2num(smat(2,:));
     if taper_amount>.5,
       disp(' taper value must not exceed 0.5 --try again')
     else
       data1=taper_part(data1,header1,taper_amount);
     end
   end

elseif abs(opt(1:4))==abs('hilb')
 % correct data for hilbert transform applied by the earth by applying a 
 % -90 deg phase shift (negative of a hilbert transform) to the data in buffer #1
   [smat,n_smat]=cut_string(opt);
   if n_smat>3 
     disp(' hilbert requires zero, one or two arguments-- try again')
     disp('        if no arguments, transform only phases that were transformed by the Earth')
     disp('        if fisrt arg = 0 transform all seismograms in data1')
     disp('        else transform only the nth seismogram')
     disp('        if < 2 arguments, apply a -90 deg phase shift, else shift by angle')
     disp('        given in second argument')
   else
     if n_smat==3
       phs_shift=str2num(smat(3,:));
     else
       phs_shift=-90;
     end 
     if n_smat==1
       % compare phase names to determine which phases to transform
       phase_names=label1(17:24,:)';
       hilb_names =['PP      '; 'pPP     '; 'sPP     '
                    'PKPab   '; 'pPKPab  '; 'sPKPab  '
                    'SS      '; 'pSS     '; 'sSS     '];
       hilb_index=strcmp2(phase_names,hilb_names);
     else 
       [ndata1,m]=size(data1);
       hilb=str2num(smat(2,:)); 
       if hilb~=0, 
         hilb_index=zeros(m,1);
         hilb_index(hilb)=1;
       else
         hilb_index=ones(m,1);
       end
     end
     hilb_index=(hilb_index>0)*phs_shift;
     [data1,header1]=phase_shift_part(data1,header1,hilb_index);
     [data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1); % fix labels
   end

elseif abs(opt(1:4))==abs('enve')
 % replace data with envelope function of data
   [ndata1,m]=size(data1);
   envelope_index=ones(m,1);
   data1=envelope_part(data1,header1,envelope_index);

elseif abs(opt(1:4))==abs('deme')
 % remove mean of data in buffer #1
   data1=demean_part(data1,header1);

   % JCC1
elseif abs(opt(1:4))==abs('tren')
 % remove linear trend of data in buffer #1
   data1=detrend_part(data1,header1);
   % JCC2
   
 elseif abs(opt(1:4))==abs('plot')
 % plot record section
   [smat,n_smat]=cut_string(opt);
   if n_smat~=2
     disp(' plot requires one or two arguments (0, 1, 2, or 3) ');
   else
     plot_option=cut_string(smat(2,:));
     if finite(obs1(3,:)); 
       plt_offset=obs1(3,:)+wind_width(1); 
     else; 
       plt_offset=wind_width(1);
     end

     % open appropriate figure 
     if plot_option(1)=='0' | plot_option(1)=='1'
       figure(h_main);  % make Coral be the current figure
     elseif plot_option(1)=='2' | plot_option(1)=='3'
       figure_name=['Coral ',plot_option(1)];
       handles=get(0,'Children');
       for iii=1:length(handles);
         if strcmp(get(handles(iii),'Name'),figure_name),
           h_coral2_3=handles(iii);
           iii=0;
           break
         end
       end
       if iii~=0,  % open a new plot window
         h_coral2_3=figure('Position',[501 210 500 800],'NumberTitle','off','Name',figure_name);
       end
       figure(h_coral2_3);  % make this the current figure
     end 

     if tt_label=='on ';
       syn_label=[Syn_label;'label on'];
     else
       syn_label=[Syn_label;'label of'];
     end

     if     plot_option(1)=='0' , delta_plt=Delta;
     elseif plot_option(1)=='1' , delta_plt=Delta(header1(5,:));
     elseif plot_option(1)=='2' , delta_plt=Delta(header2(5,:));
     elseif plot_option(1)=='3' , delta_plt=Delta(header3(5,:));
     end

     if     yaxis=='e',  yval= [1:length(delta_plt)]; ylab='yaxi\e\ylabel\\';
     elseif yaxis=='E',  yval= [1:length(delta_plt)]; ylab='yaxi\E\ylabel\\';
     elseif yaxis=='d',  yval= delta_plt;             ylab='yaxi\d\ylabel\Distance (deg)\';
     elseif yaxis=='D',  yval= delta_plt;             ylab='yaxi\D\ylabel\Distance (deg)\';
     elseif yaxis=='-',  yval= delta_plt;             ylab='yaxi\D\ylabel\Distance (deg)\';
	 elseif (yaxis=='s'	| yaxis=='S')				% superimpose different components from the same station
	   % added by John Winchester on 28 August 96
	   if       plot_option(1)=='0' , labelTmp = Label(1:4,:)';
	     elseif plot_option(1)=='1' , labelTmp = label1(1:4,:)';
	     elseif plot_option(1)=='2' , labelTmp = label2(1:4,:)';
	     elseif plot_option(1)=='3' , labelTmp = label3(1:4,:)';
	   end
	   yval = NaN * ones(1,length(delta_plt));
	   yval(1) = 1;
	   yindex = 1;
	   for iy = 2:length(yval);
		 for iy2 = 1:iy-1
		   if strcmp(labelTmp(iy,:),labelTmp(iy2,:))
			 yval(iy) = yval(iy2);
			 break;
		   end
		 end
		 if isnan(yval(iy))
		   yindex = yindex + 1;
		   yval(iy) = yindex;
		 end
	   end
	   if       yaxis=='s', ylab='yaxi\e\ylabel\\';
	     elseif yaxis=='S', ylab='yaxi\E\ylabel\\';
	   end
	   clear labelTmp yindex
	   % end of 28 August 96 addition
     else                yval= [1:length(delta_plt)]; ylab='yaxi\e\ylabel\\';
     end 
     
     if length(s_fill)==2,
       ylab=[ylab 'fill\' s_fill '\'];
     end
 
     if plot_option(1)=='0'
       my_rsx1(plt_offset,Data,yval,Header,Syn,plot_scale,titl,ylab,Label,0,[],syn_label);
     elseif plot_option(1)=='1' 
       [window,button,nskip,data1,header1,my_rsx_opts]= ...
       my_rsx1(plt_offset,data1,yval,header1,Syn,plot_scale,titl,ylab,label1,1,[],syn_label);
       window=window';

       if button==13 & length(window)>0;
         if strncmp(my_rsx_opts.pick,'abs',3);
           INDX=window(3,:);
           obs1(1,INDX) = header1(1,INDX) + window(1,:) - plt_offset;
           obs1(2,INDX)=obs1(1,INDX) - header1(9,INDX);
         elseif strncmp(my_rsx_opts.pick,'rel',3) & ...
              size(window,2)==size(header1,2) & max(abs(window(1,:)))>0
           obs1(1,:)=header1(1,:)+window(1,:);
           obs1(1,:)=obs1(1,:) - mean(obs1(1,:)-header1(9,:)); % differential travel time (s)
           obs1(2,:)=obs1(1,:) - header1(9,:);               % differential travel time residual (s)
         end
         [data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1,window);
       else
         [data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1);
       end
     elseif plot_option(1)=='2' 
       my_rsx1(plt_offset,data2,yval,header2,Syn,plot_scale,titl,ylab,label2,0,[],syn_label);
     elseif plot_option(1)=='3' 
       my_rsx1(plt_offset,data3,yval,header3,Syn,plot_scale,titl,ylab,label3,0,[],syn_label);
     else
       disp(' plt requires one argument (0, 1, 2, or 3) ');
     end
   end

elseif abs(opt(1:4))==abs('prin')
 % print current plot to a laserwriter
   [smat,n_smat]=cut_string(opt);
   if n_smat==2
     if strcmp(smat(2,1:2),'fs'),
       if exist('h_fs'), 
          figure(h_fs);
          print;
          figure(h_main);
       else
         disp('Focal Sphere figure does not exist--use FS')
       end
     else
       disp('print requires 0 or 1 argument (fs)')
     end
   elseif n_smat==1
     print;
   else
     disp('print requires 0 or 1 argument (fs)')
   end

elseif abs(opt(1:4))==abs('orie')
 % paper orientation for subsequent plots to laserwriter
   [smat,n_smat]=cut_string(opt);
   if n_smat~=2,
     disp('orient must have one parameter: tall, landscape, or portrait')
   else
     orient(cut_string(smat(2,:)))
     orientation=orient;
   end

elseif abs(opt(1:4))==abs('grid')
 % put a grid on the plot
   grid;

elseif abs(opt(1:4))==abs('filt')
 
 % Butterworth filter data1, (data1 -> data1).
 % arguments: cutoffPeriod,order,passOpt, filtOpt.
 % passOpt = 0 - lowpass or bandpass
 %         = 1 - highpass
 %         = 2 - bandstop
 % filtOpt = 0 - zero-phase filter
 %         = 1 - minimum-phase filter
 
   [smat,n_smat]=cut_string(opt);
   if n_smat==1,
      disp('filt requires at least one argument: the cutoff period')
   else
      [calib,calib_count,ERRMSG]=sscanf(opt,'%*s %f %f %f %f');

 
     % check for defaults:
 
     filtType  = 0;
     passOpt = 0;
     order = 8;
     cutoffPeriod = calib(1);

     if calib_count == 2
       order = calib(2)
     elseif calib_count == 3
       order = calib(2);
       passOpt = calib(3);
     elseif calib_count == 4
       order = calib(2);
       passOpt = calib(3);
       filtType = calib(4);
     end
     cutoffFreq = (header1(6,:) ) ./ cutoffPeriod;

     % dataOut = zeros(size(data1));

     [dataR,dataC] = size(data1);

     for i = 1:dataC,
       if passOpt == 0                         % lowpass or bandpass
         [b,a] = butter(order, 2*cutoffFreq(i));
       elseif passOpt == 1                     % highpass
         [b,a] = butter(order, 2*cutoffFreq(i),'high');
       elseif passOpt == 2                     % bandstop
         [b,a] = butter(order, 2*cutoffFreq(i),'stop');
       end

       if filtType == 0        % zero-phase filter
         data1(:,i) = filtfilt(b,a,data1(:,i));
       else
         data1(:,i) = filter(b,a,data1(:,i));
       end
     end
   end

elseif abs(opt(1:4))==abs('Deco')
 % deconvolve instrument response
  [data1,err] = coral_deco (opt,data1,header1,Calib);

elseif abs(opt(1:4))==abs('deco')
 % deconvolve instrument response 
   [smat,n_smat]=cut_string(opt);
   calib_key=-1;
   if n_smat==1,
     disp('deco requires at least one argument')
     calib_key=-1;
   else
     [calib,calib_count,ERRMSG]=sscanf(opt, ... 
     '%*s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
     if length(ERRMSG)==0,
       if calib_count<=2,% if there are 1 or 2 arguments and both are numbers
         calib_key=2;    % the first is an index. reconvolve Calib(index) 
         calib_no=calib(1);
         if calib_no<1 | calib_no>length(data1(1,:));
           disp('first argument of deco out of range of possible integers--retry') 
           calib_key=-1;
         end
       else                  % if there are more than 2 arguments, the first
                             % is a key to determine type of reconvolution
         calib_key=calib(1); 
         if calib_key==3,
           if calib_count~=7,
             disp('deco key equals 3 for cos tapered output filter response')
             disp('arguments must be: waterlevel,gain,f1,f2,f3,f4--retry')
             calib_key=-1;
           else
             calib=calib([1,3:7]);
           end
         elseif calib_key==4,
           if calib_count~=3 & calib_count~=4
             disp('deco key equals 4 for gaussian tapered output filter response')
             disp('arguments must be: waterlevel,gain,f2,[f0]--retry')
             calib_key=-1;
           else
             calib=calib([1,3:length(calib)]);
           end
         else  
           disp('Error in definition of new response--retry')
           calib_key=-1;
         end
       end  
     elseif smat(2)=='s' | smat(2)=='i' | smat(2)=='l' | smat(2)=='r',
       calib_key=1;
     else   
       disp('error in definition of new response--retry')
       calib_key=-1;
     end
     if calib_key~=-1;
       if n_smat>=3, waterlevel=sscanf(smat(3,:)','%f'); else, waterlevel=1e-8; end
       w_index=header1(5,:);sintr1=header1(6,:);key=1:length(w_index);
       % if sample intervals differ by more than 1 parts in 10^3 then resample the data
       % IDA stations have sample intervals that differ by about .0001 from
       % nominal values, we will live with that for now, but must be aware that
       % this causes problems when cross-correlating
       if (max(sintr1)-min(sintr1))/max(sintr1) > 0.001,
         [max_rate, sintr1, data1] = resam(sintr1, data1);
         [ndata1,m]=size(data1);dur1=sintr1*(ndata1-1);
         header1(2,:)=ones(1,m).*dur1;
         header1(3,:)=zeros(1,m);
         header1(4,:)=ones(1,m).*dur1;
         header1(6,:)=sintr1;
       end
       if calib_key==1,
         calib=get_inst_resp(smat(2));
       elseif calib_key==2,
         calib=Calib(:,w_index(calib_no));
         disp(['convolve with instrument response of ' setstr(Station(2:5,w_index(calib_no)))' ])
       end
       data1=decon_inst(data1,Calib(:,w_index),calib,sintr1,key,waterlevel);
     end
   end

elseif abs(opt(1:4))==abs('copy')
 % copy from one buffer to another
   [smat,n_smat]=cut_string(opt);
   if n_smat~=3
     disp('copy requires two arguments (0, 1, 2, or 3)')
   else
     from=smat(2,1);
     to  =smat(3,1);
     from_n=abs(from)-abs('0');
     to_n  =abs(to)  -abs('0');
     if from_n<0 | from_n>3 | to_n<1 | to_n>3,
       disp('copy arguments must be 0, 1, 2, or 3; eg. copy 1 2')
     elseif from_n==0
       if exist('Data')==1,
         temp=['data' to '=Data; header' to '=Header; label' to '=Label; obs' to '=Obs;'];
         disp(temp);
         eval(temp);
       else
         disp('Data does not exist, use read to create Data')
       end
     else 
       temp=['exist_data=(exist(''data' from ''')==1)';];
       eval(temp);
       if exist_data
         temp=['data' to '=data' from '; header' to '=header' from  ...
            '; label' to '=label' from '; obs' to '=obs' from ';'];
         disp(temp);
         eval(temp);
       else
         disp(['data' from ' does not exist, try again'])
       end
     end
   end

elseif abs(opt(1:3))==abs('cat')
 % concatenate one buffer after another
   [smat,n_smat]=cut_string(opt);
   if n_smat~=3
     disp('cat requires two arguments (1, 2, or 3)')
   else
     from=smat(2,1);
     to  =smat(3,1);
     from_n=abs(from)-abs('0');
     to_n  =abs(to)  -abs('0');
     if from_n<1 | from_n>3 | to_n<1 | to_n>3,
       disp('cat arguments must be 1, 2, or 3; eg. cat 1 2')
     else 
       temp=['exist_data=(exist(''data' from ''')==1)';];
       eval(temp);
       temp=['exist_data_to=(exist(''data' to ''')==1)';];
       eval(temp);
       if exist_data & exist_data_to
       temp=['[nto,mto]=size(data' to ');[nfrom,mfrom]=size(data' from ');'];
       eval(temp);
       if nfrom>nto,
         grow=to;
         mmm=mto;
       else
         grow=from;
         mmm=mfrom;
       end
       if mto>0 & mfrom>0,  % both have data so deal with windowing them
         temp=['window_dur=header' grow '(6,:)*(max(nfrom,nto)-1)']
         eval(temp);
         window=[zeros(1,mmm); window_dur; (1:mmm)];
         temp=['data' grow ',header' grow ',label' grow ',obs' grow];
         temp=['[' temp ']=apply_window(' temp ',window);'];
         eval (temp);
       end
       temp=['data' to '=[data' to ' data' from '];']; eval(temp);
       temp=['header' to '=[header' to ' header' from '];']; eval(temp);
       temp=['label' to '=[label' to ' label' from '];']; eval(temp);
       temp=['obs' to '=[obs' to ' obs' from '];']; eval(temp);
       else
         if ~(exist_data)
           disp(['data' from ' does not exist, try again'])
         end
         if ~(exist_data_to)
           disp(['data' to ' does not exist, try again'])
         end
       end
     end
   end

 
% JCC1   
 elseif abs(opt(1:4))==abs('stac')
 % make a slant-stack of the data in data1.
 % If no arguments, make a stack at -.5 sec/deg to .5 sec/deg.
   % 3rd root
  k=figure;
   [smat,n_smat]=cut_string(opt);
   if n_smat == 3 | n_smat == 4 | n_smat > 9 
     disp('Stack requires no, 1, 4, 5, 6, or 7 arguments')
     disp('stac Nroot LowerSlowness UpperSlowness Step Envelope(1=Y) ...')
     disp('       ... Scale DecimateFactor RelativeToP')
     disp('')
     disp('Default')
     disp('stac 3 -.5 .5 0.05 0 1 1 1')
     else 
      	if exist('phases_tt') ==0 phases_tt =('P     '); end
        if n_smat >1 Nroot = str2num(smat(2,:)); else Nroot =3; end
        if n_smat >2 
     slowness1=str2num(smat(3,:));slowness2=str2num(smat(4,:));step=str2num(smat(5,:));
          else slowness1=-.5; slowness2 = .5; step =0.05; 
        end
        if n_smat >5 env=str2num(smat(6,:)); else env=0; end
        if n_smat >6 scale = str2num(smat(7,:));else scale =1; end
        if n_smat >7 decimate = str2num(smat(8,:));else decimate =1; end
        if n_smat >8 relative = str2num(smat(9,:));else relative =1; end
	
         [timestack,stackeddata,movedstackeddata,slowness] = make_stack (data1,Delta,...
	   header1, Loc, Station, Mag, phases_tt, Nroot, slowness1, slowness2, step,...
	   env, scale, decimate, relative);
    end
    
    
 elseif abs(opt(1:4))==abs('vesp')
 % make a vespagram of the stacked data in stackeddata, timestack, and slowness
 % The arguments = 1) make envelope of data (yes=1)
 %                  2) height at which to put a ceiling on data 
 %                     (the P wave is normalized to 1)
 %                  3) relative (default is yes, ==1)
   if exist('timestack') ==1 & exist('slowness') & exist ('stackeddata') ==1
  [smat,n_smat]=cut_string(opt);
   if n_smat > 3
     disp('Vespagram requires no, 1, 2, or 3 arguments')
     disp('')
     disp('vesp envelope(1=Y) MaxHeight Relative')
     disp('defaults')
     disp('vesp 1 .5 1')
     else 
        if exist('phases_tt') ==0 phases_tt =('P     '); end
        if n_smat >1 env = str2num(smat(2,:)); else env =1; end
        if n_smat >2 scal= str2num(smat(3,:)); else scal = .5; end
        if n_smat >3 relative = str2num(smat(4,:));else relative =1; end
	make_vespagram(timestack, slowness, stackeddata, Delta, Loc, Station, Mag,...
	  env, scal, phases_tt, relative);
    end
    else 
    disp('First run "stack" then run the vespagram program to make color vesps.')
    end
% JCC2   

 % JCC1
elseif abs(opt(1:4))==abs('alig')
  % Align data based on the maximum or minimum or CORRvsBEAM in a time window
   [smat,n_smat]=cut_string(opt);
  if n_smat==3 | n_smat > 4
    disp('Align requires zero, one, or three arguments')
    disp('')
    disp('ALIGN Max(1)/Min(2)/CORRvsBEAM(3) TimeWindow')
    disp('TimeWindow is defined as time displayed on the screen (s)')
    disp('alig     1    -5   5')
   else
    if n_smat >3
       time_window = [str2num(smat(3,:)) str2num(smat(4,:))];
       else time_window = wind_width;
    end
    if n_smat > 1
      [data1,header1,label1,obs1,ccval]=align_seis(data1,time_window,header1,...
        label1,obs1,wind_width,str2num(smat(2,:)));
    end
  end
% JCC2
    
elseif abs(opt(1:4))==abs('xcor')
   % cross-correlate data and realign on peaks of cross-correlograms
   % if no arguments, cross correlate all seismograms, otherwize use the
   % nth seismogram as a reference seismogram and align others with respect
   % to that one
   [smat,n_smat]=cut_string(opt);
   if n_smat==2
     ref_trace=str2num(smat(2,:));
   else
     ref_trace=0;
   end

   [n,m]=size(data1);
   sintr1=header1(6,:);

%  cross correlate seismograms and return time lag of peaks in tlag
   [tlag, ccval, cc_times, cc, lag_array, xcor_array, n_idx] = ...
                    my_cross_times(data1, sintr1, 1, ref_trace);

%  del_t (s) are the differential times that provide the optimal alignment of
%  all the seismograms rewindow the seismograms according to this shift. 
   if ref_trace==0,
     del_t = dtimes_invert(tlag',m);
   else
     del_t=tlag';
   end
   Tdur=header1(2,:);
   window=[-del_t';Tdur;(1:m)];   
   obs1(1,:)=header1(1,:)-del_t';
   obs1(1,:)=obs1(1,:) - mean(obs1(1,:)-header1(9,:)); % differential travel time (s)
   obs1(2,:)=obs1(1,:) - header1(9,:);               % differential travel time residual (s)
   [data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1,window);

 elseif abs(opt(1:2))==abs('fs')
   % plot a focal sphere
   [smat,n_smat]=cut_string(opt);
   fs_type=1; fs_ray_type=1; fs_up_down=1; fs_scal=25; fs_cut=5.; fs_angle=90;
   if n_smat>1,  fs_type    =str2num(smat(2,:));  end % 1=RS, 2=FS, 3=both
   if n_smat>2,  fs_ray_type=str2num(smat(3,:));  end % 1=P, 2=SV, 3=SH
   if n_smat>3,  fs_up_down =str2num(smat(4,:));  end % 1=down, 2=up
   if n_smat>4,  fs_scal    =str2num(smat(5,:));  end
   if n_smat>5,  fs_cut     =str2num(smat(6,:));  end
   if n_smat>6,  fs_angle   =str2num(smat(7,:));  end
   if fs_type<1 | fs_type>3,
     disp(' first argument to fs must be 1 (residual sphere), 2 (polarity sphere) or 3 (both)')
   elseif fs_ray_type~=1 & fs_ray_type~=2 & fs_ray_type~=3,
     disp(' second argument to fs must be 1 (P), 2 (SV) or 3 (SH)')
   else
     fs_desc=['residuals       ' % write what is being plotted to screen
              'polarities      '
              'P radiation     '
              'SV radiation    '
              'SH radiation    '
              'lower hemisphere' 
              'upper hemisphere' ];
     if fs_type<3, 
       disp( [fs_desc(fs_type,:) fs_desc(fs_ray_type+2,:) fs_desc(fs_up_down+5,:)] )
     else 
       disp( [fs_desc(1,:) fs_desc(1,:) fs_desc(fs_ray_type+2,:) fs_desc(fs_up_down+5,:)] )
     end

     depth=Loc(6,1);radius=6371-depth;
     [pvel,svel]=iasp91(radius);
     if fs_ray_type==1, vel=pvel; else, vel=svel; end
     tstart1=header1(1,:); modeltime1=header1(9,:); 
     index1 =header1(5,:); rayparm1=header1(10,:);
     up_down=(header1(12,:)>0); % =1 for up, 0 for down
     resid=obs1(2,:)';
     take_off=(asin(rayparm1*vel/radius*180/pi)*180/pi)';
     azim    =Azim(index1)'; % if ray is up plot at azim+180
     flip_direction = (fs_up_down==1 & up_down==1)' | (fs_up_down==2 & up_down==0)';
     temp=find(flip_direction)
     if length(temp)>0,
       take_off(temp)=180-take_off(temp);
       azim=azim+flip_direction*180;
     end
     polarity=sign(header1(7,:))';
     uncertain=ones(1,length(resid))';
     data_array=[take_off azim resid uncertain polarity];
     if length(M)>=23 & fs_type>1, Mc=RadPatJC(M(12:23),fs_ray_type,fs_up_down); end;
     handles=get(0,'Children');
     for iii=1:length(handles);
       if strcmp(get(handles(iii),'Name'),'Focal Sphere'),
         h_fs=handles(iii);
         iii=0;
         break
       end
     end
     if iii~=0,  % open a new plot window
       h_fs=figure('Position',[910 480 360 480],'NumberTitle','off','Name','Focal Sphere');
     end
     figure(h_fs);  % make this the current figure
     clf
     if fs_type==3,
       h_fs1=axes('position',[.3 .55 .4 .4]);
       if length(M)>=23, radplt(Mc); hold on; end;
%       if length(M)>=23, radpat1(M(12:23),fs_ray_type,fs_up_down);hold on; end
       focal_sphere(2,data_array,titl,' ',[fs_scal,fs_cut,fs_angle])
       set(h_fs1,'Visible','off');axis('square')
       h_fs2=axes('position',[.3 .05 .4 .4]);
       hold off
       focal_sphere(1,data_array,titl,' ',[fs_scal,fs_cut,fs_angle])
       set(h_fs2,'Visible','off');axis('square')
       subplot(111)
     else
       h_fs1=axes('position',[.1 .1 .8 .8]);
       if length(M)>=23 & fs_type==2, radplt(Mc); hold on; end;
%       if length(M)>=23, radpat1(M(12:23),fs_ray_type,fs_up_down);hold on; end
       focal_sphere(fs_type,data_array,titl,' ',[fs_scal,fs_cut,fs_angle])
       set(h_fs1,'Visible','off');axis('square')
       hold off
     end
     h_title=get(h_fs1,'Title'); set(h_title,'visible','on');
   end
   figure(h_main);  % make main window the current window

 elseif abs(opt(1:4))==abs('inte')
    % integrate all data in buffer #1
      sintr1=header1(6,:);
      data1=integrate_part(data1,header1,sintr1);
  
elseif abs(opt(1:4))==abs('diff')
    % differentiate all data in buffer #1
      sintr1=header1(6,:);
      data1=differentiate_part(data1,header1,sintr1);

 elseif abs(opt(1:4))==abs('titl')
   % change plot title
   [smat,n_smat]=cut_string(opt);
   if n_smat<2
     titl=' ';titl_flag='a';
   else
     titl=opt(min(find(opt==' '))+1 : length(opt));
     if titl=='a'; % title will be date/time depth, magnitude, component of first record
       titl_flag='a';
       if exist('Loc')==1
         titl=set_title(Loc(:,1),Station(:,1),Mag(:,1))
       end
     else
       titl_flag=' ';
     end
   end

 elseif abs(opt(1:4))==abs('scal')
   % change plot scale
   [smat,n_smat]=cut_string(opt);
   if n_smat<2
     disp('scale requires one argument which is the ratio of the maximum peak-to-peak')
     disp('amplitude to the total plot height. (> 0 true scale, < 0 normalizes traces')
   else
     plot_scale(1)=str2num(smat(2,:));
     disp([' plot scale = ' num2str(plot_scale(1)) ])
   end

 elseif abs(opt(1:4))==abs('yaxi')
   % change of y-axis for record sections
   [smat,n_smat]=cut_string(opt);
   if n_smat==2,
     temp=smat(2,:);
     if temp(1)=='e'|temp(1)=='d'|temp(1)=='s'|temp(1)=='E'|temp(1)=='D'|temp(1)=='S'|temp(1)=='-' ,
       yaxis=temp(1);
     else
       n_smat=1
     end
   end
   if n_smat~=2,
     disp('yaxis requires one argument which must be')
     disp('      ''d''  space seismograms by distance with close distance on bottom') 
     disp('      ''D''  space seismograms by distance with close distance on top')
     disp('      ''-''  space seismograms by distance with close distance on top')
     disp('      ''e''  space seismograms evenly with close distance on bottom (default)')
     disp('      ''E''  space seismograms evenly with close distance on top')
     disp('      ''s''  space seismograms evenly with close distance on bottom, components superimposed')
     disp('      ''S''  space seismograms evenly with close distance on top, components superimposed')
   end

 elseif abs(opt(1:4))==abs('fill')
   % option to draw filled seismograms
   [smat,n_smat]=cut_string(opt);
   if n_smat==2,
     temp=deblank(smat(2,:));
     if length(temp)==1;
       s_fill='n';
     elseif length(temp)==2;
       s_fill=temp;
     end
   else
     disp('fill requires one argument which must be')
     disp('      ''n''   do not fill seismograms or')
     disp('      two  adjacent characters chosen from ymcrgbwk to indicate the')
     disp('           colors for solid fill seismograms')
     disp('      e.g. fill wk')
   end

 elseif abs(opt(1:4))==abs('xwin')
   % change plot window
   [smat,n_smat]=cut_string(opt);
   if n_smat<3
     disp('xwin requires two or three arguments. If two arguments are given, they are')
     disp('the fractional distances along x-axis where traces start and end')
     disp('If there are three arguments, the first is fractional distance along') 
     disp('x-axis where traces start and the second is the scale (s/cm) after')
     disp('printing in landscape mode, the value of the third argument is not used')
   else
     plot_scale(2)=str2num(smat(2,:));
     plot_scale(3)=str2num(smat(3,:));
     if n_smat==4
       plot_scale(4)=1;
     else 
       plot_scale(4)=0;
     end
     disp([' plot window = ' num2str(plot_scale(2)) '  ' num2str(plot_scale(3)) ])
   end

 elseif abs(opt(1:4))==abs('shif')
    % shift
    [smat,n_smat]=cut_string(opt);
     if n_smat < 2
       disp('shif requires 1 argument which is the row number of the bestN matrix.')
       disp('The bestN matrix gives the best N solutions found by the genetic algorithm')
       disp('for the alignment of the seismograms in data buffer 1.')
     end
     obs1(3,:) = bestN(str2num(smat(2,:)),:);

 else
   disp(' command not recognized--retry')
 end
end 

% delete file coral.cmd and write the commands that were saved to file coral.cmd
% also write a file in the form of a matlab script that can be run later using the
% macro command (m).

temp=cut_string(opt_save, setstr(0));
[ntemp,mtemp]=size(temp);
if ntemp>2,
  if exist('coral.cmd')==2, 
    !/bin/rm coral.cmd
  end
  diary coral.cmd
  disp(temp)
  diary off 

  if exist('dt.m')==2, 
    !/bin/rm dt.m
  end
  temp1=temp(2:ntemp-1,:);ntemp=ntemp-2;
  top=['new_opt=[' blanks(mtemp-7)];
  bottom=['];' blanks(mtemp)];
  quote=setstr(zeros(ntemp,1)+abs(''''));
  temp1=[top;[quote temp1 quote];bottom];
  diary dt.m
  disp(temp1)
  diary off 
end
% save travel-time offsets relative to iasp91, distance, station and event lat and lon.
if exist('obs1')==1,
  wi=header1(5,:); 
  delta_temp=Delta(wi); 
  out_matrix=[obs1(2,:)',delta_temp(:),Loc([1,2,4,5],wi)'];
end
