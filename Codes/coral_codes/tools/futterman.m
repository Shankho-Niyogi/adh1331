function [FUTTER,t]=futterman(tstar,tt,f0,instrument,plt_flag);
%   futterman     Futterman Filter Attenuation Operator
% Usage: [FUTTER,t]=futterman(tstar,tt,f0,instrument,plt_flag);
% Calculate the displacement response for a unit delta function input, 
% convolved with a Futterman Filter attenuation operator for a set of 
% values of tstar, and convolved with an instrument response.
% Input parameters:
%   tstar = row vector containing values of tstar = travel time/Q
%   tt    = two element vector containing the approximate time duration (s) 
%           and sample interval (s/sample) 
%   f0    = reference frequency (Hz) of Futterman Filter (default = 1)
%   instrument = one element string containing instrument type; currently 
%           must be one of: n(none), l,i,s (long-,intermediate-,short-period
%           DWWSSN), or r(REFTEK station LON) (default='n')
%   plt_flag=0 (default) for no plot, or 1 for plot whole time window, or 
%           two element vector to plot from first element (s) to last(s).
%
% Output Parameters:
%   FUTTER= array of time-domain displacement fields stored in columns
%   t     = column vector of time (s) corresponding to FUTTER.
%           zero time corresponds to the time predicted for waves traveling
%           at the velocity corresponding to the reference frequency 
%   
% See W.I.Futterman, Dispersive body waves, J.Geophys.Res., 67, 5279-5291, 1962.
% eq 24 for the asymptotic form of dispersion used here.
% eg.: [FUTTER,t]=futterman([1 2 4],[100 .05],1.,'n',[-2 8]);
%      [FUTTER,t]=futterman([1 2 4],[100 .05],1.,'s',[-2 8]);
%      [FUTTER,t]=futterman([1 2 4],[100 .05],1.,'i',[-2 8]);
%      [FUTTER,t]=futterman([1 2 4],[100 .05],1.,'r',[-2 8]);
%      [FUTTER,t]=futterman([1 2 4],[100 .05],1.,'l',[-5 55]);
%      [FUTTER,t]=futterman([1 2 4],[100 .05],.1,'l',[-5 55]); 

dur=tt(1);                    % time duration
dt =tt(2);                    % sample interval (s)
n=round(dur/dt)+1;            % length of time vector
nn=2^ceil(log(n)/log(2));     % next power of 2 for FFT
f=make_freq(nn,dt);           % frequency vector
w=2*pi*f;                     % angular frequency vector
T=-0.2*dt*(nn-1);             % infinite frequency arrival time is 20% into plot
if nargin<5, plt_flag=0;     end  % set default values
if nargin<4, instrument='n'; end
if nargin<3, f0=1;           end
if nargin<2, tt=[100 .05];   end

if instrument=='n';           % get transfer function for desired instrument
                              % instrument can be one of n(none),s,i,l,r(reftek)
  transfer=ones(length(f),1);
else
  Calib=get_inst_resp(instrument) ;
  transfer=inst_response(Calib,1,f,[20 dt]); 
end

FUTTER=[];
% frequency domain version of Futterman filter including the exponential
% amplitude decay and dispersion.
for j=1:length(tstar)
  futter = exp(-tstar(j)*abs(w)/2 + i*w.*(tstar(j)/pi*log(abs(w+eps)/2/pi/f0)));
  futter = futter.*transfer;      % convolve attenuation operator with instrument response
  [temp,f,t]=ift(futter,nn,T,dt); % properly scaled and time shifted inverse FFT
  FUTTER=[FUTTER real(temp)];     % save each response in FUTTER
end

if plt_flag(1)~=0,                   % plot results
  if length(plt_flag)==2,
    ii=[min(find(t>plt_flag(1))) : max(find(t<plt_flag(2)))];
  else
    ii=[1:length(t)];
  end
  plot(t(ii),FUTTER(ii,:)); grid
  xlabel('time(s)'); 
  ylabel('displacement amplitude');
  titlestar=[];for ii=1:length(tstar);
    titlestar=[titlestar num2str(tstar(ii)) ' '];
  end
  title(['Futterman Operator; t*=' titlestar '; f0=' num2str(f0) 'Hz; instrument: ' instrument]);
end
