function [data, ierr, options] = coralResample(data, options);
%   coralResample    resample seismograms in coral structure
% usage: [data, ierr, options] = coralResample(data, options);
%
%  defalut (only 1 input) is to resample all seismograms to the largest 
%  sample interval among all the seismograms.
%
%  if options.sintr_target exists and is a number, then all seismograms will
%  be resampled to this sample interval
%
%  if options.interpol_n and/or options.decimate_n exist and are vectors of 
%  positive integers, they specify the interpolation and/or decimation factors 
%  for each seismogram
%
%  see resamp_values for code and description of further options
%  to define the sample intervals
%  Resampling is done by first interpolating by an integer factor,
%  then decimating by an integer factor using the matlab routine 
%  resample from the signal processing toolbox.
%
% input:
%  options.tolerance = fractional variability in sample intervals (.001 by default)
%
% output:
%  options.sintr_err = fractional errors in sample intervals
%  options.same_sintr= 0:all the same; 1:otherwise
%
% ierr [Nx1] vector where N is the numer of seismograms
%      = 0 if no errors
%      = 1 if no data are available 
%      = 2 if  data are not all finite
%      = 3,4,5 errors in the options structure specifying the desired interpolation/decimation
%
% required fields: data, recLog, recSampInt, recNumData
% See coral for explanation of structures data, data
%
% K. Creager  kcc@ess.washington.edu   2/17/2004

% KCC 2/7/00
% Bug Fix 7/20/01 KCC 
% Modified to fix timing 2/16/04 KCC

% check for errors
ndata = length(data);
ierr  = zeros(ndata,1);

sintr = [data.recSampInt]; % old sample intervals (s)

if nargin<2;  % if no values given, calculate default values to determine sample intervals;

  [decimate_n, interpol_n, sintrnew, err, options] = resamp_values(sintr);

else
  
  if ~strcmp(class(options),'struct');  % Is input parameter a structure?
    disp('Error in ''coralResample'': second input argument is not a structure')
    ierr(:)=3;
    return
  end
  % if explitic decimation and interpolation factors are given, use them, 
  % otherwise pass the options onto 'resamp_values' to calculate these factors
  if sum(strcmp('interpol_n',fieldnames(options))) & sum(strcmp('decimate_n',fieldnames(options)));
    interpol_n = options.interpol_n;
	  decimate_n = options.decimate_n;
  else
    [decimate_n, interpol_n, sintrnew, err, options] = resamp_values(sintr,options);
  end
  
end

% check for errors
decimate_n=decimate_n(:)';
interpol_n=interpol_n(:)';

if length(decimate_n)~=length(sintr) | length(interpol_n)~=length(sintr);
  ierr(:)=3;
  disp(sprintf('Error in coralResample: number of seismograms %d, interpolation %d and decimations %d factors must match', ...
	  length(sintr), length(interpol_n), length(decimate_n)))
  return
end

tmp = find(decimate_n~=round(decimate_n) | decimate_n<=0);
if length(tmp)> 0; 
  ierr(tmp)=4; 
  disp(sprintf('Error in coralResample: decimation factors not positive integers %f',decimate_n))
  return
end

tmp = find(interpol_n~=round(interpol_n) | interpol_n<=0); 
if length(tmp)> 0; 
  ierr(tmp)=5; 
  disp(sprintf('Error in coralResample: interpolation factors not positive integers %f',interpol_n))
  return
end

% if no errors then go on

% resample each time series.  
% the time of the first sample will always remain the same, but the time of the last sample may change

ratio              = decimate_n./interpol_n;
indx               = find(ratio~=1); % index to data that needs to be resampled
sintrnew           = sintr.*ratio;
for k = 1:length(indx);  % loop through data that needs resampling
  idata     = indx(k);
  temp_data = data(idata).data;    
  if length(temp_data)>0;
    temp_data = resample(temp_data, interpol_n(idata), decimate_n(idata));
    if length(temp_data)>0;
      if isfinite(sum(temp_data));
        data(idata).data       = temp_data;
        data(idata).recSampInt = sintrnew(idata);
        data(idata).recLog     = sprintf('%sresamp %d/%d;',data(idata).recLog,decimate_n(idata),interpol_n(idata));
        data(idata).recNumData = length(data(idata).data);
      else
        ierr(idata)=2;
      end
    else
      ierr(idata)=1;
    end
  else
    ierr(idata)=1;
  end

end  

% if the sample interval target was not input, determine its value from the resampled data
if ~sum(strcmp('sintr_target ',fieldnames(options)));
  options.sintr_target = median([data.recSampInt]);
end

% set the tolerance for fractional differences in sample intervals
if ~sum(strcmp('tolerance',fieldnames(options)));
  options.tolerance = 0.001;
end

options.sintr_err = [data.recSampInt]./options.sintr_target - 1;
if sum(abs(options.sintr_err) < options.tolerance);
  options.same_sintr = 1;
else
  options.same_sintr = 0;
end

if length(indx)>0;
  disp('Resampled the following seismograms (index:decimate/interpolate)')
  disp(sprintf('  %d:%d/%d',[indx',decimate_n(indx)',interpol_n(indx)']'));
  if options.same_sintr == 0;
	ind = find ( abs(options.sintr_err) < options.tolerance );
	disp(sprintf('Target sample interval is: %7.3f, the following seismograms do not match: (index, sampleinterval)',...
											 options.sintr_target))
	disp(sprintf('  %d:%7.3f',[ind',newsintr(ind)']'))
  end
end
