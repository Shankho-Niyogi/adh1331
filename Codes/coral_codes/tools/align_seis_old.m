function [data1, header1,label1,obs1]=align_seis(data1,time_window,header1,...
	label1,obs1,wind_width,iflag);
%   align_seis    align coral seismograms by cross correlation or trace extrema
% USAGE: [data1, header1,label1,obs1]=align_seis(data1,time_window,header1,...
%       label1,obs1,wind_width,iflag);
%
%  Coral function to align all of the traces on the maximum value of the traces
%    (iflag==1), or on the minimum value of the traces (iflag==2),
%    or by cross correlation (iflag==3).  For the later case the traces are
%    stacked (without normalizing) and each trace is cross correlated with
%    the stack to determine the time shift.

t=1:length(data1(:,1)); t=t*header1(6,1) + wind_width(1);
if time_window(1) < min(t) time_window(1) = min(t); end;
if time_window(2) > max(t) time_window(2) = max (t); end;
[trash, place1] = min(abs(t - time_window(1)));
[trash, place2] = min(abs(t - time_window(2)));
data = data1(place1:place2,:);

if     iflag==3,                         % use cross correlation
  
  beam=sum(data');
  [A,B]=size(data);
  C=zeros(1,B);
  timeshift=zeros(1,B);
  for i=1:B

    correl = xcorr(beam,data(:,i),'coeff');
    [C(i),timeshift(i)] = max(correl);
  end

elseif iflag==2,                          % use minumum
  [a,timeshift]=min(data);

else,                                     % use maximum
  [a,timeshift]=max(data);
end

timeshift=timeshift.*header1(6,:);
del_t=demean(timeshift')
Tdur=header1(2,:);
window=[del_t';Tdur;(1:length(Tdur))];
obs1(1,:)=header1(1,:)+del_t';
obs1(1,:)=obs1(1,:) - mean(obs1(1,:)-header1(9,:)); % differential travel time (s)
obs1(2,:)=obs1(1,:) - header1(9,:);               % differential travel time residual (s)
[data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1,window);
