function [pvel,svel,density,qp,qs,qk] = iasp91(r);
%   iasp91        iasp91 radial earth model
% USAGE: [pvel,svel,density,qp,qs,qk] = iasp91(r);
% Evaluate the velocity, density, and Q structure of the IASP91 earth model.
% r is an input vector of radii (km) from the center of the earth.
% The following 6 vectores are returned with the same dimensions as r:
% compressional velocity (km/s), shear wave velocity (km/s), density 
% (g/cm^3), and three dimensionless quality (attenuation) factors.
% qp is Q for compressional body waves, qs is Q for shear waves, and
% qk is Qkappa for pure compression.
% Q, and density are modified from PREM by Brian Kennett, 3/1/93, and are 
% not part of the iasp91 model.  The values for Q are a little high.
% written by Ken Creager 5/3/92

% IASP91 is parameterized by third order (or less) polynomials in each of 11 shells
% separated at the radii given in vector iasprad. The polynomial coefficients are
% given in arrays iaspvp, iaspvs, iaspden, qk, and qs.

global Iasprad Iaspvp Iaspvs Iaspden Iaspqk Iaspqs
readarrays='true ';
if exist('Iaspvp')
  if length(Iaspvp) == 11,
    if Iaspvp(4,4) == -26.6083,
%     do not reassign the arrays
      readarrays='false';
    end
  end
end
if readarrays == 'true ',
   disp('reading in arrays')
Iasprad=[
 1217.1
 3482.0
 3631.0
 5611.0
 5711.0
 5961.0
 6161.0
 6251.0
 6336.0
 6351.0
 6371.0];

Iaspvp =[
 11.24094,   0.     ,  -4.09689,   0.    ;
 10.03904,   3.75665, -13.67046,   0.    ; 
 14.49470,  -1.47089,   0.     ,   0.    ;
 25.14860, -41.15380,  51.99320, -26.6083;
 25.96984, -16.93412,   0.     ,   0.    ;
 29.38896, -21.40656,   0.     ,   0.    ;
 30.78765, -23.25415,   0.     ,   0.    ;
 25.41389, -17.69722,   0.     ,   0.    ;
  8.78541,  -0.74953,   0.     ,   0.    ;
  6.5    ,   0.     ,   0.     ,   0.    ;
  5.8    ,   0.     ,   0.     ,   0.    ];

Iaspvs =[
  3.56454,   0.     ,  -3.45241,   0.    ;
  0.     ,   0.     ,   0.     ,   0.    ;
  8.16616,  -1.58206,   0.     ,   0.    ;
 12.93030, -21.25900,  27.89880, -14.1080;
 20.76890, -16.53147,   0.     ,   0.    ;
 17.70732, -13.50652,   0.     ,   0.    ;
 15.24213, -11.08552,   0.     ,   0.    ;
  5.75020,  -1.27420,   0.     ,   0.    ;
  6.706231, -2.248585,  0.     ,   0.    ;
  3.75   ,   0.     ,   0.     ,   0.    ;
  3.36   ,   0.     ,   0.     ,   0.    ];

Iaspden=[
 13.01219,   0.     ,  -8.45115,   0.    
 12.58405,  -1.69822,  -1.94472,  -7.10867
  7.18300,  -2.98500,   0.     ,   0.
  6.81848,  -1.68035,  -1.16066,  -0.01144
  7.75231,  -3.77163,   0.     ,   0.
 11.12044,  -7.87128,   0.     ,   0.
  7.15937,  -3.86083,   0.     ,   0.
  7.15661,  -3.85799,   0.     ,   0.
  7.15122,  -3.85258,   0.     ,   0.
  2.92000,   0.00000,   0.     ,   0.
  2.72000,   0.00000,   0.     ,   0.     ];

%for i=1:11;ii=[ind(i+1):ind(i)-1];rr=r(ii)/6371;dd=d(ii);                       
%c=polyfit(rr,dd,min(3,length(dd))),ddd=polyval(c,rr);plot(rr,dd,'o',rr,ddd,'+');
%[i,max(abs(ddd-dd))],sprintf('%10.5f,',fliplr(c)),pause;end                     

Iaspqk=[
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
 57823.0];
 
Iaspqs=[
    84.6,
   9.e99,
   312.0,
   312.0,
   312.0,
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
   if r(j) <= 0,
     pvel(j)=Iaspvp(1,1);      svel(j)=Iaspvs(1,1); 
     density(j)=Iaspden(1,1);  qk(j)=Iaspqk(1);      qs(j)=Iaspqs(1);
   elseif r(j) >= radius ,
     pvel(j)=Iaspvp(11,1);     svel(j)=Iaspvs(11,1);
     density(j)=Iaspden(11,1); qk(j)=Iaspqk(11);     qs(j)=Iaspqs(11);
   else
      i=min(find(Iasprad>r(j)));
      y=r(j)/radius;
      x=[1;y;y*y;y*y*y];
      pvel(j)=Iaspvp(i,:)*x;
      svel(j)=Iaspvs(i,:)*x;
      density(j)=Iaspden(i,:)*x;
      qk(j)=Iaspqk(i);
      qs(j)=Iaspqs(i);
   end
end

% calculate Q_alpha -  modified 4/20/00 to fix an error (1-gamma) was 1/(1+gamma)
vs_over_vp = svel./pvel;
gamma      = 4/3 * vs_over_vp.^2;
qp         = 1./ ( (1-gamma)./qk  +  gamma./qs );

