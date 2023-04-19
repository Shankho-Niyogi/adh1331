function [data, ierr] = coralFilter(data, cutoffFreq, type, order, phase);
%   coralFilter    apply Butterworth filter to data in coral structure
% USAGE: [data, ierr] = coralFilter(data, cutoffFreq, type, order, phase);
%
% Apply Butterworth filter to data in coral structure and write this action into recLog
% See coral for explanation of data structure
%
% INPUT parameters
%
% data   is a coral structure that must contain the fields data, recSampInt and recLog
%
% cutoffFreq is the cutoff (3 db) frequency for the filter
%        should be one frequency for low pass and high pass filters
%        and two frequencies (row vector) for bandpass bandstop filters
%
% type   'low', 'high', 'bandpass' or 'stop' for lowpass, highpass, bandpass or bandstop filter
%        default 'low'
%
% order  order of butterworth filter (default 4)
%
% phase  'zero' or 'minimum' for zero phase or minimum phase filter
%        default is 'zero'
%
% INPUT parameters:
%
% data   is a coral structure, same as input except that data have been filtered
%
% ierr [Nx1] vector where N is the numer of seismograms (or a scalar)
%      = 0 if no errors
%      = 1 if no data are available for a given seismogram
%      = 2 if data are not all finite for a given seismogram
%      = 3 if type is not a character string starting with l, h, or s
%      = 4 if cutoffFreq is not a scalar (type 'l' or 'h') or a 2x1 vector for type 's'
%      = 5 if phase is not a character string starting with z or m
%
%
%  required fields: data, recSampInt, recLog
%
% e.g. 
% cutoffFreq = [.2 5]; type = 'bandpass'; order=2; phase='minimum';
% [data, ierr] = coralFilter(data, cutoffFreq, type, order, phase);

% K. Creager  kcc@ess.washington.edu   4/27/2004


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check that input parameters are valid and set to defaults if not entered
%
if nargin<3;
  if length(cutoffFreq)==2; type = 'bandpass';
  else                      type = 'low';
  end
end
if length(type)==0;
  if length(cutoffFreq)==2; type = 'bandpass';
  else                      type = 'low';
  end
end

if nargin<4;
  order = 4;
end
if length(order)==0;
  order = 4;
end

if nargin<5;
  phase = 'zero';
end
if length(phase)==0;
  phase = 'zero';
end


% check to see that type is valid (must be character string starting with l, h, or s

ierr=3;
if strcmp(class(type),'char');  % is it a character string?
  ierr=0;
  switch lower(type(1));  % is the first character l, h or s?
    case 'l'
      type='low';
    case 'h'
      type='high';
    case 's'
      type='stop';
    case 'b'
      type='bandpass';
    otherwise
      ierr=3;
  end
end
if ierr>0;
  disp('ERROR coralFilter: third argument must be a character string starting with l, h, b or s')
  return
end

% check to see that cutoffFreq is a number if type is 'low' or 'high' and a 2x1 vector if type is 'stop'

if strcmp(type,'low') | strcmp(type,'high');
  if length(cutoffFreq)~=1;
    disp('ERROR coralFilter: second argument must be a number')
    ierr=4;
    return
  end
end

if strcmp(type,'stop') | strcmp(type,'bandpass');
  if length(cutoffFreq)~=2;
    disp('ERROR coralFilter: second argument must be a 1x2 vector')
    ierr=4;
    return
  end
end

% check to see that phase is valid (must be character string starting with z or m

ierr=5;
if strcmp(class(phase),'char');  % is it a character string?
  ierr=0;
  switch lower(phase(1));  % is the first character z or m?
    case 'z';
      phase='zero';
    case 'm';
      phase='minimum';
    otherwise
      ierr=5;
  end
end
if ierr>0;
  disp('ERROR coralFilter: fifth argument must be a character string starting with z or m')
  return
end

% Done checking input parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ndata = length(data);
ierr  = zeros(ndata,1);

for idata = 1 : ndata;             % loop over seismograms
  temp_data = data(idata).data;    % seismogram
  if length(temp_data)>0;
    Wn    = 2*cutoffFreq*data(idata).recSampInt;  % normalized frequencies
    if max(Wn<1) & min(Wn>0); % if cutoffFreq is between 0 and Nyquist apply the filter
      [b,a] = butter(order, 2*cutoffFreq*data(idata).recSampInt, type); % calculate coefficients for Butterworth filter
      if strcmp(phase,'zero');
        temp_data = filtfilt(b,a,temp_data);  % apply zero-phase filter
      else
        temp_data = filter(b,a,temp_data);    % apply minimum-phase filter
      end
      if isfinite(temp_data);        % if filtered data are all finite then save them
        data(idata).data   = temp_data;
        cutoffStr=num2str(cutoffFreq(1)); 
        if length(cutoffFreq)==2; cutoffStr=[cutoffStr ' ' num2str(cutoffFreq(2))]; end
        data(idata).recLog = sprintf('%s filter %s %s %d %s;', data(idata).recLog, type, cutoffStr, order, phase);
      else
        ierr(idata)=2;
      end
    else
      ierr(idata)=3;
    end
  else
    ierr(idata)=1;
  end
end