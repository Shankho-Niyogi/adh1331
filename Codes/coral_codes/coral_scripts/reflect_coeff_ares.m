function [C,ierr] = ares_coeff(a,b,rho,p);
% ares_coeff - Compute all reflection/transmission coefficients for a liquid-solid interface
%
% USAGE: [C,ierr] = ares_coeff(a,b,rho,p);
%
% Input Parameters:
%  a(2): P-wave velocities above(1) and below(2) discontinuity (km/s)
%  b(2): S-wave velocities above(1) and below(2) discontinuity (km/s) - set zero for liquid
%  rho(2): Density above(1) and below(2)  (g/cc) 
%  p: ray parameter (column vector, flat earth) (s/km)
%
% Output Parameters:
%  C:  structure of reflection and transmission coefficients containing column vectors 
%    with a value for each input ray parameter.  These coefficients are for 
%    displacement potentials using the sign conventions of Aki and Richards, 1980.
%
%    C.PdownPup, C.PdownPdown, C.PdownSup
%    C.PupPup,   C.PupPdown,   C.PupSup
%    C.SdownPup, C.SdownPdown, C.SdownSup
%
%
% Note:  This code does not handle critical angles.  Once one of the angles
%    becomes critical, the coefficients are not returned.  This is probably not
%    hard to fix, but hasn't been done yet.
%
%    
%   coded originally by J. Revenaugh in c
%   matlab version by K. Creager (6/99)
%
% Intermediate Results:
%
%    SS: Matrix of scattering coefficients.
%    columns are incident wave, rows are reflected/transmitted
%    column 1 is downgoing P
%    column 2 is downgoing S
%    column 3 is upgoing P
%    row 1 is upgoing P
%    row 2 is upgoing S
%    row 3 is downgoing P
%
%    e.g. The reflection coefficient of PcP is SS(1,1) = PdownPup

ierr = 0;

pp   = p(:);    % make sure ray parameter is a column vector
n=length(pp);   % number of ray parameters

r1=rho(1); r2=rho(2); % density (g/cc)
a1=a(1);   a2=a(2);   % compressional velocities (km/s)
b1=b(1);              % shear velocity (km/s)

sini = [p*a1 , p*a2];   % sin of ray angles for p waves  (n,2) matrix for down and up going rays
%if any(abs(sini(:)) > 1); ierr=-1; end
cosi = sqrt(1-sini.*sini);  % cos of ray angles for p waves (n,2) matrix

sinj = p*b1;      % sin of ray angles for s waves (n,2) matrix for down and up going rays
%if any(abs(sinj) > 1); ierr=-2; end
cosj = sqrt(1-sinj.*sinj);  % cos of ray angles for s waves (n,2) matrix

SSS=zeros(3,3,n)*NaN;

for i=1:n;       % loop over each ray parameter
  
%  if all( [sini(i,:) , sinj(i)] <= 1); % are all ray angles subcritical?
    p     = pp(i);
    si1   = sini(i,1); 
    ci1   = cosi(i,1); 
    si2   = sini(i,2); 
    ci2   = cosi(i,2);
    sj1   = sinj(i,1);
    cj1   = cosj(i,1);
    gamma1= 1 - 2*b1*b1*p*p;
  
    M= [ -ci1            ,      sj1          ,   -ci2
       r1*a1*gamma1      , -2*r1*b1*b1*p*cj1 , -r2*a2
      -2*r1*b1*b1*p*ci1  ,   -r1*b1*gamma1   ,    0     ];

    N      =  M;
    N(2,:) = -M(2,:);
    SS = inv(M)*N;   % Compute the inverse of M and the product MinvN
    SSS(:,:,i)=SS;
%  end
  
end

tmp = [SSS(1,1,:)]; C.PdownPup   = tmp(:);
tmp = [SSS(1,2,:)]; C.SdownPup   = tmp(:);
tmp = [SSS(1,3,:)]; C.PupPup     = tmp(:);

tmp = [SSS(2,1,:)]; C.PdownSup   = tmp(:);
tmp = [SSS(2,2,:)]; C.SdownSup   = tmp(:);
tmp = [SSS(2,3,:)]; C.PupSup     = tmp(:);

