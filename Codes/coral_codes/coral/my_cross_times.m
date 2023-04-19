function [tlag, ccval, cc_times, cc, lag_array, xcor_array, n_idx] = ...
          my_cross_times(data, srate, flag, ref_trace);
%   my_cross_times  cross correlate coral data
% USAGE: [tlag, ccval, cc_times, cc, lag_array, xcor_array, n_idx] = ...
%         cross_times(data, srate, flag, ref_trace);
%
% Input parameters:
%  data is the data matrix of traces to be correlated (stored in
%  column matrix form).  srate is the sample interval (s) which must be 
%  the same for all traces.
%  flag specifies which time of maxima to search for (default is 1):
%                 flag > 0       ->      only positive peaks will be found
%                 flag = 0       ->      both positive and negative peaks
%                 flag < 0       ->      only negative peaks will be found
%  ref_trace is the trace number for a reference trace (cross correlate all
%            seismograms with respect to this trace.  If ref_trace=0, which
%            is the default, cross correlate all traces in pairs.
% 
% Output parameters: 
%  tlag   vector of lag times (s) (one time per trace)
%  ccval  vector of cross correlation values evaluated at lag times (tlag)
%  cc     matrix of cross-correlograms of pairs of traces (auto correlations removed)
%  lag_array   vector of lag times for all maxima 
%  xcor_array  vector of cross correlation values at lag times (lag_array)

if nargin < 3, flag      = 1; end
if nargin < 4, ref_trace = 0; end

d = data;
[n,m]=size(d);
[ccc,tt]=my_xcor(d,srate,[0,0],ref_trace);        % cross correlate
nn=size(ccc(:,1));
t=srate(1)*[-n/2:1:n/2-1]';
if rem(n,2)~=0;                        % truncate to form cc for plotting
  t=t+srate(1)/2;
  indstart=(nn+2)/4+1;
else
  indstart=nn/4+1;
end

if ref_trace==0,
  cc_idx = cc_rm_diag(m);
else
  cc_idx=[1:m];
end

cc = ccc([indstart:1:indstart+n-1],cc_idx);
[ncc,mcc] = size(cc);

% truncate cc to ignore maxima w/in 2 of end points (cannot fit these) by only
%  passing cc(2:(ncc-2),i) to the find_max_idx function...

N=size(cc,2);
for i = 1:N
  [temp_idx,tempn] = find_max_idx(cc(:,i), flag);
  if i==1,
    cc_max_idx = temp_idx;
    n_idx = 1;
    n_idx = [n_idx, (tempn + n_idx(length(n_idx)))];
  else
    cc_max_idx = [cc_max_idx; temp_idx];
    if i<N
      n_idx = [n_idx, (tempn + n_idx(length(n_idx)))];
    end
  end
end

% initialize some vectors...

xcor_array = [];
lag_array = [];
lagvec = [];
ccvec = [];
ccval = [];
tlag = [];

% for each of cross-correlograms, fit points around all of peaks in correlogram
%  to determine best-fit actual peak and peak time

new_n_idx = [n_idx, (length(cc_max_idx) + 1)];
for j = 1:length(n_idx),                          % loop over all cross correlograms
  lagvec = [];
  ccvec = [];
  for k = new_n_idx(j):(new_n_idx(j+1)-1),        % loop over all local maxima 
    [k,cc_max_idx(k)];
    ind=[-1 0 1]+cc_max_idx(k);
    p=polyfit(t(ind),cc(ind,j),2);                % fit a parabola to 3 points near max
    tempt=-p(2)/(2*p(1));                         % find time at max of parabola
    tempc=polyval(p,tempt);                       % find correlation coeff at max of parabola
    lagvec = [lagvec; tempt];                     % keep track of all local maxima for this correlogram
    ccvec = [ccvec; tempc];
  end;
  [tempval, tempidx] = max(ccvec);                % find global maximum of cross correlograms
  ccval = [ccval, tempval];
  templag = lagvec(tempidx);
  tlag = [tlag, templag];
  xcor_array = [xcor_array; ccvec];
  lag_array = [lag_array; lagvec];
end;
cc_times = t;
