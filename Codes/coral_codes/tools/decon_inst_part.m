function data=decon_inst_part(data,Calib_old,Calib_new,header,key,waterlevel);
%   decon_inst    deconvolve instrument response
% Usage: data=decon_inst(data,Calib_old,Calib_new,sintr,key,waterlevel);
%
% Deconvolve old instrument response from data and convolve new 
% instrument response.  Stabilize using a waterlevel (eg = 1e-6).
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
%               If Calib_new(1)==3 then use a zero-phase cos (hanning) taper
%                 In this case Calib_new contains 6 numbers:
%                 [3,gain,f1,f2,f3,f4] 
%               If Calib_new(1)==4 then use a zero-phase gaussian filter
%                 In this case Calib_new contains 3 or 4 numbers:
%                 [4,gain,f2,[f0]]    G(f) = exp( -((f-f0)/f2).^2 )
%                                     f0=0 if not specified
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
% Calib(2)    = meands (gain)
% Calib(3)    = number of poles
% Calib(4:32) = complex poles
% Calib(33)   = number of zeros
% Calib(34:62)= complex zeros

if length(Calib_new) == 62,
  calib_key = 1;                 % poles and zeros
else
  calib_key = real(Calib_new(1));
end

if nargin < 7, waterlevel=1.e-8; end          % default waterlevel

n=length(data(:,1));                          % number of data
nn=2^nextpow2(n);                             % next power of 2 for FFT
f=make_freq(nn,sintr(1));                     % define frequency vector

[n,m]=size(data(:,key));
data_out=data;
[istart,iend]=find_nonzero(header);
ndata = iend-istart+1;
nn=2.^nextpow2(ndata);



for i=1:m
  index  = istart(i):iend(i);
  dd=data(index,i);
  data_out(index,i)=dd-mean(dd);
end;



if calib_key==1,                              % new response in poles and zeros
  inst_new=inst_response(Calib_new,1,f,[]);
  meands_new=Calib_new(2);

elseif calib_key == 3,                        % new response is cos taper
  meands_new=real(Calib_new(2));
  f1=real(Calib_new(3));f2=real(Calib_new(4));
  f3=real(Calib_new(5));f4=real(Calib_new(6));
  inst_new=f*0;
  g=abs(f);
  i1=find(g>f1&g<f2);i2=find(g>f3&g<f4);i3=find(g>=f2&g<=f3);
  inst_new(i3)=inst_new(i3)+1;
  inst_new(i1)=0.5*(1-cos(pi*(g(i1)-f1)/(f2-f1)));
  inst_new(i2)=0.5*(1+cos(pi*(g(i2)-f3)/(f4-f3)));

elseif calib_key == 4,                        % new response is gausian taper
  meands_new=real(Calib_new(2));
  f2=real(Calib_new(3));
  if length(Calib_new>3); f0=real(Calib_new(4));
  else                    f0=0;
  end
  ff=(f-f0)./f2;
  inst_new=exp(-(ff.*ff));
end

DATA=fft(data(:,key),nn);
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
    if Calib_old([3,33],k)==[0;0]; % if no poles and no zeros then old resp = 1
      temp=inst_new;
    else
      inst_old=inst_response(Calib_old,k,f,[]);
      temp1=inst_old.*conj(inst_old);
      gamma=max(temp1)*waterlevel;
      temp=inst_new.*conj(inst_old)./(temp1+gamma);
    end
    temp_data=real(ifft(DATA(:,i).*temp));
    data(:,k)=temp_data(1:n);
  end 
  meands_old=Calib_old(2,k);
  data(:,k)=data(:,k)*meands_new/meands_old;  
end
