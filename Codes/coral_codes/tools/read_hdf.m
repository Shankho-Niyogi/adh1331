function [HDF,HDF_KEY]=read_hdf(file_name);
%   read_hdf      read earthquake catalog in HDF format
% USAGE: [HDF,HDF_KEY]=read_hdf(file_name);

% This takes about 5 minutes per 18000 (one years) events

% First determine the number of events (nevents) in the file
% using the unix command wc

eval(['[a,b]=unix(''wc ' file_name ''');']);
a=sscanf(b,' %f',3);
nevent=a(1);

%a=setstr(zeros(1,nchar));
fid=fopen(file_name);
i1=1;
nread=50;                                                % read 50 lines at a time
HDF=zeros(nevent,12);                                    % initialize the data matrix
while i1<=nevent;
  i2=min(nevent,i1+nread-1);                             % read events i1 to i2
  a=fscanf(fid,'%c',nread*88);                           % read i2-i1+1 events into a
  [b,n_lines]=cut_string(a,setstr(10));
  b=reshape(a,88,n_lines)';                              % convert character vector to a matrix
  year  =sscanf(b(:,[4,05:08])' , '%f',n_lines);         % read submatrices as columns
  month =sscanf(b(:,[4,09:10])' , '%f',n_lines);
  day   =sscanf(b(:,[4,11:12])' , '%f',n_lines);
  hour  =sscanf(b(:,[4,13:14])' , '%f',n_lines);
  minute=sscanf(b(:,[4,15:16])' , '%f',n_lines);
  second=sscanf(b(:,[4,17:19])' , '%f',n_lines)/10;
  lat   =sscanf(b(:,[4,20:24])' , '%f',n_lines)/1000;
  lat   =lat.*(-2*(abs(b(:,25))==abs('S'))+1);          %multiply lat by -1 if 'S'
  lon   =sscanf(b(:,[4,26:31])' , '%f',n_lines)/1000;
  lon   =lon.*(-2*(abs(b(:,32))==abs('W'))+1);          %multiply lon by -1 if 'W'
  depth =sscanf(b(:,[4,33:35])' , '%f',n_lines);
  a=abs(b(:,37)); A=setstr((a==abs(' ')) .* (abs('0')-abs(' ')) + a);
  a=[b(:,[4,36]),A]; mb     =sscanf(a','%f',n_lines)/10;
  region=sscanf(b(:,[4,51:53])' , '%f',n_lines);
  a=abs(b(:,55)); A=setstr((a==abs(' ')) .* (abs('0')-abs(' ')) + a);
  a=[b(:,[4,54]),A]; ms     =sscanf(a','%f',n_lines)/10;
  HDF(i1:i2,:)=[year,month,day,hour,minute,second,lat,lon,depth,mb,ms,region];
  i1=i2+1;
end
fclose(fid);  % read everything into a string
HDF_KEY='year month day hour minute second lat lon depth mb ms region';
