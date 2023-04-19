function [r,cc]=decon1(c,s,waterlevel,a,timeshift,sintr,plt_flag);
% frequency domain waterlevel deconvolution
% USAGE: [r,cc]=decon1(c,s,waterlevel,a,timeshift,sintr,plt_flag);
% deconvolve c from s using spectral division regularized by a waterlevel
% so that c = r*s
% r(f)    = c(f).*conj(s(f)) ./ [s(f).*conj(s(f)) + gamma] .* filt(f) .* shift(f)
% gamma   = waterlevel * max(s(f).*conj(s(f))) 
% filt(f) = exp( -(f*(pi/a))^2 )
% shift(f)= exp(-j*2*pi*timeshift*f);
%
% INPUT PARAMETERS:
% c = radial component seismogram
% s = vertical component seismogram
% c and s are each real column vectors of the same dimesnion
% waterlevel (row vector or scalar) of waterlevels for regularizing spectral division
% a is a parameter for the gausian filter applied to deconvolved time series
% timeshift (s) shifts the time of the deconvolved time series
% sintr (scalar) sample interval (Hz)
% plt_flag is optional - make plots if plt_flag>0
%
% OUTPUT PARAMETERS:
% r = receiver functions (one for each value of waterlevel)
% cc= conv(r,s) for each value of water level, ideally this sould equal c

if nargin<7, plt_flag=0; end   % set plot flag to default value if necessary

n=length(c);                  % n is length of time series
m=length(waterlevel);         % m is number of waterlevels entered

if n ~= length(s),            % check dimensions on input time series
  disp(['dimensions of input arrays must be identical.  They are:'])
  disp(sprintf('%d ',[ size(c),size(s) ]))
  return
end


% compute FFT of time series: 
%  S,C     = fourier transform of vertical,radial components
%  SS,CC   = power spectra (not normalized)
%  f       = frequency (Hz)
%  maxSS   = maximum value of power of s
%  gaussfilt=gaussian filter
%  eiwt    = exp(i omega t) multiplies the frequency domain
%            receiver function (time shifts it in the time domain)

t=[0:n-1]';t=t*sintr;         % time vector
f=make_freq(n,sintr);         % frequency vector in wrap around order
S=fft(s);                     
SS=S.*conj(S);  
maxSS=max(SS);
C=fft(c);  
CC=C.*conj(C);  
CS=C.*conj(S);
gamma=maxSS*waterlevel;
gaussfilt=exp(-(f.*f*(pi*pi/(a*a))));
eiwt=exp(-j*2*pi*timeshift*f);
CSGW=CS.*gaussfilt.*eiwt;
for k=1:m;  
  r(:,k)=ifft( CSGW ./ max(SS,gamma(k)) );  
end

if nargout>1,
  for k=1:m, 
     cc(:,k)=ifft(fft(r(:,k)).*fft(s).*conj(eiwt));
     maxc=max(abs(c));maxcc=max(abs(cc(:,k)));cc(:,k)=cc(:,k)*maxc/maxcc;
  end
end

if nargin>6,
 if plt_flag>0
  % plot time series
  plot(t,s,t,c);title('z and r seismograms'); pause 
%  print
  % plot power spectra
  p0=1; p1=ceil(n/2); p2=p1;
  xplt=[f(p0) f(p1)]'; yplt(1,:)=gamma/n; yplt(2,:)=gamma/n;
  semilogy(f(p0:p1),SS(p0:p1)/n,f(p0:p2),gaussfilt(p0:p2)*maxSS/n,xplt,yplt)
%  axis([0, max(f), max(SS(p0:p1)/n), max(SS(p0:p1)/n)*(waterlevel^2)])
% axis( [0, max(f), max(SS(p0:p1)/n)*(waterlevel^2), max(SS(p0:p1)/n)] )
  title('Power spectral density of Z'), xlabel('Frequency (Hz)'), 
  xlabel('Frequency (Hz)'), pause
  semilogy(f(p0:p1),CC(p0:p1)/n)
  title('Power spectral density of R'), xlabel('Frequency (Hz)'), pause

  plot(t,r); title('receiver function'), pause
%  print 
  plot(t,c,t,cc);title('receiver function prediction')
 end
end
