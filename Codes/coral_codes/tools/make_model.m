function [r,pvel,svel,density,qp,qs,qk] = make_model(del,model_name,directory);
%   make_model    evaluate a radial earth model at evently spaced points
% USAGE: [r,pvel,svel,density,qp,qs,qk] = make_model(del,model_name,directory);
% 
% del        approximate sample interval (km) for model
%            specify one number for same spacing in all layers
%            or a column vector for different spacing in each layer (start at center)
% model_name string specifying desired model (default is 'ak135')
%            other models are iasp91 and prem
% directory  optional string specifying path to model files
%            see mod_eval for details
%
% modified by KCC  6/7/00

global Modrad

% initialize model to get the global variable Modrad 
% which contains the radii of the discontinuities
if nargin <= 1
  mod_eval(0);
elseif nargin <= 2; 
  mod_eval(0,model_name);
else
  mod_eval(0,model_name,directory);
end

Nlayer=length(Modrad);      % number of layers in model
if length(del)==1;
  del=del+zeros(Nlayer,1);  
elseif length(del)<Nlayer
  disp(sprintf('Error in make_model: number of requested layers (%d) must be >= number of model layers(%d)',length(del),Nlayer'))
  return
end

r_disc = 1e-6;             % move 1 mm off discontinuity
r=[];                      % initialize vector of radii
R=[];                      % initialize vector of radii
for i=1:Nlayer             % loop over each major layer
  if i==1,                 % r0 is radius at bottom of layer
    r0=r_disc;
  else
    r0=Modrad(i-1);
  end
  r1     = Modrad(i);            % r1 is radius at top of layer
  n      = ceil((r1-r0)/del(i)); % number of sample points within the layer
  delr   = (r1-r0)/n;            % sample interval
  rr     = [0:n]'*delr + r0;     % radii in this layer
  r      = [r;rr];               % add to radii for output
  rr(1)  = rr(1)+r_disc;         % move off discontinuities
  rr(end)= rr(end)-r_disc;
  R      = [R;rr];               % add to radii for evaluating model
end

r =flipud(r);  % flip radius vector to start at surface of earth and go down
R =flipud(R);  % flip radius vector to start at surface of earth and go down

%evaluate model at these radii that are r_disc off the discontinuities
if nargin <= 1
  [pvel,svel,density,qp,qs,qk] = mod_eval(R);
elseif nargin <= 2; 
  [pvel,svel,density,qp,qs,qk] = mod_eval(R,model_name);
else
  [pvel,svel,density,qp,qs,qk] = mod_eval(R,model_name,directory);
end

% find index to places where the radius and each of the parameters 
% changes by less than 1e-4 and remove this point from the model
% this may represent a place where the properties have a change in
% derivitives but no discontinuity in properties
k = find(all(abs(diff([r,pvel,svel,density,qp,qs,qk]))' < 1e-4));
if length(k)>0;
  r(k)      =[];
  pvel(k)   =[];
  svel(k)   =[];
  density(k)=[];
  qp(k)     =[];
  qs(k)     =[];
  qk(k)     =[];
end

