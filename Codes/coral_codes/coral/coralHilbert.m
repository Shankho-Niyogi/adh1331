function [data, ierr] = coralHilbert(data);
%   coralHilbert  apply  Hilbert Transform to data in coral structure
% USAGE: [data, ierr] = coralHilbert(data);
%
% Hilert Transform data in each seismogram and write this action into recLog
% See coral for explanation of data structure
% ierr [Nx1] vector where N is the numer of seismograms
%      = 0 if no errors
%      = 1 if no data are available 
%      = 2 if  data are not all finite
%
%  required fields: data, recLog
%
% K. Creager  kcc@ess.washington.edu   7/26/2005

ndata = length(data);
ierr  = zeros(ndata,1);

for idata = 1 : ndata;             % loop over seismograms
  temp_data = data(idata).data;    
  if length(temp_data)>0;
    if all(isfinite(temp_data));        % if all data are finite
      data(idata).data   = hilbert_trans(temp_data);      % calculate hilbert transform
      data(idata).recLog = [data(idata).recLog 'hilbert;'];
    else
      ierr(idata)=2;
    end
  else
    ierr(idata)=1;
  end
end