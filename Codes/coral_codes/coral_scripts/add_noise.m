function data1 = add_noise(snr,data1)
% 
% Usage:           data1 = add_noise(snr,data1)
% in coral:   eval data1 = add_noise(snr,data1) 
%
% Note that data1 must be present
%
% Input: snr  -  a number indicating how many times the noise
%                will be lower (in amplitude) than the data1
%                trace with the greatest amplitude.
%        data1  -  standard data1 in coral
%
% Output: data1  -  noise will be added to all traces in
%                   coral's data1 array.
%
% Script essentially adds white noise, which works OK for
% short period or high frequency band-passed data but is
% not very earth-like for long period data. Use with caution.
%

for xx = 1:length(data1(1,:)),
 junk(xx) = max(abs(data1(:,xx)));
end
junk = max(abs(junk))/snr;
noise = rand(size(data1));
noise = noise -0.5;
noise = noise*junk;
data1 = noise + data1;
