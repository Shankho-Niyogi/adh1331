function [g,f,t]=ift(G,n,tstart,dt);
%   ift           Inverse Fourier Transform, time shifts, sample interval scaling
% USAGE: [g,f,t]=ift(G,n,tstart,dt);
% Compute the Inverse Fourier Transform of G(f) and order the output to match
% a time vector that starts at tstart and has a sample interval of dt.
% n is the length of the time vector and of g.  An N point IFFT is calculated 
% where N is the length of G.  Output is scaled according to the conventions of 
% continuous transforms in Aki and Richards and in J.H. Karl.
%
% INPUT: G is a column vector spectrum evaluated at positive and negative
%        frequencies as defined by MAKE_FREQ. 
%        tstart, dt and n define the output time vector as described above.
%
% OUTPUT: g is the Inverse Fourier Transform of G.  it is scaled by dt to be 
%        consistent with the continuous transform.  the time shift
%        theorem has been used to account for time not starting at t=0.
%        f and t are the time and frequency vectors for g and G.
%        the lengths of g and t are n.
%
% See also FT, and MAKE_FREQ.

% K. Creager  kcc@geophys.washington.edu   12/30/93

G=G(:);                         % force G to be a column vector
N=length(G);                    % length of input time-domain vector
t=tstart(1)+[0:dt:(n-1)*dt]';   % time vector

f=make_freq(N,dt);

g=1/dt*ifft(G.*exp(2*pi*i*tstart*f)); % inverse fourier transform with time shift
g=g(1:n);                             %truncate time vector to n points.
