function [pvel,svel,density,qp,qs,qk] = tna(r);
%   tna           tna radial earth model
% USAGE: [pvel,svel,density,qp,qs,qk] = tna(r);
% Evaluate the velocity, density, and Q structure of the TNA earth model.
% Tectonic North Anerica (Grand and Helmberger, GJRAS, 1984)
% r is an input vector of radii (km) from the center of the earth.
% The following 6 vectores are returned with the same dimensions as r:
% compressional velocity (km/s), shear wave velocity (km/s), density 
% (g/cm^3), and three dimensionless quality (attenuation) factors.
% qp is Q for compressional body waves, qs is Q for shear waves, and
% qk is Qkappa for pure compression.
% Q, and density are modified from PREM by Brian Kennett, 3/1/93, and are 
% not part of the Tna91 model.  The values for Q are a little high.
% written by Ken Creager 5/3/92

% TNA is parameterized by third order (or less) polynomials in each of 11 shells
% separated at the radii given in vector Tnarad. The polynomial coefficients are
% given in arrays Tnavp, Tnavs, Tnaden, qk, and qs.

global Tnarad Tnavp Tnavs Tnaden Tnaqk Tnaqs
readarrays='true ';
if exist('Tnavp')
  if length(Tnavp) == 10,
    if Tnavp(4,4) == -26.6083,
%     do not reassign the arrays
      readarrays='false';
    end
  end
end
if readarrays == 'true ',
   disp('reading in arrays')
Tnarad=[
 1217.1
 3482.0
 3631.0
 5621.0
 5711.0
 5966.0
 6096.0
 6333.0
 6351.0
 6371.0];


Tnavp =[
 11.24094,   0.     ,  -4.09689,   0.    ;
 10.03904,   3.75665, -13.67046,   0.    ; 
 14.49470,  -1.47089,   0.     ,   0.    ;
 25.14860, -41.15380,  51.99320, -26.6083;
 25.96984, -16.93412,   0.     ,   0.    ;
 27.53608, -19.52829,   0.     ,   0.    ;
-215.77583,501.31733,-279.17753,   0.    ;
-41328.74178,127990.79036,-132067.02595,45413.32974;
  6.5    ,   0.     ,   0.     ,   0.    ;
  5.8    ,   0.     ,   0.     ,   0.    ];

Tnavs =[
  3.56454,   0.     ,  -3.45241,   0.    ;  % inner core
  0.     ,   0.     ,   0.     ,   0.    ;  % outer core
  8.16616,  -1.58206,   0.     ,   0.    ;  % D"
 12.93030, -21.25900,  27.89880, -14.1080;  % lower mantle
 20.76890, -16.53147,   0.     ,   0.    ;  % just below 660
 16.87210, -12.67522,   0.     ,   0.    ;  % 410-660
-118.82532,274.16947,-151.82425,   0.    ;  % 
-12261.13096,38099.52569,-39437.03970,13603.20227;
  3.75   ,   0.     ,   0.     ,   0.    ;
  3.36   ,   0.     ,   0.     ,   0.    ];

Tnaden=[
 13.01219,   0.     ,  -8.45115,   0.    
 12.58405,  -1.69822,  -1.94472,  -7.10867
  7.18300,  -2.98500,   0.     ,   0.
  6.81848,  -1.68035,  -1.16066,  -0.01144
  7.75231,  -3.77163,   0.     ,   0.
 11.12044,  -7.87128,   0.     ,   0.
  7.15937,  -3.86083,   0.     ,   0.
  7.15661,  -3.85799,   0.     ,   0.
  2.92000,   0.00000,   0.     ,   0.
  2.72000,   0.00000,   0.     ,   0.     ];

%for i=1:N;ii=[ind(i+1):ind(i)-1];rr=r(ii)/6371;dd=d(ii);                       
%c=polyfit(rr,dd,min(3,length(dd))),ddd=polyval(c,rr);plot(rr,dd,'o',rr,ddd,'+');
%[i,max(abs(ddd-dd))],sprintf('%10.5f,',fliplr(c)),pause;end                     

Tnaqk=[
  1327.7,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0,
 57823.0];
 
Tnaqs=[
    84.6,
   9.e99,
   312.0,
   312.0,
   312.0,
   143.0,
   143.0,
    80.0,
   600.0,
   600.0];

end
radius=6371;
N=length(Tnarad);

% loop over each element in the vector r: i is the index of the appropriate shell
pvel=zeros(size(r));svel=pvel;
density=pvel; qk=pvel;qs=pvel;

for j=1:length(r);
   if r(j) <= 0,
     pvel(j)=Tnavp(1,1);      svel(j)=Tnavs(1,1); 
     density(j)=Tnaden(1,1);  qk(j)=Tnaqk(1);      qs(j)=Tnaqs(1);
   elseif r(j) >= radius ,
     pvel(j)=Tnavp(N,1);     svel(j)=Tnavs(N,1);
     density(j)=Tnaden(N,1); qk(j)=Tnaqk(N);     qs(j)=Tnaqs(N);
   else
      i=min(find(Tnarad>r(j)));
      y=r(j)/radius;
      x=[1;y;y*y;y*y*y];
      pvel(j)=Tnavp(i,:)*x;
      svel(j)=Tnavs(i,:)*x;
      density(j)=Tnaden(i,:)*x;
      qk(j)=Tnaqk(i);
      qs(j)=Tnaqs(i);
   end
end

% calculate Q_alpha -  modified 4/20/00 to fix an error (1-gamma) was 1/(1+gamma)
vs_over_vp = svel./pvel;
gamma      = 4/3 * vs_over_vp.^2;
qp         = 1./ ( (1-gamma)./qk  +  gamma./qs );
