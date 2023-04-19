function [cc,t,phs]= my_xcor(d,srate,plt,ref_trace);
%   xcor          cross correlate coral data
% usage: [cc,t,phs]= my_xcor(d,srate,plt,ref_trace);
%
% compute normalized cross correlograms:
%INPUT PARAMETERS
% d      contains several (at least two) real column vectors of time series
% srate  is the sample rate (scalar, all data must have same sample rate)
% plt    optional 2 element vector for plotting:
% plt(1) maximum time for cross correlogram plot (zero for no plot)
% plt(2) maximum frequency for phase angle plot (zero for no plot)
% ref_trace integer specifying a reference trace (0 for no reference)
%
%OUTPUT PARAMETERS:
% cc     contains the [(n+1)*n/2] normalized cross correlations of the 
%        column vectors taken in pairs
%        eg. if there are 4 input vectors cc contains the pairs:
%        11 12 13 14 22 23 24 33 34 44
%        if ref_trace is given, cc contains only n normalized cross correlations
%        calculated with respect to the reference trace
% t      time vector for cross correlograms
% phs    is the phase spectrum of the cross correlograms (same size as cc)
% 
% cross correlograms are calculated in the frequency domain using the FFT
% and normalized so the autocorrelation at zero lag equals 1.

% Ken Creager  3/19/92

if nargin<4,  ref_trace=0;   end

dd=[d; zeros(size(d))];                           % pad data with zeros
[n,m]=size(dd);                                   % determine size of data array
t=srate(1)*[-n/2:1:n/2-1]';                       % time axis (centered at 0 lag)
n2=2^ceil(log(n)/log(2));                         % next power of 2 for FFT
ff=fft(dd,n2);                                    % fourier transform the data
if ref_trace==0,

  cc=zeros(n2,(m+1)*m/2);norm=zeros(1,m);           % initialize arrays
  % compute cross correlograms and normalization factors
  k=0; for i=1:m; for j=i:m; k=k+1;
      cc(:,k)=real( ifft( ff(:,i).*conj(ff(:,j)),n2 ) ) ;
      if i == j; norm(i)=sqrt(cc(1,k)); end;
  end; end;
  % normalize and time shift cross correlogram so zero lag is at center of vectors
  k=0; for i=1:m; for j=i:m; k=k+1;
    cc(:,k)=fftshift(cc(:,k))/(norm(i)*norm(j));
  end; end;

else

  cc=zeros(n2,m); norm=zeros(1,m);           % initialize arrays
  % compute cross correlograms and normalization factors
  for i=1:m; 
    cc(:,i)=real( ifft( ff(:,ref_trace).*conj(ff(:,i)),n2 ) ) ;
    if i==ref_trace; 
      norm(i)=sqrt(cc(1,i)); 
    else
      cc_temp=real( ifft( ff(:,i).*conj(ff(:,i)),n2 ) ) ;
      norm(i)=sqrt(cc_temp(1));
    end;
  end
  % normalize and time shift cross correlogram so zero lag is at center of vectors
  for i=1:m;
    cc(:,i)=fftshift(cc(:,i))/(norm(i)*norm(ref_trace));
  end

end

% delete ends of cross correlogram so its length is twice the length of input data
% rather than a power of 2 which was used for fast fourier transform
ncut=(n2-n)/2;
cc=cc(ncut+1:n2-ncut,:);

if ref_trace==0,  %  plotting only works with no reference trace 

if nargout>=3 | (nargin==3 & plt(2)~=0) ;  %calculate phase shift(f) if requested
% NOTE: this part uses the slow fourier transform, if anyone wants to make extensive use
% of the phase difference part of this routine, it should be modified to use power of
% 2 FFT
  c=demean(cc);c=taperd(c,.1);            % remove mean and taper
  c=fft(c);                               % fourier transform cross correlogram
% c was time shifted in the time domain using fftshift so we could taper c.
% We must correct for this now by applying a phase shift in the frequency
% domain. In this case each point in the frequency domain gets shifted by
% pi*i where i is the index, ie. multiply the complex spectrum by -1^i for
% index i
  timeshift=cos(pi*[0:n-1]');
  k=0; for i=1:m; for j=i:m; k=k+1;
      c(:,k)=c(:,k).*timeshift;
      c(:,k)=fftshift(c(:,k));
      phs(:,k)=angle(c(:,k));
  end; end;
end

if nargin ==3,                     % make plots

  f=1/srate(1)*[-.5:1/n:.5-1/n]';  % full frequency range (centered at 0)
  t=srate(1)*[-n/2:1:n/2-1]';      % full time range (centered at 0 lag)
  freq=f(n/2+1:n);                 % half frequency range (starting at 0)

  if plt(1) ~= 0;                  % plot cross correlograms
    p0=n/2+1-plt(1)/srate(1);      %set plot limits
    p1=n/2  +plt(1)/srate(1); 
    k=0; for i=1:m; for j=i:m; k=k+1;
      plot(t(p0:p1),cc(p0:p1,k),'-');
      title(['cross correllogram  i=' num2str(i) '  j=' num2str(j)] );
      xlabel('lag time (s)');pause
    end;end;
  end;

  if plt(2) ~= 0;                  % plot phase
    phs1=phs(n/2+1:n,:);
    p0=1;                          %set plot limits
    p1=plt(2)*2*srate(1)*length(phs1);
    k=0; for i=1:m; for j=i:m; k=k+1;
      plot(freq(p0:p1),phs1(p0:p1,k),freq(p0:p1),phs1(p0:p1,k),'o');
      title(['phase difference    i=' num2str(i) '  j=' num2str(j)] );
      xlabel('frequency (Hz)');pause
    end;end;
  end;

end
 
end
