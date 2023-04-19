function [slab,slabKey] = loadSlab(fileNameString);
% 
% usage: [slab,slabKey] = loadSlab(fileNameString);
% 
% Loads one of Oli Gudmundsson's (oli@rses.anu.edu.au) slab contour files
% into the Nx3 matrix "slab" where N is the total number of points in all
% of the contours.
% 										
% Input arguments:
% 
%     fileNameString:  the name of the slab file to read. Acceptable slab
%                      file names are:
%                      aleutians assam camerica caribbean ephilippines 
%                      halmahera hellas hindu1 hindu2 indonesia italia luzon 
%                      marjapkur mindanao molucca nbritain ryukyus samerica 
%                      solomons ssandwich sulawesi tonga vanuatu wphilippines
% 										
% Return values:
% 										
%     slab: an Nx3 matrix whos rows consist of the follow 3 elements:
%              longitude    latitude    depth  
% 
%     slabKey: a 2 column matrix which keys the rows of the slab matrix.
%              Column 1 gives the slab depth and column 2 gives the row 
%              number at which that depth begins.
% 
% See also: densifySlab, plotSlab


slabDirectory = '/u0/iris/MATLAB/slabs/';
fileNameString = [slabDirectory,fileNameString,'.slb'];
fid = fopen(fileNameString,'r');

slab = [];
slabKey = [];
eofstat = feof(fid);
slabName = fgetl(fid);
while (~eofstat);
  nptsStr = fgetl(fid);
  eofstat = feof(fid);
  if (~eofstat)
	npts = str2num(nptsStr);
	for i = 1:npts
	  line = fgetl(fid);
	  tmp = sscanf(line,'%f');
	  slab = [slab;tmp'];
	  if i == 1
	    slabKey = [slabKey;tmp(3) npts];
	  end
	end
  end
end
slab = slab(:,1:3);
[sR,sC] = size(slabKey);
slabKey = [slabKey(:,1) [1;cumsum(slabKey(1:sR-1,2))+1]];
fclose(fid);
