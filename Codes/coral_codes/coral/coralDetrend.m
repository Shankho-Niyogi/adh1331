function [data, ierr] = coralDetrend(data);
%   coralDetrend   remove trend (line) from data in coral structure
% USAGE: [data, ierr] = coralDetrend(data);
%
% Remove the trend from each seismogram and write this action into recLog
% See coral for explanation of data structure
% ierr [Nx1] vector where N is the numer of seismograms
%      = 0 if no errors
%      = 1 if no data are available 
%      = 2 if  data are not all finite
%
%  required fields: data, recLog
%
% K. Creager  kcc@ess.washington.edu   2/17/2004

ndata = length(data);
ierr  = zeros(ndata,1);

for idata = 1 : ndata;             % loop over seismograms
  temp_data = data(idata).data;    
  if length(temp_data)>0;
    temp_data = detrend(temp_data);
    if isfinite(temp_data(1));        
      data(idata).data   = temp_data;
      data(idata).recLog = [data(idata).recLog 'tren;'];
    else
      ierr(idata)=2;
    end
  else
    ierr(idata)=1;
  end
end