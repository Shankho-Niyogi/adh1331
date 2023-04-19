function [Data, DataStart, DataStop, StartTime, StartDate, SamIntr]= ...
coral2afids(data,header,Loc);
%   coral2afids   convert coral format to afids format
%USAGE: [Data, DataStart, DataStop, StartTime, StartDate, SamIntr]= ...
%       coral2afids(data,header,Loc);
%
%  The output arrays contain the information needed to define N time series
%  where DataStart, DataStop, StartTime, StartDate, SamIntr are 1xN column 
%  vectors and Data is a row vector containing all the time series.
%
%     INPUT VECTORS  (See coral.man for further information)
%  data      is a matrix containing the data
%  header    is a matrix containing the header information
%  Loc       is a matrix containing the earthquake origin time
%
%     OUTPUT VECTORS
%  Data      is row vector containing one or more data streams
%  DataStart are the indices in Data corresponding to the start points
%  DataStop  are the indices in Data corresponding to the stop points
%  StartTime are the absolute time of day of the first samples
%  StartDate are the absolute dates of the first samples
%  SamIntr   are the sample intervals (s)

SamIntr=header(6,:)';
w_index=header(5,:)';
OriginDateTime=Loc(7:8,w_index);
StartDateTime=timeadd(OriginDateTime, header(1,:));
StartDate=StartDateTime(1,:)';
StartTime=StartDateTime(2,:)';

% reformat the data
[n,m]=size(data);
[istart,iend]=find_nonzero(header);
duration=iend-istart+1;
DataStop=cumsum(duration)';
DataStart=[1; DataStop(1:m-1)+1];
Data=zeros(1,sum(duration));
for i=1:m
  index  = istart(i):iend(i);
  Data(DataStart(i):DataStop(i)) = data(index,i); 
end;
