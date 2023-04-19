function [C,ierr] = refl_coeff_sol_sol(a,b,rho,p,DIS_DEP);
% refl_coeff_sol_sol - Compute all reflection/transmission coefficients for a solid-solid interface
%
%
% USAGE: [C,ierr] = refl_coeff_sol_sol(a,b,rho,p,DIS_DEP);
%
% Input Parameters:
%  a(2): P-wave velocities above(1) and below(2) discontinuity (km/s)
%  b(2): S-wave velocities above(1) and below(2) discontinuity (km/s)
%  rho(2): Density above(1) and below(2)  (g/cc) 
%  p: ray parameter (column vector, flat earth) (ATTENTION: s/deg !!!)
%  DIS_DEP: discontinuity depth (km)
%
% Output Parameters:
%  C:  structure of reflection and transmission coefficients containing column vectors 
%    with a value for each input ray parameter.  These coefficients are for 
%    displacement potentials using the sign conventions of Aki and Richards, 1980.
%
%    C.PdownPup,     C.SdownPup,   C.PupPup,    C.SupPup
%    C.PdownSup,     C.SdownSup,   C.PupSup,    C.SupSup
%    C.PdownPdown,   C.SdownPdown, C.PupPdown,  C.SupPdown
%    C.PdownSdown,   C.SdownSdown, C.PupSdown,  C.SupSdown
%
% Note:  This code handles critical angles, seemingly just fine. However, if you
%        wish the code not to return values of reflection and transmission coefficients
%        for post-critical angles then you need to remove some comment symbols from
%        in front of some lines of code 
%    
% Put together following Section 5.2.4 of Aki & Richards, by A. Ouzounis (Feb. 2001)



ierr = 0;
r = 6371-DIS_DEP;
p = p*180/pi/r;
pp   = p(:);    % make sure ray parameter is a column vector
n=length(pp);   % number of ray parameters

r1=rho(1); r2=rho(2); % density (g/cc)
a1=a(1);   a2=a(2);   % compressional velocities (km/s)
b1=b(1);   b2=b(2);   % shear velocity (km/s)

sini = [pp*a1 , pp*a2];   % sin of ray angles for p waves  (n,2) matrix for down and up going rays
%if any(abs(sini(:)) > 1); ierr=-1; end
cosi = sqrt(1-sini.*sini);  % cos of ray angles for p waves (n,2) matrix

sinj = [pp*b1 , pp*b2];   % sin of ray angles for s waves (n,2) matrix for down and up going rays

%if any(abs(sinj) > 1); ierr=-2; end
cosj = sqrt(1-sinj.*sinj);  % cos of ray angles for s waves (n,2) matrix

SSS=zeros(4,4,n)*NaN;

for i=1:n;       % loop over each ray parameter
  
%  if all( [sini(i,:) , sinj(i)] <= 1); % are all ray angles subcritical?
    p     = pp(i);
    si1   = sini(i,1); 
    ci1   = cosi(i,1); 
    si2   = sini(i,2); 
    ci2   = cosi(i,2);
    sj1   = sinj(i,1);
    cj1   = cosj(i,1);
    sj2   = sinj(i,2);
    cj2   = cosj(i,2);
  
    M= [ -a1*p                   ,    -cj1                ,     a2*p               ,     cj2
          ci1                    ,    -b1*p               ,     ci2                ,     b2*p
          2*r1*b1*b1*p*ci1       , r1*b1*(1-2*b1*b1*p*p)  ,  2*r2*b2*b2*p*ci2      , r2*b2*(1-2*b2*b2*p*p)
         -r1*a1*(1-2*b1*b1*p*p)  , 2*r1*b1*b1*p*cj1       , r2*a2*(1-2*b2*b2*p*p)  , -2*r2*b2*b2*p*cj2     ];

    N      =  M;
    N(1,:) = -M(1,:);
    N(4,:) = -M(4,:);
    SS = inv(M)*N;   % Compute the inverse of M and the product MinvN
    SSS(:,:,i)=SS;
%  end
  
end

tmp = [SSS(1,1,:)]; C.PdownPup   = tmp(:);
tmp = [SSS(1,2,:)]; C.SdownPup   = tmp(:);
tmp = [SSS(1,3,:)]; C.PupPup     = tmp(:);
tmp = [SSS(1,4,:)]; C.SupPup     = tmp(:);

tmp = [SSS(2,1,:)]; C.PdownSup   = tmp(:);
tmp = [SSS(2,2,:)]; C.SdownSup   = tmp(:);
tmp = [SSS(2,3,:)]; C.PupSup     = tmp(:);
tmp = [SSS(2,4,:)]; C.SupSup     = tmp(:);

tmp = [SSS(3,1,:)]; C.PdownPdown = tmp(:);
tmp = [SSS(3,2,:)]; C.SdownPdown = tmp(:);
tmp = [SSS(3,3,:)]; C.PupPdown   = tmp(:);
tmp = [SSS(3,4,:)]; C.SupPdown   = tmp(:);

tmp = [SSS(4,1,:)]; C.PdownSdown = tmp(:);
tmp = [SSS(4,2,:)]; C.SdownSdown = tmp(:);
tmp = [SSS(4,3,:)]; C.PupSdown   = tmp(:);
tmp = [SSS(4,4,:)]; C.SupSdown   = tmp(:);

return
