function a=euler_trans(phi,theta,psi);
%   euler_trans   Euler Transform rotation matrix
% usage: a=euler_trans(phi,theta,psi);
%
%  euler_trans - transformation matrix for coordinate rotation
%  transformation matrix for an arbitrary coordinate rotation specified
%  in terms of the eulerian angles.  conventions used are those of
%  goldstein, classical mechanics, 1959, chapter 4.
%
%  phi,theta,psi must be scalars, output is a 3x3 rotation matrix 
%  see also rot and scrot


cf = cos(phi);
sf = sin(phi);
ct = cos(theta);
st = sin(theta);
cs = cos(psi);
ss = sin(psi);
ctsf = ct*sf;
ctcf = ct*cf;
a = [ cs*cf-ctsf*ss   ,  cs*sf+ctcf*ss  ,  ss*st;
     -ss*cf-ctsf*cs   , -ss*sf+ctcf*cs  ,  cs*st;
      st*sf           , -st*cf          ,  ct    ];
