function d=corr_inst(Data, Calib, Sintr, flag, dimen, filter_freqs);
%   corr_inst     remove instrument response 
%Usage:  d=corr_inst(Data, Calib, Sintr, flag, dimen, filter_freqs);
% if flag = 0   it is assumed that the instrument is flat to velocity 
%               and that the part described by poles and zeros is flat at 1 Hz
%               in this case divide by the gain and integrate, do nothing or differentiate
%               for displacement, velocity, or acceleration
% if flag ~=0   convert the units of the instrument response from counts/M to counts/
%               desired units, and deconvolve the instrument response and gain.
%  input the Data in column vectors (counts), the instrument response in Calib, the sample
%               interval in Sintr (s/sample).  dimen must be one of d,v,a for output in 
%               displacement (M), velocity(M/S), or acceleration (M/S/S).  If flag~=0,
%               filter_freqs=[min1,min2,max1,max2] must be included.  This sets the 
%               cutoff frequencies for the deconvolutions.  The response is flat between
%               min2 and max1, and tapers using a cosine to min1 and max2 (Hz).
%  output vector d is same size as Data

[L,M]=size(Data);
if flag==0;                                  
  Calib_new=conv_response(Calib,'d','v',1);   % convert response to velocity
  Sd=Calib_new(2,:);                          % get digital sensitivity (gain) in counts/(M/S)
  Data=Data./vec2mat(Sd',size(Data,1))';      % divide by gain to get true velocity (if inst resp is flat to vel)
  if dimen=='d';
    d=cum_trapz(Data);                        % integrate to get true displacement
    d=d  .* vec2mat(Sintr',size(d,1))';       % multiply by Sample interval
  elseif dimen=='v';
    d=Data;
  elseif dimen=='a';
    d=zeros(size(Data));
    for i=1:M
      d(:,i)=gradient(Data(:,i)',Sintr)';     % differentiate to get true acceleration
    end
  end
else
  Calib_new=conv_response(Calib,'d',dimen,1); % convert response to desired dimensions 
  d=decon_inst(Data,Calib_new, [[3,1,1e8],filter_freqs]',Sintr,[1:M],1e8); % deconvolve response
end

