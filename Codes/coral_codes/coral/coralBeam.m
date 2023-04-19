function [stack,t] = coralBeam(data, opt);
%   coralBeam     stack data in the coral structure
% USAGE: [stack,t] = coralBeam(data, opt);
%
% 
% See coral for explanation of data structure
% opt is an optional structure with optional fields: 
% opt.tshift (time shift applied to data before stacking)
%
% OUTPUT:
% 
%  stack     column vector of stacked data
%  t         column vector of time starting at t=0;
%
% required fields of data: data, recSampInt, recNumData
%

% K. Creager  kcc@ess.washington.edu   10/18/2004

% initialize outputs
stack=[];
t=[];

ndata  = length(data); % number of seismograms

if ndata==0;  % no data entered so return
  return
end

% set defalut values for tshift
tshift   = zeros(ndata,1);  % default time shifts 
flds      = {'tshift'};
% if values are passed in throught 'opt' change them from their defaults
if nargin >1;
  if isstruct(opt);
    for k=1:length(flds);
      fld = flds{k};
      if any(strcmp(fields(opt),fld));
        eval(sprintf('%s=opt.%s;',fld,fld));
      end
    end
  end
end

numData = median([data.recNumData]);
sampInt = median([data.recSampInt]);
tshift  = tshift(:)';
opts.absStartTime = timeadd([data.recStartTime],-(tshift-max(tshift)));   
opts.absEndTime   = timeadd([data.recStartTime],-(tshift-min(tshift))+(numData-1)*sampInt);
opts.cutType      = 'absTime';          
[data, ierr, opts] = coralCut(data, opts);

stack=data(1).data*0;  
for k=1:ndata; 
  tmp = demean(data(k).data);
  tmp1 = tmp/(max(tmp)-min(tmp));
  stack=stack + tmp1;
end
stack=stack/ndata;
t=[0:length(stack)-1]'*data(1).recSampInt;

return

% pad stack evently at beginning and end stack to be same length as other data
ndiff = numData - length(stack);
if ndiff>0;
  stack=taperd(stack,.05);  % first taper it to 0 at ends
  nstart = round(max(tshift)/sampInt);
  %nstart = floor(ndiff/2); 
  nend = numData - nstart -length(stack);
  stack = [ zeros(nstart,1); stack; zeros(nend,1) ];
  if nstart<0; stack = stack(1-nstart:end); end
  if nend  <0; stack = stack(1:end+nend); end
end
t=[0:length(stack)-1]'*data(1).recSampInt;
  
