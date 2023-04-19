function [pvel,svel,density,qp,qs,qk] = mod_eval(r,model_name,directory);
%   mod_eval      evaluate a radial earth model
% USAGE: [pvel,svel,density,qp,qs,qk] = mod_eval(r,model_name,directory);
% Evaluate the velocity, density, and Q structure of a radial earth model.
% r is an input vector of radii (km) from the center of the earth.
% model_name is the name of the model to be evaluated.  This defaults
% to model ak135.
% The following 6 vectors are returned with the same dimensions as r:
% compressional velocity (km/s), shear wave velocity (km/s), density
% (g/cm^3), and three dimensionless quality (attenuation) factors.
% qp is Q for compressional body waves, qs is Q for shear waves, and
% qk is Qkappa for pure compression.
% written by Ken Creager 11/10/96

% Models are read from an ascii file containing the model name and number of 
% layers in the first line.  One line per layer follows, starting at the 
% center of the earth.  The 10 columns on each line contain layer number, 
% radius(km), density (g/cm^3), vp, vp, vs, vs, 1.0, 1/Qmu, 1/Qkappa.
% A discontinuity is given by 2 lines at the same radius.  Between 
% discontinuities the values are interpolated using cubic splines.

% If the file has not been previously read then read the file and 
% and calculate all the spline coefficients.  Store them in global
% variables.

global Modrad PP_VP PP_VS PP_RHO PP_QK PP_QS PP_IND Modname

if nargin<2,                      % default model name is ak135
  model_name='ak135';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  if model has not been read, read it and calculate spline coefficients   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~strcmp(model_name,Modname), 
  
  if nargin<3,                    % find the tau_p directory that contains the ascii model files
    directory = which('get_ttt'); % directory containing the code for get_ttt
    iind=findstr('matlab/get_ttt.m',directory);
    directory = directory(1:iind-2); % directory containing m*.mod ascii model files
  end

  in_file=[directory '/m' model_name '.mod'];            % specify file name
  disp(['reading model from ' in_file])
  [fid,fmessage]=fopen(in_file,'r');                     % open file
  if length(fmessage>0), 
    disp(fmessage); 
    return
  end
  Modname=fscanf(fid,'%s',1);                            % read model name
  N=fscanf(fid,'%f',1);                                  % read number of layers
  temp=fscanf(fid,'%f',[10,N])';                         % read in whole model
  fclose(fid);                                           % close file

  rad=temp(:,2);rho=temp(:,3);vp=temp(:,4);vs=temp(:,6);
  qs=temp(:,9);qk=temp(:,10);
  disc_ind=find(diff(rad)==0);                           % find indices of discontinuities
  Nlayer=length(disc_ind)+1;                             % number of layers

  PP_RHO=[]; PP_VP =[]; PP_VS =[]; PP_QK=[]; PP_QS=[];   % initialize spline coefficients

  for i=1:Nlayer                                         % loop over layers
    if     i==1, 
      ibot=1;                itop=disc_ind(i);
    elseif i==Nlayer
      ibot=disc_ind(i-1)+1;  itop=N;
    else
      ibot=disc_ind(i-1)+1;  itop=disc_ind(i);
    end
  
    j=ibot:itop;                                         % indices of points within the layer
    R=rad(j);  RHO=rho(j);  VP=vp(j); VS=vs(j);          % vectors of values within the layer
    QK=qk(j); QS=qs(j);

    r_bot(i)=rad(j(1));
    r_top(i)=rad(max(j));

    pp=spline(R,RHO);                                    % calculate spline coefficients
    PP_RHO=[PP_RHO,pp];                                  % save spline coefficients
    pp=spline(R,VP );
    PP_VP =[PP_VP ,pp];
    pp=spline(R,VS );
    PP_VS =[PP_VS ,pp];
    pp=spline(R,QK );
    PP_QK =[PP_QK ,pp];
    pp=spline(R,QS );
    PP_QS =[PP_QS ,pp];
    pp_ind(i)=length(pp);

  end
  PP_IND=zeros(Nlayer,2);                               % index into spline coefficient vectors
  PP_IND(1,:)=[1,pp_ind(1)];
  for i=2:Nlayer
    PP_IND(i,1)=PP_IND(i-1,1)+pp_ind(i-1);
    PP_IND(i,2)=PP_IND(i-1,2)+pp_ind(i  );
  end 
  Modrad=r_top;                                         % radius at top of each layer

  clear N temp rad rho vp vs qk qs disc_ind Nlayer 
  clear i ibot itop j R RHO VP VS QK QS r_bot r_top pp pp_ind 

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  now use spline coefficients to evaluate model                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

radius=6371-1e-7;

% loop over each element in the vector r: i is the index of the appropriate shell
pvel=zeros(size(r));svel=pvel;              % initialize output vectors
density=pvel; qk=pvel;qs=pvel;
rr=min(r ,radius);                          % force radii between 0 and 6371
rr=max(rr,0);

% it is much more efficient to evaluate all parameters within a given layer at
% once, so loop over each layer (most models have about 10). k is an index 
% to the desired radii within the layer.  


for j=1:size(PP_IND,1),                     % loop over each layer
  if j==1;                             
    k=find(rr<Modrad(j));
  else
    k=find(rr<Modrad(j) & rr>=Modrad(j-1));
  end
  if length(k)>0, 
    rrr=rr(k);
    jj=PP_IND(j,1):PP_IND(j,2);
    pvel(k)   =ppval(PP_VP(jj),rrr);
    svel(k)   =ppval(PP_VS(jj),rrr);
    density(k)=ppval(PP_RHO(jj),rrr);
    qk(k)     =ppval(PP_QK(jj),rrr);
    qs(k)     =ppval(PP_QS(jj),rrr);
  end
end

%  now evaluate quality factor for compressional waves from
%  quality factor for pure shear and pure compression

vratio=svel./pvel;
b=(4/3)*(vratio.*vratio);
qp = qk.*(1-b) + qs.*b;

qs=1./(qs+1e-99);  % qs,qp,qk are quality factors (they are read in as
qp=1./(qp+1e-99);  % inverse quality factors)
qk=1./(qk+1e-99);

