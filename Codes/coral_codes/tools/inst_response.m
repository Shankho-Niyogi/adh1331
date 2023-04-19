function [transfer,resp,f,t]=inst_response(Calib,key,ff,tt,plot_key);
%   inst_response compute impulse response and transfer function
% Usage: [transfer,resp,f,t]=inst_response(Calib,key,ff,tt,plot_key);
%
% Convert poles and zeros of transfer function to polynomial coefficients, 
% and calculate the amplitude and phase response, and the impulse response.
% Calib(1)    = normalization
% Calib(2)    = meands (gain)
% Calib(3)    = number of poles
% Calib(4:32) = complex poles
% Calib(33)   = number of zeros
% Calib(34:62)= complex zeros
%
% NOTE:  Gain is not included in these calculations, but normalization is.
%
% Calculate transfer function only if length(ff)>0
% Calculate instrument response only if length(tt)>0
%
%INPUT PARAMETERS:
% Calib(62xN) = complex array containing the poles and zeros of N instruments
% key         = use poles and zeros from the keyth column of Calib
% ff          = evaluate transfer function at the frequencies (Hz) in ff
%               if ff has 2 elements evaluate at log spacing from 10^f(1)->10^f(2)
% tt          = time duration (s) and sample interval (s/sample) of time vector 
%               for impulse response
% plot_key    = make plots if this parameters exists. pause after plot if plot_key>0
%
%OUTPUT PARAMETERS:
% transfer    = transfer function evaluated at frequencies (f)
% resp        = impulse response evaluated at times (t)
% f           = frequency vector corresponding to transfer function (Hz)
% t           = time vector corresponding to impulse response (s)

% K. Creager  kcc@geophys.washington.edu   12/30/93


norm  =Calib(1,key);
meands=Calib(2,key);
npole =real(Calib( 3,key));
nzero =real(Calib(33,key));
poles =Calib( 4:npole+ 3,key);
zeroes=Calib(34:nzero+33,key);
bb    =poly(zeroes);             % convert zeros to polynomial coefficients 
aa    =poly(poles);              % convert poles to polynomial coefficients

transfer=[]; resp=[]; t=[]; f=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           calculate transfer function               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(ff)>0,
  % specify the frequencies at which transfer function is evaluated
  if length(ff)==2,
    f=logspace(ff(1),ff(2));
  else
    f=ff;
  end
  w=2*pi*f;
  w(find(w==0))=eps;
  transfer=freqs(bb,aa,w)*norm;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          calculate impulse response                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(tt)>0,
  sintr=tt(2);                    % sample interval
  n=floor(tt(1)/sintr);           % number of time points
  n=n+rem(n,2);                   % force n to be even
  n2=n/2;
  tstart=sintr*(1-n2);            % time of first sample
  d=zeros(n,1);                   % d is a delta function at time=0
  d(n2)=1/sintr;
  [D,f1,t]=ft(d,n,tstart,sintr);  % fourier transform of delta function
  resp=real(ift(D.*freqs(bb,aa,2*pi*f1)*norm,n,tstart,sintr)); % inv trans
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               plot results                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==5,                      % make plots only if a fifth argument exists
  if length(ff)>0,                 % plot transfer function
    mag=abs(transfer); phase=angle(transfer); 
    hold off
    clf
    subplot(2,1,1)
%   for velocity response plot mag./(2*pi*f) and phase-pi/2 + 2*pi (I think)
    loglog(f,mag);xlabel('frequency (Hz)');ylabel('amplitude');
    grid;title('transfer function for displacement')
    subplot(2,1,2)
    semilogx(f,unwrap(phase));xlabel('frequency (Hz)');ylabel('phase (rad)');
    grid;title('transfer function for displacement')
    if plot_key>0, disp('push any key to continue');pause;end
  end
  if length(tt)>0,                  % plot impulse response
    clf
    subplot(1,1,1)
    plot(t,resp);xlabel('time (s)'); title(' Displacement response to unit impulse at t=0 ');
  end
end
