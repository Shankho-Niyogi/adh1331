function d=plot_amp(ah_filename,dimen,flag,tt,filter_freqs);
%   plot_amp      plot seismic trace data in absolute values
% Usage: d=plot_amp(ah_filename,dimen,flag,tt,filter_freqs);
% ah_filename is file name for ah data
% dimen must be one of d,v, or a for displacement, velocity or acceleration
% flag = 0 assumes the instrument is already flat to velocity.  Divide by the
%          gain at 1 Hz and integrate, do nothing or differentiate in the time
%          domain to get displacement, velocity or acceleration.  
% flag ~=0 determine instrument response in desired units and deconvolve the 
%          response making the response flat from f2 to f3 and taper to zero
%          at f1 and f4 where filter_freqs=[f1,f2,f3,f4] Hz. 
%          window the data at tt=[start,tend] seconds with respect to the origin time
%          use [-Inf Inf] to display all the data
%
% e.g.
% cat /data0/gia/Proj2/95*.ah.? > /dmc/uw/kcc/9501290311.ah
%plot_amp('/dmc/uw/kcc/9501290311.ah','a',1,[0 50],[.03,.05,10,20]);
%plot_amp('/dmc/uw/kcc/9501290311.ah','a',0,[0 50]);

if nargin<=1, dimen='d';       end
if nargin<=2, flag=0;          end
if nargin<=3, tt=[-Inf Inf];   end
if nargin<=4, filter_freqs=[]; end

if     dimen=='d', units='m';     titl='peak displacement (m)';
elseif dimen=='v', units='m/s';   titl='peak velocity (m/s)';
elseif dimen=='a', units='m/s/s'; titl='peak acceleration (m/s/s)';
end

tstart=tt(1);
tend=tt(2);

[Station,Loc,Calib,Comment,Record,Extras,Data] = ah2ml(ah_filename); % read ah file
[L,M]=size(Data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This block of code is only used for sorting the data by distance and by
% orientation, and can be removed if desired

sort_flag=2;
if sort_flag~=0,

  % calculate epicentral distance and sort by distance and by channel
  sta_lat=Loc(1,:);sta_lon=Loc(2,:);eq_lat=Loc(4,:);eq_lon=Loc(5,:);
  [delta,azeqst,azsteq]=delaz(eq_lat,eq_lon,sta_lat,sta_lon,0);
  [junk,index]=sort(delta);
 
  if sort_flag==2, 
    channel=left_justify(setstr(Station(7:12,index)'));  % get channel names
    sta=setstr(Station(1:6,index)');                     % get station names
    ind=diff(strcmp2(sta,sta));                          % group by station 
    end_ind=[find(ind~=0) ; M];
  
    for i=1:length(end_ind)                              % loop over each station
      if i==1, jj=1:end_ind(1);                          % find indices for each station
      else     jj=(end_ind(i-1)+1):end_ind(i);
      end
      if length(jj)>1                                    % if more than one channel assume
        test=channel(jj,3);                              % orientation is third character and
        kk=find(test=='T');if length(kk)==1, test(kk)='P'; end % change T to P so alphabetical
        kk=find(test=='t');if length(kk)==1, test(kk)='p'; end % sort gives E N R T Z order
      end   
      [junk,ind]=sort(test);
      index(jj)=index(jj(ind));                          % apply sorting for this station
    end
  end
  
  % sort all the incoming data
  Station=Station(:,index);Loc=Loc(:,index); Calib=Calib(:,index); Comment=Comment(:,index);
  Record=Record(:,index); Extras=Extras(:,index); Data=Data(:,index);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sta_lat=Loc(1,:);sta_lon=Loc(2,:);eq_lat=Loc(4,:);eq_lon=Loc(5,:);
[delta,azeqst,azsteq]=delaz(eq_lat,eq_lon,sta_lat,sta_lon,0);
delta=delta*111.111;  %epicentral distance (km)

Sintr=Record(4,:);      % sample interval
Data=demean(Data);      % remove mean of data
Data=taperd(Data,.05);  % taper 5% from beginning and end of data
if Loc(7,1)==1900 & Loc(8,1)==0, % no origin time was given
  deltime=zeros(M,1);
else
  deltime=timediff(Record(1:2,:),Loc(7:8,:));  % record start times minus origin times (s)
end
ti=[0:L-1]';

clf
hold off
peak2peak=zeros(M,1);
peak=peak2peak;

for i=1:M
  t=ti*Sintr(i)+deltime(i);              % cut out desired time window
  j=find(t>tstart & t<tend);
  t=t(j);
  d=demean(Data(j,i));                   % remove mean from cut out window
  d=corr_inst(d, Calib(:,i), Sintr(:,i), flag, dimen, filter_freqs); % deconvolve response
  peak(i)=max(abs(d));                   % peak absolute value
  peak2peak(i)=max(d)-min(d);            % maximum peak-to-peak value
  y_offset=sum(peak2peak)-(peak2peak(1)+peak2peak(i))/2; % offset for plot
  plot(t,d+y_offset,'-');hold on;        % draw seismogram
  label=[setstr((Station(1:12,i)')) ...
  sprintf('  %d  %d%10.1e',round(delta(i)),round(azeqst(i)), peak(i)) ];
  text(min(t),y_offset+0.1*peak2peak(i),label)  % label seismogram
end
axis([-Inf Inf -Inf Inf])
xlabel('time (s) after origin time')
disp(['peak amplitudes are ' sprintf('%9.1e',peak) '  ' units]);
temp=set_title(Loc(:,1),Station(:,1),0.); temp=temp(1:(length(temp)-8));
titl=[temp '   ' titl];
disp(titl);
title(titl)
orient landscape
