function [max_idx, nmax, maxima_idx, maxima] = find_max_idx(in_vec, flag);
%   find_max      return indices of all local maxima of a vector
% USAGE: [max_idx, nmax, maxima_idx, maxima] = find_max_idx(in_vec, flag);
%
% Input parameters:
%  in_vec is a vector
%  if flag > 0, return all local maxima of in_vec (default)
%          < 0, return all local minuma of in_vec
%          = 0, return all local extrama of in_vec
%  
% Output paramaters:
%  max_idx    column vector of indices of extrema
%  nmax       number of extrema found
%  maxima_idx fractional index of local extrama found by 
%             fitting a parabola to nearest points to extrema
%  maxima     extrema found for each point found by 
%             fitting a parabola to nearest points to extrema
%
% modified to properly find extrema PB 2/22/99
% modified to correct indices which were off by one KCC 2/22/99

if nargin < 2, flag = 1; end;

in_vec = in_vec(:);    % force in_vec to be a column vector

temp1  = in_vec(1:end-1);
temp2  = in_vec(2:end);

% local maxima are where slope is positive for the first sequence and
% negative for the second.  the opposite is true for local minima.

maxvec = [diff(temp1)] > 0 & [diff(temp2) < 0];  % maxima
minvec = [diff(temp1)] < 0 & [diff(temp2) > 0];  % minima

if     flag>0,  max_idx = find(maxvec);
elseif flag<0,  max_idx = find(minvec);
elseif flag==0, max_idx = find(maxvec + minvec);
end

max_idx = max_idx+1;      % indices are all off by one
nmax = length(max_idx);   % number of extrema

if nargout>2,  % fit parabolas to each of the extrema to find 
               % find better approximations to the extrema

  t=[-1 0 1]';
  maxima     = zeros(nmax,1);         % initialize output vectors
  maxima_idx = zeros(nmax,1);

  for k = 1:nmax;
    ind = t + max_idx(k);
    p   = polyfit(t,in_vec(ind),2);   % fit a parabola to 3 points near each extrema
    temp = -p(2)/(2*p(1));            % find x at extrema of parabola
    maxima(k) =polyval(p,temp);       % find the extrema 
    maxima_idx(k)=temp + max_idx(k);  % find the exact x-value of extrema
  end

end

