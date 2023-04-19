function data=butter_filt(data,sintr,cutoffPeriod,order,passOpt,filtType);
%   filt_butter   butterworth filter
% USAGE: data=butter_filt(data,sintr,cutoffPeriod,order,passOpt,filtType);
%
%   Input Parameters
% data          is matrix of data (time series are in columns)
% sintr         is vector of sample intervals (s) 
% cutoffPeriod  is filter cut off period (s)
% order         is order of filter (default is 8)
% passOpt       is 0 for low pass, 1 for high pass (default is 0)
% filtType      is 0 for zero-phase filter, 1 for causal filter (default is 0)
%
%   Output Parameter
% data          is matrix of filtered data

if nargin<6, filtType=0; end,        % default filter type is zero-phase
if nargin<5, passOpt =0; end,        % default is a low pass filter
if nargin<4, order   =8; end,        % default filter order is 8


cutoffFreq = sintr ./ cutoffPeriod;
[dataR,dataC] = size(data);
for i = 1:dataC,
  if passOpt == 0                         % lowpass or bandpass
    [b,a] = butter(order, 2*cutoffFreq(i));
  elseif passOpt == 1                     % highpass
    [b,a] = butter(order, 2*cutoffFreq(i),'high');
  elseif passOpt == 2                     % bandstop
    [b,a] = butter(order, 2*cutoffFreq(i),'stop');
  end
 
  if filtType == 0        % zero-phase filter
    data(:,i) = filtfilt(b,a,data(:,i));
  else
    data(:,i) = filter(b,a,data(:,i));
  end
end


