function stations=find_flipped(date);
%   find_flipped  find Alaska Seismic Network stations with wrong polarity
% USAGE: stations=find_flipped(date);
%
% read the Alaska Seismic Network station file to determine
% the names of the 'stations' which have flipped polarity
% on the date given in 'date'
% date is given as an integer in the format 19931225
% stations are given as an N,4 matrix of left justified lower-case
% names
% the station file has the format:
% station names in columns 1-4
% start and end dates for times when the station is flipped 
% appear after the station name on the same line
% modified 11-21-01 KCC for Y2K dates

[fid,message]=fopen('/u0/kcc/COL/stations_polarity','r');  % open file
if length(message)>0, disp(message'), end
S=fscanf(fid,'%c');                          % read entire file
fclose(fid);                                 % close file
[a,b]=cut_string(S,10);                      % break strings into a matrix
dates=sscanf(a(:,5:end)','%f');               % interpret all dates
dates=reshape(dates,2,length(dates)/2)';
ind=find(date>=dates(:,1) & date<=dates(:,2)); % find indices corresponding to given date
stations=left_justify(lower(a(ind,1:4)));    % list of flipped stations
