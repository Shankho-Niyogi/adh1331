function [data, ierr] = coralIntegrate(data);
%   coralIntegrate  integrate data in coral structure
% USAGE: [data, ierr] = coralIntegrate(data);
%
% Integrate data in each seismogram and write this action into recLog
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
    if all(isfinite(temp_data));        % if all data are finite
      data(idata).data   = cumtrapz(temp_data)*data(idata).recSampInt;      % numerical integration
      data(idata).recLog = [data(idata).recLog 'integrate;'];
    else
      ierr(idata)=2;
    end
  else
    ierr(idata)=1;
  end
end