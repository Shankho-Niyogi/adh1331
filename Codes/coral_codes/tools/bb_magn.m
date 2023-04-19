function amp = bb_magn(ahfile_n, ahfile_e)
%   bb_magn       calculate Richter magnitude
% Function "bb_magn" is used by "richmag" and is linking
% function "synthwa" with the latter.
% pfile is a pickfile for a particular event (from ~seis/P)
%  Modified on June 15, 1994 

fid=fopen(ahfile_n);
if fid > 2,
     ampl1=feval('synthwa',ahfile_n); 	% call Matlab function "synthwa"
     fclose(fid);

else 
     ampl1=0;
end;


fid=fopen(ahfile_e);
if fid > 2,
    ampl2=feval('synthwa',ahfile_e);	% call Matlab function "synthwa"
    fclose(fid);
else 
     ampl2=0;
end;

amp=(ampl1+ampl2)/2;			% average of N-S and E-W amplitudes 
ampl1=0;
ampl2=0;
