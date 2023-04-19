function richmag(pfile)
% RICHMAG       Richter Magnitude Determination Program
% "richmag" function gives a user a unique opportunity to determine
% the Richter scale magnitude for given earthquake using the broad-band 
% data obtained by the WRSN broad-band instruments. Currently it includes
% stations: LON, LTY, SSW, TTW 
% usage: richmag 93102435451o ( where the pased argument is the pfile)
% Note: the pfile has to be in the current directory
% You can use "getp" to get the pickfile into your directory
% uses: "bb_magn", "wamagnitude", "obtdata"
% written by Gia Khazaradze			July 22, 1994
% Modified on Oct 30, 1994
if ~exist(pfile)
	'Pickfile does not exist in the current directory, Copy it from ~seis/P/YYMM,                 And try RICHMAG again'
else
      x=input('Do you already have data in TmpDir? y/n: ','s');
        if x=='n' | x=='N'
            eval(['!obtdata ' pfile]);          % shell script "obtdata"
	end

eval(['!cp ',pfile,' TmpDir/.']);
eval('cd TmpDir')
 
% Following six lines enable the user to save obtained synthetic seismograms
% If you find it inconvenient, you can comment them out
 
global PLOS SAVD;       % declare global variable used by "synthwa.m"
PLOS = input('Would you like to DISPLAY "synthetic" seismograms? y/n: ','s');
disp('');
% SAVD = input('Would you like to SAVE "synthetic" seismograms in Matlab binary format? y/n: ','s');

ST_LIST=str2mat('GNW','LON','LTY','RWW','SSW','TTW');
N=size(ST_LIST,1);			% number of BB stations
fname=sscanf(pfile,'%10s%2*c ');        % get first 10 characters from pfile
tale=['.','   ','.','BH ','.','ah'];    % data file AH format
 
% the following lines include manipulations with the data file names for
% each station and component, in order to match the names with the file
% names in TmpDir. So that function "synthwa" can receive appropriate name
 
for j=length(tale):length(tale)+length(fname),
	fname(j)=tale(j-10); 
end

for i=1:N,
  fname(12:14)=ST_LIST(i,:);           	% assigning station name
  ahfile_n=fname;
  ahfile_n(18)='N';                    	% assigning comp. "N"
  ahfile_e=fname;
  ahfile_e(18)='E';                    	% assigning comp. "E"
  amp(i) = bb_magn(ahfile_n, ahfile_e);	% calling Matlab function "bb_magn"
  amp=amp';
end 					% end loop through the stations
eval(['save waampl.dat amp -ascii']);


eval('!echo >> wamagn.dat');		% to create a file "wamagn.dat"
eval(['!wamagnitude ',pfile]);		% calling C program "wamagnitude" 
eval('cd ..')                           % return back to home directory
x = input('Do you want to SAVE data in TmpDir? y/n: ','s');
if x=='n'|x=='N'
     eval('!/usr/bin/mv TmpDir/wa*.dat .');	
     eval('!/usr/bin/mv TmpDir/*ps .');
     eval('!/usr/bin/rm -r TmpDir');
     close all;
end
end	% the outermost loop (exist pfile or not)
