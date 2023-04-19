function ml2ah(Station,Loc,Calib,Comment,Record,Extras,Data,ah_out_filename);
%   ml2ah         write matlab formatted waveform data to an AH file
% USAGE: ml2ah(Station,Loc,Calib,Comment,Record,Extras,Data,ah_out_filename);
%
% write data stored in the arrays Station,Loc,Calib,Comment,Record,
% Extras,Data into the ah file named ah_out_filename
%   
% see coral/ah2ml.man for a description of the relation between these arrays 
% and the ah headers.

% K. Creager, April 1, 1996

SS        =setstr(Station);
CC        =setstr(Comment);
ORIG_TIME =time_reformat(Loc(7:8,:));
START_TIME=time_reformat(Record(1:2,:));

asc_filename=[ah_out_filename '.temp'];
[fid,fmessage]=fopen(asc_filename,'w');  % open temporary ascii ah output file
if length(fmessage)>0,
  disp(fmessage)
end
for i=1:size(Data,2);                    % loop over all waveforms
  disp(sprintf('Writing data to trace %d...', i))
% write station information
  fprintf(fid,'%s\n','station information');
  fprintf(fid,'%s\t%s\n','code:',      SS( 1: 6,i));
  fprintf(fid,'%s\t%s\n','channel:',   SS( 7:12,i));
  fprintf(fid,'%s\t%s\n','type:',      SS(13:20,i));
  fprintf(fid,'%s\t %f\n','latitude:',  Loc(1,i));
  fprintf(fid,'%s\t %f\n','longitude:', Loc(2,i));
  fprintf(fid,'%s\t %f\n','elevation:', Loc(3,i));
 
% write station response information
  fprintf(fid,'%s\t %f\n','gain:',         Calib(2,i));
  fprintf(fid,'%s\t %f\n','normalization:', Calib(1,i));
  fprintf(fid,'%s\n','calibration information');
  fprintf(fid,'%s\t %s\t %s\t %s\n','pole.re','pole.im','zero.re','zero.im');
  fprintf(fid,'%f\t %f\t %f\t %f\n', real(Calib(3,i)), 0, real(Calib(33,i)), 0);
  for j=4:32
    fprintf(fid,'%f\t %f\t %f\t %f\n', real(Calib(j,i)), imag(Calib(j,i)), ...
                                       real(Calib(j+30,i)), imag(Calib(j+30,i)));
  end

% write event information
  fprintf(fid,'%s\n','event information');
  fprintf(fid,'%s\t %f\n','latitude:',  Loc(4,i));
  fprintf(fid,'%s\t %f\n','longitude:', Loc(5,i));
  fprintf(fid,'%s\t %f\n','elevation:', Loc(6,i));
  fprintf(fid,'%s\t %d\t %d\t %d\t %d\t %d\t %10.5f\n','origin_time:',ORIG_TIME(:,i));
  fprintf(fid,'%s\t %s\n','comment:', CC(1:80,i));

% write record information
  fprintf(fid,'%s\n','record information');
  fprintf(fid,'%s\t %d\n','type:',  1);
  fprintf(fid,'%s\t %d\n','ndata:', Record(3,i));
  fprintf(fid,'%s\t %d\n','delta:', Record(4,i));
  fprintf(fid,'%s\t %f\n','max_amplitude:', Record(5,i));
  fprintf(fid,'%s\t %d\t %d\t %d\t %d\t %d\t %10.5f\n','start_time:',START_TIME(:,i));
  fprintf(fid,'%s\t %f\n','abscissa_min:', Record(6,i));
  fprintf(fid,'%s\t %s\n','comment:',CC(81:160,i));
  fprintf(fid,'%s\t %s\n','log:',    CC(161:362,i));
 
% write extras 
  fprintf(fid,'%s\n','extras:');
  fprintf(fid,'%d:\t %f\n', [0:20 ; Extras(:,1)'] );

% write data
  fprintf(fid,'%s\n','data:');
  fprintf(fid,'%g\n',Data(1:Record(3,i),i));

end  
fclose(fid);    % close ascii output file

disp('converting ascii to binary ah file...')
%  convert ascii format to binary format
temp=['!asc2ah < ' asc_filename ' |ah2asc|asc2ah > ' ah_out_filename '; /bin/rm ' asc_filename];
eval(temp)
