function y = hilbert_trans(x);
%   hilbert_trans Hilbert Transformation
% USAGE: y = hilbert_trans(x);
%   hilbert_trans(x) is the Hilbert transform of the real part of vector x.  
%   The Hilbert transform of x reproduces x with a frequency independent
%   phase advance of pi/2.  See Aki and Richards, Quantitative Seismology, 
%   box 5.6 for a discussion of the Hilbert Transform.
%   This version uses a power of 2 FFT and IFFT.  See also HILBERT, but note 
%   that the documentation for the MATLAB program HILBERT is incorrect.  
%   HILBERT_TRANS(X)=-IMAG(HILBERT(X)) whereas the documentation for 
%   HILBERT suggests the opposite sign.
%
%       Try:t=0:100';  y=t*0;  y(50:53)=hanning(4);
%           plot(t,y,t,hilbert_trans(y))

%	Charles R. Denham, January 7, 1988.
%	Revised by LS, 11-19-88, 5-22-90.
%	Copyright (C) 1988, 1990 the MathWorks, Inc.
%	Modified to use power of 2 FFT Ken Creager  10-1-92.

n = length(x);
m = 2^ceil(log(n)/log(2));
y = fft(real(x),m);
if m ~= 1
	h = [1; 2*ones(fix((m-1)/2),1); ones(1-rem(m,2),1); zeros(fix((m-1)/2),1)];
	y(:) = y(:).*h;
end
y = ifft(y,m);
y = -imag(y(1:n));
