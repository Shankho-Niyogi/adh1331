function sta_index=findsta(filenames,station);
%   findsta       find station name from list
% USAGE: sta_index=findsta(filenames);
% station must be four characters, ie. col is 'col_'
% find a station in list
% Use 'run' to make the filename list called filenames
% then run this routine
[N,M]=size(filenames);test=zeros(N,1);
for i=1:N,test(i)=strcmp(filenames(i,23:26),station);end
sta_index=find(test==1);

