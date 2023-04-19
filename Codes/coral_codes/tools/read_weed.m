function [EQS,EQS_KEY]=read_weed(file_name);
%   read_weed     read earthquake catalog in WEED format
% USAGE: [EQS,EQS_KEY]=read_weed(file_name);

% First determine the number of events (nevents) in the file
% using the unix command wc
%file_name='example_weed_catalog';
eval(['[a,b]=unix(''wc ' file_name ''');']);
a=sscanf(b,' %f',3);
nevent=a(1);

%a=setstr(zeros(1,nchar));
fid=fopen(file_name);
i1=0;
D.Source  = cell(nevent,1);
D.EqDate  = zeros(nevent,1)+NaN;
D.EqTime  = zeros(nevent,1)+NaN;
D.EqLat   = zeros(nevent,1)+NaN;
D.EqLon   = zeros(nevent,1)+NaN;
D.EqDepth = zeros(nevent,1)+NaN;
D.EqLat   = zeros(nevent,1)+NaN;
D.Mw      = zeros(nevent,1)+NaN;
D.Ms      = zeros(nevent,1)+NaN;
D.Ml      = zeros(nevent,1)+NaN;
D.mb      = zeros(nevent,1)+NaN;

date_time = zeros(nevent,6)+NaN;
loc       = zeros(nevent,5)+NaN;
mags      = zeros(nevent,4)+NaN;
while i1<nevent;
  line=fgetl(fid);
  if ~isstr(line), break, end
  i=findstr(',',line);
  if length(i)>=6;
	% first get the source date/time
	tmp = line([i(1)+1:(i(2)-1)]);
	j=[findstr('/',tmp) findstr(':',tmp)];
	if length(j)>0; tmp(j)=' ';end
	[dat_tim,count,date_errmsg]=sscanf(tmp,'%f',6);
	
	% then get the source lat, lon, depth and region numbers
	tmp = line([i(2)+1:(i(7)-1)]);
	j=findstr(',',tmp);
	if length(j)>0; tmp(j)=' ';end
	[stuff,count,stuff_errmsg]=sscanf(tmp,'%f',5);
	if length(date_errmsg)>0 
      disp(date_errmsg);
    elseif length(stuff_errmsg)>0
      disp(date_errmsg);
    else
	  i1=i1+1;
	  date_time(i1,:)=dat_tim(:)';
	  loc(i1,:)      =stuff(:)';
	  D.Source{i1,1} = line(1:i(1)-1);
	  i(length(i)+1)=length(line)+1;
      for k=1:(length(i)-6)/2;
		kk=5+2*k;
		mag_type = (line([i(kk)+1:i(kk+1)-1]));
		j=findstr(' ',mag_type); 
		if length(j)>0; mag_type(j)=[];end
		kk=kk+1;
		val      = sscanf(line([i(kk)+1:i(kk+1)-1]),'%f');

		jj= find(strcmp(upper(mag_type),{'MW','MS','MB','ML'}));
		if length(jj)==1;
		  mags(i1,jj)=val;
		end
      end
	end
  end
end

ind=1:i1;
date_time=date_time(ind,:);
%date_time=time_reformat(date_time);
loc      =loc(ind,:);
mags     =mags(ind,:);
EQS      =[date_time loc mags];
fclose(fid);  % read everything into a string
EQS_KEY='year month day hour minute second lat lon depth region1 region2 Mw Ms mb Ml';
