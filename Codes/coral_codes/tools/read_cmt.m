function [M,M_KEY]=read_cmt(file_name);
%   read_cmt      read Harvard CMT Catalog in Harvard 4-line ascii format
% USAGE: [M,M_KEY]=read_cmt(file_name);
% file_name is as ascii string containing the catalog file name
% eg. file_name='/extra/archive/seis/harvard.cmt.dek';

tic;
%  read in the whole file as a character string
fid=fopen(file_name);
a=fscanf(fid,'%c');
fclose(fid);  % read everything into a string
 
% If file is empty return with an error message
if length(a)==0,
  disp(['WARNING: cmt file is empty.  file_name=' file_name])
  M=[];
  M_KEY=[];
  return
end

% make a mask to extract desired numbers from date/time row 
% with all numbers separated by blanks
ii=[10:49 9 50:52 9 53:55];ii(3:3:15)=[9 9 9 9 9]; 

toc,tic
i=find(abs(a)==10);                          % find the line feeds
i=i(:); i=[0;i];
nevent=floor(length(i)/4);
M=zeros(nevent,23);
% loop thru each event pulling out the values specified in M_KEY
for j=1:nevent
  i1=(j-1)*4+1;
  b=a(i(i1)+1:i(i1+1)-1);
  i1=i1+2;
  c=[b(ii) a(i(i1)+12:i(i1+1)-1)];
  x=sscanf(c,'%f',24);
  y=x(13:24)*10^x(12);
  M(j,:)=[x([3 1 2 4:11]) ; y]';
end
M_KEY='EventYear EventMonth EventDay EventHour EventMinute EventSecond EventLatitude EventLongitude EventDepth Ms Mb Mrr MrrError Mss MssError Mee MeeError Mrs MrsError Mre MreError Mse MseError';
toc
