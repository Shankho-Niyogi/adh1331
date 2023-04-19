function [C,ierr] = refl_coeff_fl_sol(a,b,rho,p);
% refl_coeff_fl_sol - Compute all reflection/transmission coefficients for a liquid-solid interface
%                     (e.g. the Inner Core Boundary)
%
% USAGE: [C,ierr] = refl_coeff_fl_sol(a,b,rho,p);
%
% Input Parameters:
%  a(2): P-wave velocities above(1) and below(2) discontinuity (km/s)
%  b(2): S-wave velocities above(1) and below(2) discontinuity (km/s) - set zero for liquid
%
%	 (NOTE: b(1) MUST be set equal to zero!!!)
%
%  rho(2): Density above(1) and below(2)  (g/cc) 
%  p: ray parameter (column vector, flat earth) (s/km)
%
% Output Parameters:
%  C:  structure of reflection and transmission coefficients containing column vectors 
%    with a value for each input ray parameter.  These coefficients are for 
%    displacement potentials using the sign conventions of Aki and Richards, 1980.
%
%    C.PdownPup,     C.PupPup,    C.SupPup
%    C.PdownPdown,   C.PupPdown,  C.SupPdown
%    C.PdownSdown,   C.PupSdown,  C.SupSdown
%
%
% Note:  This code handles critical angles, seemingly just fine. However, if you
%        wish the code not to return values of reflection and transmission coefficients
%        for post-critical angles then you need to remove some comment symbols from
%        in front of some lines of code 
%
%    
%   coded originally by J. Revenaugh in c
%   matlab version by K. Creager (6/99)
%   modified by A. Ouzounis (3/00)
%
% Intermediate Results:
%
%    SS: Matrix of scattering coefficients.
%    columns are incident wave, rows are reflected/transmitted
%    column 1 is downgoing P
%    column 2 is upgoing P
%    column 3 is upgoing S
%    row 1 is upgoing P
%    row 2 is downgoing P
%    row 3 is downgoing S
%
%    e.g. The reflection coefficient of PKiKP is SS(1,1) = PdownPup

ierr = 0;

pp   = p(:);    % make sure ray parameter is a column vector
n=length(pp);   % number of ray parameters

r1=rho(1); r2=rho(2); % density (g/cc)
a1=a(1);   a2=a(2);   % compressional velocities (km/s)
b1=b(1);   b2=b(2);   % shear velocity (km/s)

sini = [p*a1 , p*a2];   % sin of ray angles for p waves  (n,2) matrix for down and up going rays
%if any(abs(sini(:)) > 1); ierr=-1; end
cosi = sqrt(1-sini.*sini);  % cos of ray angles for p waves (n,2) matrix

sinj = [p*b1 , p*b2];   % sin of ray angles for s waves (n,2) matrix for down and up going rays
			% REMEMBER HERE THAT b(1) IS SUPPOSED TO BE ZERO!!

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
    sj2   = sinj(i,2);
    cj2   = cosj(i,2);
    gamma2= 1 - 2*b2*b2*p*p;
  
    M= [ -ci1            ,      -ci2         ,   sj2
           0             , -2*r2*b2*b2*p*ci2 , -r2*b2*gamma2
          r1*a1          ,   -r2*a2*gamma2   ,  2*r2*b2*b2*p*cj2     ];

    N      =  M;
    N(3,:) = -M(3,:);
    SS = inv(M)*N;   % Compute the inverse of M and the product MinvN
    SSS(:,:,i)=SS;
%  end
  
end

tmp = [SSS(1,1,:)]; C.PdownPup   = tmp(:);
tmp = [SSS(1,2,:)]; C.PupPup     = tmp(:);
tmp = [SSS(1,3,:)]; C.SupPup     = tmp(:);

tmp = [SSS(2,1,:)]; C.PdownPdown = tmp(:);
tmp = [SSS(2,2,:)]; C.PupPdown   = tmp(:);
tmp = [SSS(2,3,:)]; C.SupPdown   = tmp(:);

tmp = [SSS(3,1,:)]; C.PdownSdown = tmp(:);
tmp = [SSS(3,2,:)]; C.PupSdown   = tmp(:);
tmp = [SSS(3,3,:)]; C.SupSdown   = tmp(:);

return
