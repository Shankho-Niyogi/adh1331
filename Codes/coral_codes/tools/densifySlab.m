function [newSlab,newSlabKey] = densifySlab(slab,slabKey,scaleFactor)
% 
% usage: [newSlab,newSlabKey] = densifySlab(slab,slabKey,scaleFactor);
% 
% Crudely resamples a slab matrix by linearly interpolating between
% adjacent points on a contour. The scale factor determines how many
% poits will be interpolated between the two samples and must be a 
% power of 2.
% 
% See also: loadSlab, plotSlab

if nargin < 2
  numIterations = 1;
else
  numIterations = log2(scaleFactor);
  if (numIterations-round(numIterations))
	error('scaleFactor must be an integral power of 2');
  end
end
  
for i = 1:numIterations
  [sR,sC] = size(slab);
  [skR,skC] = size(slabKey);
  endKey = [slabKey(2:skR,2)-1;sR];
  newSlab = [];
  newSlabKey = [];
  for i = 1:skR
	lon = slab(slabKey(i,2):endKey(i),1);
	lenLon = length(lon);
	lonBar = (lon(1:lenLon-1) + lon(2:lenLon))/2;
	lat = slab(slabKey(i,2):endKey(i),2);
	latBar = (lat(1:lenLon-1) + lat(2:lenLon))/2;
	lon2 = [];
	lat2 = [];
	for j = 1:lenLon-1
	  lon2 = [lon2;lon(j);lonBar(j)];
	  lat2 = [lat2;lat(j);latBar(j)];
	end
	lon2 = [lon2;lon(lenLon)];
	lat2 = [lat2;lat(lenLon)];
	newLen = length(lon2);
	newSlab = [newSlab; lon2 lat2 slab(slabKey(i,2),3)*ones(newLen,1)];
	newSlabKey = [newSlabKey;slab(slabKey(i,2),3) newLen ];
  end
  newSlabKey = [newSlabKey(:,1) [1;cumsum(newSlabKey(1:skR-1,2))+1] ];
  slab = newSlab;
  slabKey = newSlabKey;
end
