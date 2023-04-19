function plgndr = plegendre(l,m,x);
%   plegendre     associated legendre function
% USAGE: plgndr = plegendre(l,m,x);
%       Calculate the associated legendre function for scalar values 
%       of l and m, and a vector of x.  Use the algorithm given in
%       Numerical Recipies, 1986, section 6.6.  (x=cos(theta)).
%       x may be a column or row vector. 
%       plgndr is a column vector.
%       See also matlab function 'legendre'

%       K. Creager 4/31/93.
%       Geophysics Program, Univ. of Washington

if m<0 | m>l | max(abs(x))>1, 
  disp('arguments out of range in plegendre');
  return
end

n=length(x);                     % n=length of input vector
x=x(:)';                         % make x a row vector

if m==0,
  pmm=ones(1,n);
else
  somx2=sqrt((1-x).*(1+x));
  xx=vec2mat(-somx2',m)';
  fact=vec2mat([1:2:2*m-1]',n);
  pmm=xx.*fact;
  if m>1, pmm=prod(xx.*fact); end
end

if l==m;
  plgndr=pmm;
else 
  pmmp1=x.*pmm*(2*m+1);
  if l==m+1;
    plgndr=pmmp1;
  else
    for ll=m+2:l;
      pll=(x.*pmmp1*(2*ll-1) - (ll+m-1)*pmm)/(ll-m);
      pmm=pmmp1;
      pmmp1=pll;
    end
    plgndr=pll;
  end
end
plgndr=plgndr';
