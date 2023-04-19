function data=decon_inst_richmag(data,Calib_old,Calib_new,sintr,key,waterlevel);
%   decon_inst_richmag deconvolve old instrument response and convolve a new one
% Usage: data=decon_inst_richmag(data,Calib_old,Calib_new,sintr,key,waterlevel);
%
% Convert poles and zeros of transfer function to polynomial 
% coefficients, then calculate the amplitude and phase response.
% Deconvolution is stabilized using a waterlevel (eg = 1e-6).
%
%INPUT PARAMETERS:
% data        = real matrix of time series stored by columns
% Calib_old   = complex matrix of instrument responses stored by columns
%               There are 62 rows in a format described below.
% Calib_new   = complex column vector describing the new instrument response
%               If there are 62 rows it contains poles and zeros in the 
%               format described below.
%               If Calib_new has fewer than 62 rows, the first
%               element is a key to the description of the new response
%               If Calib_new(1)==3 then use a cos (hanning) taper
%                 In this cals Calib_new contains 7 numbers:
%                 [3,waterlevel,gain,f1,f2,f3,f4]
% sintr       = real row vector of sample intervals (s)
%               must all be the same
% key         = row vector containing the data columns to deconvolve
%               for example deconvolve all m columns if key=[1:m] 
% waterlevel  = optional parameter used to stabilize the deconvolution
%               default value is 1.e-8
%OUTPUT parameters:
% data        = deconvolved data
%
% Format of calibration array:
% Calib(1)    = normalization
% Calib(2)    = meands (digital sensitivity)
% Calib(3)    = number of poles
% Calib(4:32) = complex poles
% Calib(33)   = number of zeros
% Calib(34:62)= complex zeros

if length(Calib_new) == 62,
  calib_key = 1;                 % poles and zeros
else
  calib_key = real(Calib_new(1));
end

if nargin < 7, waterlevel=1.e-8; end

n=length(data(:,1));                          % number of data
nn=2^nextpow2(n);                             % next power of 2 for FFT
f=make_freq(nn,sintr(1));                     % define frequency vector

if calib_key==1,                              % new response in poles and zeros
  norm_new  =Calib_new(1);
  meands_new=Calib_new(2);
  npole     =real(Calib_new( 3));
  nzero     =real(Calib_new(33));
  poles     =Calib_new( 4:npole+ 3);
  zeros     =Calib_new(34:nzero+33);
  bb_new    =poly(zeros);       % convert poles to polynomial coefficients 
  aa_new    =poly(poles);       % convert zeros to polynomial coefficients
  inst_new=freqs(bb_new,aa_new,2*pi*f)*norm_new;    % new instrument response
elseif calib_key == 3,                           % new response is cos taper
  meands_new=real(Calib_new(2));
  f1=real(Calib_new(3));f2=real(Calib_new(4));
  f3=real(Calib_new(5));f4=real(Calib_new(6));
  inst_new=f*0;
  g=abs(f);
  i1=find(g>f1&g<f2);i2=find(g>f3&g<f4);i3=find(g>=f2&g<=f3);
  inst_new(i3)=inst_new(i3)+1;
  inst_new(i1)=0.5*(1-cos(pi*(g(i1)-f1)/(f2-f1)));
  inst_new(i2)=0.5*(1+cos(pi*(g(i2)-f3)/(f4-f3)));
end

DATA=fft(data(:,key),nn);
length(key)
for i=1:length(key);
  k=key(i);
  skip_decon='f';
  if calib_key==1,
    if Calib_old(3:62,k) == Calib_new(3:62),
%     poles and zeros are the same, so change only the gain
      skip_decon='t'
    end
  end
  if skip_decon=='f',
%   deconvolve this instrument
    disp(['Deconvolving instrument response from trace ',int2str(k)]);
    norm_old  =Calib_old(1,k);
    npole     =real(Calib_old( 3,k));
    nzero     =real(Calib_old(33,k));
    poles     =Calib_old( 4:npole+ 3,k);
    zeros     =Calib_old(34:nzero+33,k);
    bb_old    =poly(zeros);       % convert poles to polynomial coefficients 
    aa_old    =poly(poles);       % convert zeros to polynomial coefficients

    inst_old=freqs(bb_old,aa_old,2*pi*f)*norm_old;
    temp1=inst_old.*conj(inst_old);
    gamma=max(temp1)*waterlevel;
    temp=inst_new.*conj(inst_old)./(temp1+gamma);
    temp_data=real(ifft(DATA(:,i).*temp));
    data(:,k)=temp_data(1:n);
  end 
  meands_old=Calib_old(2,k);
  data(:,k)=data(:,k)*meands_new/meands_old;  
end
