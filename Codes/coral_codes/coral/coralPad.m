function data = coralPad(data);
%   coralPad      zero pad data in coral structure so all data have the same length
% USAGE: [data, ierr] = coralPad(data, opt);
%
% Pad the end of the seismograms as necessary so that  all 
% seismograms have the same length
% See coral for explanation of data structure
%
%  required data fields: data, ,recNumData, recLog
%
% K. Creager  kcc@ess.washington.edu   4/13/2005

ndata      = length(data);                % number of seismograms
NumData    = [data.recNumData];           % number of samples in each seismogram
maxNumData = max(NumData);                % length of longest seismogram
nPad       = maxNumData-NumData;          % number of zeros to add to the end of each seismogram
indx       = find(nPad>0);                % indices to seismograms that need to be padded
for i = 1 : length(indx);                 % loop over seismograms that need padding
  idata   = indx(i);                      % index of a seismogram needs padding
  data(idata).data(NumData(idata)+[1:nPad(idata)])=0;  % pad seismogram at end with zeros
  data(idata).recNumData = length(data(idata).data);
  data(idata).recLog = sprintf('%scoralPad;',data(idata).recLog);
end