tmp = [SSS(3,1,:)]; C.PdownPdown = tmp(:);
tmp = [SSS(3,2,:)]; C.SdownPdown = tmp(:);
tmp = [SSS(3,3,:)]; C.PupPdown   = tmp(:);

return



% example for calculating PcP reflection coefficients for different models (e.g. ULVZ)
clf 
iprint=0;
Rad = 3480;
[a,b,rho] = prem(Rad+[.1,-.1] ), % Vp, Vs, rho just above and just below CMB
A=a;B=b;R=rho;
D=2:2:80;                        % epicentral distances for PcP
[T,p]=get_ttt('PcP',0,D,'prem'); % get travel time and ray parameter
p=p*180/pi/Rad;                  % ray parameter in s/km

a1=[.9  1 1.1];                  % range of models for P-wave velocity in mantle
b1=[.7 1 1.3];                   % range of models for S-wave velocity in mantle
r1=[.95 1 1.05];                 % range of models for density in mantle
a2=[.95 1 1.05];                 % range of models for P-wave velocity in core
c1='rbg';l1='o-+';
for k=1:length(a1);  for j=1:length(b1); for l=1:length(r1); for m=1:length(a2);
  A(1)=a(1)*a1(k); B=b(1)*b1(j); R(1)=rho(1)*r1(l); A(2)=a(2)*a2(m);
  C = ares_coeff(A,B,R,p);
  plot(D,C.PdownPup,[c1(k) l1(j)]);hold on
end; end; end; end
xlabel('distance (deg)')
ylabel('PcP reflection coefficient')
grid on
axis([0 80 -1 1])
orient landscape
if iprint==1;
  print -dpsc /shadowhome/kcc/junk.ps
  !runlow epson /shadowhome/kcc/junk.ps
end

clf
k=2; j=2; for l=1:length(r1); m=2;
  A(1)=a(1)*a1(k); B=b(1)*b1(j); R(1)=rho(1)*r1(l); A(2)=a(2)*a2(m);
  C = ares_coeff(A,B,R,p);
  plot(D,C.PdownPup,[c1(l) '-']);hold on
end;
k=2; j=2; l=2; for m=1:length(a2);
  A(1)=a(1)*a1(k); B=b(1)*b1(j); R(1)=rho(1)*r1(l); A(2)=a(2)*a2(m);
  C = ares_coeff(A,B,R,p);
  plot(D,C.PdownPup,[c1(m)  '--']);hold on
end
xlabel('distance (deg)')
ylabel('PcP reflection coefficient')
grid on
axis([0 80 -1 1])
orient landscape
if iprint==1;
  print -dpsc /shadowhome/kcc/junk.ps
  !runlow epson /shadowhome/kcc/junk.ps
end



%%%%%%%%%%%%
% Plot the reflection coefficient and phase angle
% of PKiKP reflections as a function of
% epicentral distance, in a one-page plot
%
% Added by Ares Ouzounis - 1999
%
%%%%%%%%%%%%

depth = 449;

delta = [80:0.4:180];
[t,p] = get_ttt('PKiKP',depth,delta,'ak135');
clear t
p = p*180/pi/1221.5;
a = [11.0427 10.2890];				% Vp across ICB according to ak135
b = [3.5043 0];					% Vs across ICB according to ak135
rho = [12.7037 12.1391];			% rho across ICB according to ak135

[C,ierr] = reflect_coeff_ares(a,b,rho,p);
reflection_coeff = abs(C.PupPdown);
phase_angle_radians = angle(C.PupPdown);
phase_angle_degrees = (angle(C.PupPdown)*180)/pi;

subplot (3,1,1); plot (delta,reflection_coeff,'k');title 'Absolute Value of PKiKP reflection coefficient (PREM, 449km depth)'; xlabel 'Epicentral Distance (deg)'; grid

subplot (3,1,2); plot (delta,phase_angle_radians,'k');title 'Phase Angles (in Radians)'; xlabel 'Epicentral Distance (deg)'; ylabel 'Phase angle (Radians)'; grid

subplot (3,1,3); plot (delta,phase_angle_degrees,'k');title 'Phase Angles (in Degrees)'; xlabel 'Epicentral Distance (deg)'; ylabel 'Phase angle (Degrees)'; grid
