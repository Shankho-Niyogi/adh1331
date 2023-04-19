function pptim=pptime(depth);
%   pptime        calculate very approximate pP-P times
% usage: pptim=pptime(depth);
%  this function returns the JB pP-P time (sec) for an epicentral
%  distance of 100 degrees and any depth.  This is also a very crude
%  estimate of the pPKP-PKP times for all branches of PKP.  Errors
%  resulting in interpreting these times for PKP can be as large as
%  10 sec for deep-focus earthquakes, but should not exceed 1 s
%  for shallow-focus events.

t=[      0.,11.,26.,41.,55.,69.,83.,96.,108.,120.,131.,143.,153.,163.]';
d=[-.005207,.00,.01,.02,.03,.04,.05,.06, .07, .08, .09, .10, .11, .12]';
r=(depth-33)/(6371-33);
[n,m]=size(depth);pptime=zeros(n,m);
for j=1:length(r);
  i=min(find(r(j)<d));
  pptim(j)=t(i-1)+(t(i)-t(i-1))*(r(j)-d(i-1))/(d(i)-d(i-1));
end

