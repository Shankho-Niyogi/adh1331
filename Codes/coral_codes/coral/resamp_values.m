function [decimate_n, interpol_n, sintr_new, err, resamp] = resamp_values(sintr, resamp);
%  resamp_values   choose interpolation and decimation factors for resamplingto common interval
% USAGE: [decimate_n, interpol_n, sintr_new, err, resamp] = resamp_values(sintr, resamp);
%
% Enter a column vector of sample intervals, and parameters to 
% decide on a new, common sample interval.
% 
% 1) Recommend a new, common sample interval.
% 2) Recomend two vectors of integers to:
%  Interpolate each seismogram by an integer factor (interpol_n) 
%  Decimate each seismogram by an integer factor (decimate_n)
%  so that the new sample intervals match the target to within
%  a given tolerance.
% 
% The new sample intervals are: 
% sintr_new = sintr .* interpol_n ./ decimate_n
% where interpol_n and decimate_n are integers
% and abs(sintr_target/sintr_new - 1) < tolerance
%  
%  Input:
% sintr               column vector of starting sample intervals (s)
% resamp.sintr_target desired common sample interval
%                     If this is set to 0 or if not entered then set the 
%                     new sample interval to the max(sintr);
%                      
% resamp.tolerance    fractional tolerance         default(.001)
% resamp.interpol_max maximum interpolation factor default(20)
% resmap.decimate_max maximum decimation factor    default (100)
% 
%  Output:
% decimate_n   (N,1)
% interpol_n   (N,1)
% sintr_new    (N,1) actual new sample intervals
% err          (N,1) sintr_new/sintr_target - 1
%                    or NaN if abs(err) >  resamp.tolerance
% resamp       as described in input parameters

% KCC 2/7/00

% initialize output arrays
sintr      = sintr(:);             % force sintr to be a column vector
n          = length(sintr);        % number of seismograms
interpol_n = ones(size(sintr));    % interpolate by this integer
decimate_n = ones(size(sintr));    % decimate by this integer
sintr_new  = sintr;
err        = NaN*ones(size(sintr));%error vector

if nargin<2;
  resamp.sintr_target=0;
end

if ~strcmp(class(resamp),'struct');  % Is input parameter a structure?
  disp('Error in ''resamp_values'': second input is not a structure')
  return
end

% set default values for input parameters if they are not already set
if ~sum(strcmp('sintr_target',fieldnames(resamp)));
  resamp.sintr_target = 0;
end
if ~sum(strcmp('tolerance',fieldnames(resamp)));
  resamp.tolerance = .001;
end
if ~sum(strcmp('interpol_max',fieldnames(resamp)));
  resamp.interpol_max = 20;
end
if ~sum(strcmp('decimate_max',fieldnames(resamp)));
  resamp.decimate_max = 100;
end

% if no value is given for the target sample interval set it to the maximum sample interval.
if resamp.sintr_target==0;
  resamp.sintr_target = max(sintr);
end

ratio     = resamp.sintr_target ./ sintr;

err = ratio - 1;
ind = find( abs(err) > resamp.tolerance );
if length(ind)==0;  % sample intervals are already the same as the target
  return
end

a=[1:resamp.interpol_max];
b=[1:resamp.decimate_max];

r=a'*(1./b);  % matrix of trial ratios of interpolating to decimating factors
p=a'*b;       % matrix of trial products of interpolating and decimating factors

for kind=1:length(ind); % loop through cases where ratio ~= 1
  k=ind(kind);
  tmp = (abs(ratio(k)./r - 1) <= resamp.tolerance); % matrix showing which trial ratios < tolerance
  [I,J]=find(tmp);       
  if length(I)>0;         % do any trial ratios work?
	[tmp1,i]=min(I.*J);  % if so choose the one with the minimum product of interpolating and decimating factors
	interpol_n(k)=J(i);
	decimate_n(k)=I(i);
  end
end


sintr_new = sintr.*decimate_n./interpol_n;          % new sample interval
err       = sintr_new/resamp.sintr_target - 1;      % error relative to target
i         = find(abs(err)>resamp.tolerance);
if length(i)>0; err(i)=NaN; end
[sintr;sintr_new;decimate_n; interpol_n ; err*100];
