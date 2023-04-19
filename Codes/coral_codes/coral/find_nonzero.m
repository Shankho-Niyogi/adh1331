function [istart,iend]=find_nonzero(header);
%   find_nonzero  find first and last non zeros in coral data
% USAGE: [istart,iend]=find_nonzero(header);
% determine the indices of the first and last non-zero data points
% in a data array as defined in the header.  
% header is a matrix with one column per seismogram
% istart and iend are row vectors with one element each per seismogram
% see update_data for a description of 'header'

istart = round( header(3,:)./header(6,:) )+1;
iend   = round( header(4,:)./header(6,:) )+1;
