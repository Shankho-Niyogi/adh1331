function h = coralPlot(data, opt);
%   coralPlot    plot data in coral structure
% USAGE: h = coralPlot(data, opt);
%
% opt is a structure containing the following optional arguments:
% opt.y_offset  vector of y-offsets for each seismogram.
%               if this is epicentral distance then plot is a record section
%               default is evently spaced
% opt.tshift    is a vector of time shifts for each seismogram, relative to the first
%               sample of each seismogram
% opt.scal      is a number that scales the peak-to-peak amplitude of each seismogram.
%               
% See coral for explanation of structure: data
%
% OUTPUT: 
% 
%  h           is a vector of plot handles for each seismogram.
%
% K. Creager  kcc@ess.washington.edu   10/18/2004

ndata  = length(data);

% set defalut values for offset and scal
y_offset = -[0:1:ndata-1]'; % default value for plotting each seismogram 
tshift   = zeros(ndata,1);  % default time shifts 
scal     = 1;               % default value for scaling seismograms
flds     = {'y_offset' , 'tshift' , 'scal'};
% if values are passed in through 'opt' change them from their defaults
if nargin == 2;
  if isstruct(opt);
    for k=1:length(flds);
      fld = flds{k};
      if any(strcmp(fields(opt),fld));
        eval(sprintf('%s=opt.%s;',fld,fld));
      end
    end
  end
end

for k=1:ndata
  tmp = data(k).data; 
  if length(tmp)==0;
    h(k)=NaN;
  else
    if scal>0;
      tmp1=tmp/(max(tmp)-min(tmp));
    else
      tmp1=tmp;
    end
    t = [0:length(tmp1)-1]'*data(k).recSampInt  +  tshift(k);
    h(k) = plot(t,tmp1*abs(scal) + y_offset(k),'-k');
    hold on;
  end
  %text(12,-1*(k-1),sprintf('Amp=%5d',round((max(tmp)-min(tmp))))); 
end
