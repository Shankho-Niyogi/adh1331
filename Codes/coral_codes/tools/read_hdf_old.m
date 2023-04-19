function [HDF,HDF_KEY]=read_hdf_old(file_name);
%   read_hdf_old  read earthquake catalog in HDF format
% USAGE: [HDF,HDF_KEY]=read_hdf_old(file_name);
% file_name is as ascii string containing the catalog file name
% eg. file_name='/extra/archive/seis/noaa_6.0';

% extra code that may be useful someday
%
%[a,b]=unix('wc test');a=sscanf(b,' %f',3);nchar=a(3);
%a=setstr(zeros(1,nchar));
%nread=1000;i1=1;
%while i1<=nchar,
%  i2=min(nchar,i1+nread-1);
%  a(i1:i2)=fscanf(fid,'%c',nread);
%  i1=i2+1;
%end


tic;
%  read in the whole file as a character string
fid=fopen(file_name);
a=fscanf(fid,'%c');
fclose(fid);  % read everything into a string

toc,tic
i=find(abs(a)==10);                          % find the line feeds
max(diff(i)),min(diff(i))
line_length=max(diff(i));                    % maximum line length
n_lines=length(a)/line_length;               % number of lines (assumes all lines are same length)
b=reshape(a,line_length,n_lines)';           % convert a to a matrix
a=b(:,1:56);
clear b
i=find(a==' ');
b= (a~=' ') .* (abs(a)-abs('0'));
clear a

year  =sscanf(b(:,[4,05:08])' , '%f',n_lines);     % get year
month =sscanf(b(:,[4,09:10])' , '%f',n_lines);     % get month
day   =sscanf(b(:,[4,11:12])' , '%f',n_lines);     % get day
hour  =sscanf(b(:,[4,13:14])' , '%f',n_lines);     % get hour
minute=sscanf(b(:,[4,15:16])' , '%f',n_lines);     % get minute
second=sscanf(b(:,[4,17:19])' , '%f',n_lines)/10;  % get second
lat   =sscanf(b(:,[4,20:24])' , '%f',n_lines)/1000;% get latitude
lat   =lat.*(-2*(abs(b(:,25))==abs('S'))+1);       % multiply lat by -1 if 'S'
lon   =sscanf(b(:,[4,26:31])' , '%f',n_lines)/1000;% get longitude
lon   =lon.*(-2*(abs(b(:,32))==abs('W'))+1);       % multiply lon by -1 if 'W'
depth =sscanf(b(:,[4,33:35])' , '%f',n_lines);     % get depth
x=b(:,36);  x10= (x~=' ') .* (abs(x)-abs('0'));    %convert column 36 to integers(blank=0)
x=b(:,37);  x1 = (x~=' ') .* (abs(x)-abs('0'));    %convert column 37 to integers(blank=0)
mb=x10+x1/10;                                      %mb=column 36+ column 37/10
x=b(:,54);  x10= (x~=' ') .* (abs(x)-abs('0'));    %convert column 54 to integers(blank=0)
x=b(:,55);  x1 = (x~=' ') .* (abs(x)-abs('0'));    %convert column 55 to integers(blank=0)
ms=x10+x1/10;                                      %ms column 54+ column 55/10
region=sscanf(b(:,[4,51:53])' , '%f',n_lines);     % get region number

HDF=[year,month,day,hour,minute,second,lat,lon,depth,mb,ms,region];
HDF_KEY='year month day hour minute second lat lon depth mb ms region';
toc
