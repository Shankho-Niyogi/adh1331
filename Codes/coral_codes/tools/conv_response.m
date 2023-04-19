function [Calib]=conv_response(Calib,old_units,new_units,f0,key);
%   conv_response convert units of instrument response
% Usage: [Calib]=conv_response(Calib,old_units,new_units,f0,key);
% Input a matrix (62xN) containing N pole-zero instrument responses
% with units given by old_units.  Convert these arrays to the units
% given by new_units.  The new gain and normalization will be given at
% a frequency of f0 Hz.  old_units and new_units must be chosen from
% d,v, or a for displacement, velocity, or acceleration
% key is a vector of length up to length N, ie if key=[1 5] then change 
% the first and fifth instrument responses. 

if nargin<5,
  key=1:size(Calib,2);
end

if      old_units=='d',  gammao=0;
elseif  old_units=='v',  gammao=1;
elseif  old_units=='a',  gammao=2;
else                     gammao=-1;
end
 
if      new_units=='d',  gamman=0;
elseif  new_units=='v',  gamman=1;
elseif  new_units=='a',  gamman=2;
else                     gamman=-1;
end

if (gammao<0 | gamman<0) 
  disp('old_units and new_units must each be one of d,v, or a, try again')
  return
end

gamma       = gammao-gamman;
f02pi_gamma = (2*pi*f0)^gamma;

L=length(key);
for j=1:L;                            % Loop over all requested stations
  % first: the reference frequency (fold) is not known, so first determine the gain and
  % normalization for the requested reference frequency (f0): R=A0(fold) * H(f0) where
  % fold is not known but A0(fold) is known.  Then, A(f0)=A(fold)/abs(R) and Sd(f0)=Sd(fold)*R
  R=inst_response(Calib,j,[1 1 1]*f0,[]); 
  R=abs(R(1));
  A0=Calib(1,j)/R;                    % correct A0 and Sd for new reference frequency
  Sd=Calib(2,j)*R;
  A0=A0/f02pi_gamma;                  % correct A0 and Sd for new units
  Sd=Sd*f02pi_gamma;
  Calib(1,j)=A0;
  Calib(2,j)=Sd;
  N=Calib(33,j);                      % N is number of zeros
  if N+gamma>=0;
    Calib(33,j)=Calib(33,j)+gamma;    % add gamma zeros
  else
    Calib(33,j)=0;                    % or if there are not enough zeros, remove all N zeros and
    Calib(3,j)=Calib(3,j)-N-gamma;    % add (-N-gamma) poles
  end
end
