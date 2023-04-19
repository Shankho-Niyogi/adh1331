function [data, ierr] = coralEnvelope(data);
%   coralEnvelope  make an envelope of data in coral structure
% USAGE: [data, ierr] = coralEnvelope(data);
%
% Make an Envelope of data for each seismogram and write this action into recLog
% The evelope is the square root of the data squared plus it's hilbert transform squared
% For example the envelope of a sine wave is a constant function equal to it's amplitude
% See coral for explanation of data structure
% ierr [Nx1] vector where N is the numer of seismograms
%      = 0 if no errors
%      = 1 if no data are available 
%      = 2 if  data are not all finite
%
%  required fields: data, recLog
%
% K. Creager  kcc@ess.washington.edu   4/28/2006

ndata = length(data);
ierr  = zeros(ndata,1);

for idata = 1 : ndata;             % loop over seismograms
  temp_data = data(idata).data;    
  if length(temp_data)>0;
    if all(isfinite(temp_data));        % if all data are finite
      data(idata).data   = sqrt(hilbert_trans(temp_data).^2 + temp_data.^2);      % calculate envelope function
      data(idata).recLog = [data(idata).recLog 'envelope;'];
    else
      ierr(idata)=2;
    end
  else
    ierr(idata)=1;
  end
end