function u = moment_mag( cmt )
%   moment_mag    used for Richter magnitude? 
% input arguments:
%
% cmt:      the Harvard centroid moment tensor given in vector form:
%           [ mrr mss mee mrs mre mse ].
%
% theta:    a vector giving the desired takeoff angles
%	    (in degrees) measured from the downward vertical. 
%
% phi:      a vector giving the azimuthal angles (in degrees) which
%	    correspond to the take off angles given in theta. Note
%           that theta and phi must be of the same length.
%
% plotsel:  1 = P wave, 2 = SV wave, 3 = SH wave, 4 = all.
%
%
% radpattern scales the cmt by its scalar moment, converts the cmt
% to ray coordinates, and returns the radiation (displacement) pattern
% vector u for the wave type specified by plotsel for the specified
% takeoff and azimuthal angles. If plotsel = 4 then a length(theta) x 3
% matrix is returned with uP, uSV and uSH in columns 1,2 and 3
% respectively.

% n.b. In the following calculations the axis (x=N, y=E, z=Down) and
% sign conventions of Aki & Richards, Quantitative Seismology, v1,
% pp. 114-118, have been used.

% construct moment tensor m in ray coordinates, scale m by scalar moment m0 

m0=
m = [ cmt(2) -cmt(6)  cmt(4)
     -cmt(6)  cmt(3) -cmt(5)
      cmt(4) -cmt(5)  cmt(1) ];  

m0 = sqrt(trace(m*m)/2);
Mw= = (2/3) * log10(Mo) - 10.7
m = m / m0;

% for each value of theta and phi, construct local P-wave direction
% vector gamma, SV-wave direction vector sv and SH-wave direction vector sh
% (cf. Aki & Richards, v1., p. 115). then use converted m to construct 
% displacement magnitude matrices uP, uSV, and uSH.

rad = pi/180;
t = theta(:) * rad; p = phi(:) * rad;

gamma = [sin(t).*cos(p)  sin(t).*sin(p) cos(t)];
sv    = [cos(t).*cos(p) cos(t).*sin(p) -sin(t)];
sh    = [-sin(p) cos(p) zeros(size(p))];

for i = 1:length(t)
  if plotsel == 1	 			% P wave
	u(i)  = gamma(i,:) * m * gamma(i,:)';
  elseif plotsel == 2				% SV wave
	u(i) = sv(i,:) * m * gamma(i,:)';
  elseif plotsel == 3				% SH wave
	u(i) = sh(i,:) * m * gamma(i,:)';
  elseif plotsel == 4
	u(i,1)  = gamma(i,:) * m * gamma(i,:)';
	u(i,2) = sv(i,:) * m * gamma(i,:)';
	u(i,3) = sh(i,:) * m * gamma(i,:)';
  end
end
