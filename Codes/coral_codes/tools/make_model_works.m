function [r,vp,vs,rho]=make_model(del, model_name);
%   make_model    evaluate a radial earth model at evently spaced points
% Usage: [r,vp,vs,rho]=make_model(del, model_name);
% 
% del is the approximate spacing for sampling the model.
% model_name is a string which gives the name of the model to be 
% evaluated. Acceptable values are 'ak135' (default), 'iasp91',
% and 'prem'.

if nargin < 2
  model_name = 'ak135';
end

global Modrad
mod_eval(0, model_name);    % initialize model
Nlayer=length(Modrad);      % number of layers in model
r=[];vp=[];vs=[];rho=[];    % initialize r, vp, vs, rho;
for i=1:Nlayer              % loop over each major layer
  if i==1,                  % r0 is radius at bottom of layer
    r0=del;
  else
    r0=Modrad(i-1);
  end
  r1=Modrad(i);            % r1 is radius at top of layer
  n=ceil((r1-r0)/del);     % number of sample points within the layer
  delr=(r1-r0)/n;          % sample interval
  rr=[0:n]'*delr + r0;     % radii in this layer
  rrr=rr;
  rrr(1)=rr(1)+.000001;    % move off discontinuity
  rrr(n+1)=rrr(n+1)-.000001;
  % if top of layer does not represent a first order discontinuity 
  % do not repeat this depth
  if i~=Nlayer,
    if abs(diff(mod_eval(r1+[-.00001 .00001], model_name)))<.0000001,
      rrr=rrr(1:n);
      rr=rr(1:n);
    end
  end
  [vp0,vs0,rho0] = mod_eval(rrr, model_name); % evaluate model in this layer
  r=[r;rr];
  vp=[vp;vp0];
  vs=[vs;vs0];
  rho=[rho;rho0];
end

% flip all vectors upside down so they start at the surface of the earth
r  =flipud(r);
vp =flipud(vp);
vs =flipud(vs);
rho=flipud(rho);

