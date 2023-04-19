function h_slab = plotSlab(slab, slabKey);
% 
% usage: h_slab = plotSlab(slab, slabKey);
% 
% Plots one of Oli Gudmundsson's (oli@rses.anu.edu.au) slab contour matrices
% 										
% Input arguments:
% 
%     slab: an Nx3 matrix whos rows consist of the follow 3 elements:
%              longitude    latitude    depth  
% 
%     slabKey: a 2 column matrix which keys the rows of the slab matrix.
%              Column 1 gives the slab depth and column 2 gives the row 
%              number at which that depth begins.
% 
% Return values:
% 
%     h_slab: the figure handles to the contour lines.
% 
% See also: loadSlab, densifySlab

[sR,sC] = size(slab);
numDepths = length(slabKey);
slabKey = [slabKey [slabKey(2:numDepths,2)-1;sR]];
h_slab = zeros(numDepths,1);
hold on;
for i = 1:numDepths
  col = 'r';
  ls = '-';
  if slabKey(i,1) == 0
	col = 'k';
  end
  if (rem(slabKey(i,1),100))			% depth is an odd multiple of 50
	col = 'b';
	ls = '--';
  end
  h_slab(i) = line('xdata', slab(slabKey(i,2):slabKey(i,3),1), ...
	               'ydata', slab(slabKey(i,2):slabKey(i,3),2), ...
				   'color', col, 'linestyle',ls);
end
