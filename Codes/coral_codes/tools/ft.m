function [G,f,t]=ft(g,n,tstart,dt);
%   ft            Fourier Transform with time shift and sample interval scaling
% USAGE: [G,f,t]=ft(g,n,tstart,dt);
% Compute the Fourier Transform of g(t) correcting for time offsets and sample
% interval.  Output is scaled using conventions of continuous transforms in
% Aki and Richards and in J.H. Karl.
%
% INPUT: g is a column vector time series evaluated at times specified by
%        tstart and dt.  if tstart is a vector, it is the time vector and
%        dt is not necessary. if tstart is a scalar, it is the start time 
%        and the sample interval is dt.  n is the number of points in the FFT.
%        g is truncated or zero-padded to n points.
%
% OUTPUT: G is the Fourier Transform of g.  it is scaled by dt to be 
%        consistent with the continuous transform.  the time shift
%        theorem has been used to account for time not starting at t=0.
%        the length of G is n.  
%        f is the frequency vector for G.
%        t is the time vector for g.
%
% See also IFT and MAKE_FREQ.

% K. Creager  kcc@geophys.washington.edu   12/30/93

g=g(:);                         % force g to be a column vector
N=length(g);                    % length of input time-domain vector
if length(tstart)>1             % define time vector
  t=tstart;
  tstart=t(1);
  dt=t(2)-t(1);
else
  t=tstart+[0:dt:(N-1)*dt]';    % time vector
end

if length(t)~=N, error('size of time and data vectors must be the same in FT');end

f=make_freq(n,dt);                    % construct the frequency vector

G=dt*fft(g,n).*exp(-2*pi*i*tstart*f); % forward fourier transform with time shift
