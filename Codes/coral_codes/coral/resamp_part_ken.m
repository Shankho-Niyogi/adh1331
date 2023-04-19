function [data, header, options] = resamp_part(data, header, options);
%   resam         resample seismograms to same sample interval
% usage: [data, header,options] = resamp_part(data, header,options);
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
% factors for each seismogram
%  see resamp_values for code and description of further options
%  to define the sample intervals
%  Resampling is done by first interpolating by an integer factor,
% then decimating by an integer factor.
% see the matlab routines decimate and interp for details on the 
% filtering 

% KCC 2/7/00

sintr     = header(6,:); % old sample intervals (s)

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
% the time of the first non-zero sample will always stay the sam, but the time of the last sample may change
% try to preserve the relative times as well

keyboard
ratio              = decimate_n./interpol_n;
indx               = find(ratio~=1); % index to data that needs to be resampled
sintrnew           = sintr.*ratio;
[n,m]              = size(data);
[istartold,iendold]= find_nonzero(header); % old pointers
time_offsetold     = (istartold-1).*sintr; % old time offset to first non-zero sample
istartnew          = round(time_offsetold./sintrnew) + 1; % new index to first sample
istartnew          = max(istartnew,1);                    % keep arrays in bounds
iendnew            = iendold;                      % initialize to same as before and change below as needed
time_offsetnew     = (istartnew-1).*sintrnew;      % new time offsets (as close as possible to old ones)

for k = 1:length(indx);  % loop through data that needs resampling
  INDX      = indx(k);
  index     = istartold(INDX):iendold(INDX);
  temp_data = data(index,INDX);  % old data
  if interpol_n(INDX)>1;
    temp_data = interp(temp_data, interpol_n(INDX));  % interpolate
  end
  if decimate_n(INDX)>1;
    temp_data = decimate(temp_data, decimate_n(INDX));  % decimate
  end
  len_temp = length(temp_data);
  iendnew(INDX) = istartnew(INDX) + len_temp-1;
  index      = istartnew(INDX):iendnew(INDX);
  data(:,INDX) = 0;
  data(index,INDX)=temp_data;
end  


% remove extra bits from right side of data matrix
[n,m]=size(data);     % n is number size of data matrix
N = max(iendnew);     % N is largest real data sample
if N<n; 
  data=data(1:N,:);   % remove unnecessary samples from right side of matrix
  n=N;
end

% reset header to match new data matrix
header(6,:)=header(6,:).*ratio;                          % reset sample interval
header(1,:)=header(1,:)+time_offsetold-time_offsetnew;   % reset time of first sample
header(2,:)=(n-1)*header(6,:);  % reset duration  of time series
header(3,:)=time_offsetnew;
header(4,:)=(iendnew-istartnew-1).*header(6,:);

%column 1:       time (s) of first sample relative to event origin time
%column 2:       duration of time series (s)
%column 3:       time (s) of first non-zero sample relative to time of first sample
%column 4:       time (s) of last non-zero sample relative to time of first sample
%column 5:       index from columns of D1 to columns of D0
%column 6:       sample interval (s)

if ~sum(strcmp('sintr_target ',fieldnames(options)));
  options.sintr_target = median(header(6,:));
end
if ~sum(strcmp('tolerance',fieldnames(options)));
  options.tolerance = 0.001;
end

options.sintr_err = header(6,:)./options.sintr_target - 1;
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
