function [pvel,svel,density,qp,qs,qk] = prem2(r);
%   prem2         PREM2 radial earth model
% USAGE: [pvel,svel,density,qp,qs,qk] = prem2(r);
% Evaluate the velocity, density, and Q structure of the PREM2 earth model.
% r is an input vector of radii (km) from the center of the earth.
% The following 6 vectores are returned with the same dimensions as r:
% compressional velocity (km/s), shear wave velocity (km/s), density
% (g/cm^3), and three dimensionless quality (attenuation) factors.
% qp is Q for compressional body waves, qs is Q for shear waves, and
% qk is Qkappa for pure compression.
% written by Ken Creager 12/11/96


% PREM2 is parameterized by third order (or less) polynomials in each of 15 shells
% separated at the radii given in vector Prem2rad. The polynomial coefficients are
% given in arrays Prem2vp, Prem2vs, Prem2den, qp, and qs.
% PREM2 coefficients are from Song(1994) PhD Thesis, CalTech
global Prem2rad Prem2vp Prem2vs Prem2den Prem2qk Prem2qs
readarrays='true ';
if length(Prem2vp) == 15,
   if Prem2vp(4,4) == -13.5732
%    do not reassign the arrays
     readarrays='false';
   end
end
if readarrays == 'true ',
   disp('reading in arrays')
Prem2rad=[
1010.0
1221.5
1621.5
3480.0
3630.0
3840.0
5600.0
5701.0
5771.0
5971.0
6151.0
6291.0
6346.6
6356.0
6371.0];

Prem2vp =[
 11.2622,   0.0000,  -6.3640,   0.0000;
 11.3041,  -1.2730,   0.0000,   0.0000;
  4.0354,  82.0080,-347.7690, 468.7860;
 11.0487,  -4.0362,   4.8023  -13.5732;
 14.2743,  -1.3998,   0.0000,   0.0000;
 14.2743,  -1.3998,   0.0000,   0.0000;
 24.9520, -40.4673,  51.4832, -26.6419;
 29.2766, -23.6027,   5.5242,  -2.5514;
 19.0957,  -9.8672,   0.0000,   0.0000;
 39.7027, -32.6166,   0.0000,   0.0000;
 20.3926, -12.2569,   0.0000,   0.0000;
  4.1875,   3.9382,   0.0000,   0.0000;
  4.1875,   3.9382,   0.0000,   0.0000;
  6.8000,   0.0000,   0.0000,   0.0000;
  5.8000,   0.0000,   0.0000,   0.0000];

Prem2vs=[
  3.6678,   0.0000,  -4.4475,   0.0000;
  3.6678,   0.0000,  -4.4475,   0.0000;
  0.0000,   0.0000,   0.0000,   0.0000;
  0.0000,   0.0000,   0.0000,   0.0000;
  6.9254,   1.4672,  -2.0834,   0.9783;
 11.1671, -13.7818,  17.4575,  -9.2777;
 11.1671, -13.7818,  17.4575,  -9.2777;
 22.3459, -17.2473,  -2.0834,   0.9783;
  9.9839,  -4.9324,   0.0000,   0.0000;
 22.3512, -18.5856,   0.0000,   0.0000;
  8.9496,  -4.4597,   0.0000,   0.0000;
  2.1519,   2.3481,   0.0000,   0.0000;
  2.1519,   2.3481,   0.0000,   0.0000;
  3.9000,   0.0000,   0.0000,   0.0000;
  3.2000,   0.0000,   0.0000,   0.0000];

Prem2den=[
 13.0885,   0.0000,  -8.8381,   0.0000,
 13.0885,   0.0000,  -8.8381,   0.0000,
 12.5815,  -1.2638,  -3.6426,  -5.5281;
 12.5815,  -1.2638,  -3.6426,  -5.5281;
  7.9565,  -6.4761,   5.5283,  -3.0807;
  7.9565,  -6.4761,   5.5283,  -3.0807;
  7.9565,  -6.4761,   5.5283,  -3.0807;
  7.9565,  -6.4761,   5.5283,  -3.0807;
  5.3197,  -1.4836,   0.0000,   0.0000;
 11.2494,  -8.0298,   0.0000,   0.0000;
  7.1089,  -3.8045,   0.0000,   0.0000;
  2.6910,   0.6924,   0.0000,   0.0000;
  2.6910,   0.6924,   0.0000,   0.0000;
  2.9000,   0.0000,   0.0000,   0.0000;
  2.6000,   0.0000,   0.0000,   0.0000];

Prem2qk=[
  1327.7,
  1327.7,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0];

Prem2qs=[
    84.6,
    84.6,
   9.e99,
   9.e99,
   312.0,
   312.0,
   312.0,
   312.0,
   143.0,
   143.0,
   143.0,
    80.0,
   600.0,
   600.0,
   600.0];

end
radius=6371;

% loop over each element in the vector r: i is the index of the appropriate shell
pvel=zeros(size(r));svel=pvel;
density=pvel; qk=pvel;qs=pvel;
for j=1:length(r);
   if r(j) <= 0 ,
     pvel(j)=Prem2vp(1,1);      svel(j)=Prem2vs(1,1);
     density(j)=Prem2den(1,1);  qk(j)=Prem2qk(1);      qs(j)=Prem2qs(1);
   elseif r(j) >= radius ,
     pvel(j)=Prem2vp(15,1);     svel(j)=Prem2vs(15,1);
     density(j)=Prem2den(15,1); qk(j)=Prem2qk(15);     qs(j)=Prem2qs(15);
   else
      i=min(find(Prem2rad>r(j)));
      y=r(j)/radius;
      x=[1;y;y*y;y*y*y];
      pvel(j)=Prem2vp(i,:)*x;
      svel(j)=Prem2vs(i,:)*x;
      density(j)=Prem2den(i,:)*x;
      qk(j)=Prem2qk(i);
      qs(j)=Prem2qs(i);
   end
end

% calculate Q_alpha -  modified 4/20/00 to fix an error (1-gamma) was 1/(1+gamma)
vs_over_vp = svel./pvel;
gamma      = 4/3 * vs_over_vp.^2;
qp         = 1./ ( (1-gamma)./qk  +  gamma./qs );
