function [max_rate, srate, data] = resam(srate, data);
%   resam         resample several seismograms to same sample rates
% usage: [max_rate, srate, data] = resam(srate, data);
%
%  tests the sample rates of all of the traces in the data matrix
%  and, if they are different, resamples the data matrix so that
%  all of the traces have the same sample rate
%
%  first the ratio between the sample rates is compared to see
%  if it is an integer ratio, if so then no interpolation needs to
%  be done.  if the ratio is not an integer, then the smallest number
%  between two and the smaller sample frequency that gives an integer
%  multiple of both rates is used as an interpolating frequency, and then
%  the data vector is resampled at the smaller sample frequency...

max_rate = max(srate);
test_rate = find(srate ~= max_rate);
if length(test_rate) ~= 0,
  ratio = max_rate ./ srate(test_rate);     % largest rate to non-matching rates
  inv_rate = 1/(max_rate);                  % smallest sample frequency

% if are an integer ratio of each other, just decimate, else must interpolate
%  and then decimate...

  for k = 1:length(test_rate),
    if ratio(k) == round(ratio(k)),
      temp_data = decimate(data(:, test_rate(k)), ratio(k));
    else,
      inv_old_rate = 1/srate(test_rate(k));          % larger sample frequency
      test2 = ((2:inv_rate)*inv_old_rate)./inv_rate; % series of multiple ratios
      new_ratio = min(find(test2 == round(test2)))+1;  % interpolating ratio
      old_ratio = inv_old_rate * new_ratio / inv_rate;    % resampling ratio
      temp_data = interp(data(:, test_rate(k)), new_ratio);
      temp_data = decimate(temp_data, old_ratio);
    end;
    len_data = length(data(:, test_rate(k)));
    len_temp = length(temp_data);
    diff_len = len_temp - len_data;
    if diff_len > 0,
      data(:,test_rate(k)) = temp_data(1:len_data);
    elseif diff_len < 0,
      data(:,test_rate(k)) = [temp_data' zeros(1,-diff_len)]';
    else,
      data(:,test_rate(k)) = temp_data;
    end;
    srate(test_rate(k)) = max_rate;
  end;
  data = rm_zeropad(data);
end;
