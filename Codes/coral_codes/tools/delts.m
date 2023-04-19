function [delta,dtdd]=delts(edep,del,phase);
%   delts         read table of CMB, inner-core and turning-point PKP distances
% usage: [delta,dtdd]=delts(edep,del,phase);
%
% read table of CMB, inner-core and turning point distances as
% a function of event distance and depth for the PKP phases
%
% chose table for closest depth, and interpolate table in distance
%
% input parameters:
%   edep  =  event depth (km) (column vector)
%   del   =  epicentral distance (deg) (column vector)
%   phase =  PKP phase name (6 characters) (character matrix)
%
% output parameters:
%   delta =  matrix of six column vectors containing distances from event to: 
%            station, turning point, CMB entry point, CMB exit point,
%            ICB entry point, ICB exit point
%   dtdd  =  column vector of approximate ray parameters
%
% NOTE: This routine rereads the tables each time it is called. If possible
%       only call it once with a long column vector of ray pathes.
%
% needs mat file containing tables (deltable_pkp) and calls echo_ml

% read  4 arrays: ab,bc,df,map3, containing tables for the PKP phases and a map
%       to help in reading the tables.
% kdep and kphs are indices to point to the correct table depending on the event depth and phase.
% ll is the distance index used for interpolating tables in distance.
load deltable_pkp;

ndel=length(del);
delta=zeros(ndel,7);
for jj=1:ndel;
  kdep=round(edep(jj)/25)+1;
  phs=phase(jj,:);
  if     strcmp(phs,'PKP   ') | strcmp(phs,'PKIKP ') , kphs=1;
  elseif strcmp(phs,'PKP2  ') | strcmp(phs,'PKPAB ') , kphs=2;
  elseif strcmp(phs,'PKP1  ') | strcmp(phs,'PKPBC ') , kphs=3;
  else
    echo_ml(' phase must be 6 characters long and be one of')
    echo_ml(' PKP PKIKP PKP1 PKP2 PKPAB PKPBC')
    return
  end

  ind=[map3(kdep,kphs)+1:map3(kdep+1,kphs)];
  if kphs==1,
    dist=df(ind,1); dists=df(ind,:);
  elseif kphs==2,
    dist=ab(ind,1); dists=ab(ind,:);
  elseif kphs==3,
    dist=bc(ind,1); dists=bc(ind,:);
  end
  ll=max(find(dist<=del(jj)));
  fact=(del(jj)-dist(ll)) / (dist(ll+1)-dist(ll));
  delta(jj,:)=dists(ll,:) + fact*(dists(ll+1,:)-dists(ll,:));
  dtdd(jj)=(dists(ll+1,7)-dists(ll,7)) / (dists(ll+1,1)-dists(ll,1));
end
delta=delta(:,1:6);

