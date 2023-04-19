function [data, header, options] = STresamp_part(data, header, options);
%   resam         resample seismograms to same sample interval
% usage: [data, header,options] = STresamp_part(data, header,options);
%
%  test  the sample intervals of all of the traces in the data matrix
%  and, if they are different, resample the data matrix so that
%  all of the traces have the same sample interval
%
%  using the options structure, many options are available 
%  the default (do not enter the options input argument)
%  is to resample to the largest sample interval among all the traces.
%  options.sintr_target  can be set, and this will by used as the
%  common sample interval
%  options.interpol_n, options.decimate_n can be defined as a
%  set of row vectors to specity the interpolation and decimation
%  factors for each seismogram
%  see resamp_values for code and description of further options
%  to define the sample intervals
%  Resampling is done by first interpolating by an integer factor,
%  then decimating by an integer factor.
%  see the matlab routines decimate and interp for details on the 
%  filtering 
%  NOTE:  This version uses a modified versino of decimate (STdecimate) which
%  aligns the inout and output time seties on the first sample.  The matlab
%  supplied code aligns time series on the last data sample.

% KCC 2/7/00
% Bug Fix 7/20/01 KCC 
% Modified to fix timing 2/16/04 KCC

sintr     = [data.recSampInt]; % old sample intervals (s)

if nargin<3;  % if no values given, calculate default values to determine sample intervals;

  [decimate_n, interpol_n, sintrnew, err, options] = resamp_values(sintr);

else
  
  if ~strcmp(class(options),'struct');  % Is input parameter a structure?
    disp('Error in ''resamp_part'': third input argument is not a structure')
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
ierr=0;
decimate_n=decimate_n(:)';
interpol_n=interpol_n(:)';
tmp = find(decimate_n~=round(decimate_n) | decimate_n<=0); 
if length(tmp)> 0; 
  ierr=1; 
  disp(sprintf('Error in resamp_part: decimation factors not positive integers %f',decimate_n))
end
tmp = find(interpol_n~=round(interpol_n) | interpol_n<=0); 
if length(tmp)> 0; 
  ierr=2; 
  disp(sprintf('Error in resamp_part: interpolation factors not positive integers %f',interpol_n))
end
if length(decimate_n)~=length(sintr) | length(interpol_n)~=length(sintr);
  ierr=3;
  disp(sprintf('Error in resamp_part: number of seismograms %d, interpolation %d and decimations %d factors must match', ...
	  length(sintr), length(interpol_n), length(decimate_n)))
end

options.ierr=ierr;

if ierr>0;
  return
end

% if no errors then go on

% if sample intervals are an integer ratio of each other, decimate, 
% othersise, first interpolate, then decimate

% resample the time series.  
% in general the sample interval will change
% the time of the first non-zero sample will always stay the same, but the time of the last sample may change
% try to preserve the relative times as well


ratio              = decimate_n./interpol_n;
indx               = find(ratio~=1); % index to data that needs to be resampled
sintrnew           = sintr.*ratio;
for k = 1:length(indx);  % loop through data that needs resampling
  INDX      = indx(k);
  temp_data = data(INDX).data;   % old data
  if interpol_n(INDX)>1;
    temp_data = interp(temp_data, interpol_n(INDX));  % interpolate
  end
  if decimate_n(INDX)>1;
    %if INDX==60; keyboard; end  ; % use filter order = min(8,floor((langth(temp_data)-1)/3))
    temp_data = STdecimate(temp_data, decimate_n(INDX));  % decimate
 %  DT      = data(INDX).recSampInt / interpol_n(INDX);
 %   NumSamp = length(temp_data);
 %   data(INDX).recStartTime = timeadd(data(INDX).recStartTime', mod(NumSamp-1,decimate_n(INDX)) * DT)';
  end
  data(INDX).data       = temp_data;
  data(INDX).recSampInt = sintrnew(INDX);
end  

if ~sum(strcmp('sintr_target ',fieldnames(options)));
  options.sintr_target = median([data.recSampInt]);
end
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
