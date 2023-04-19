[FID,MESSAGE]=fopen('sta_list','r');
if length(MESSAGE)>0,       % open file
  disp(MESSAGE);
  return
end
S = fscanf(FID,'%c');       % read in entire file of station names
fclose(FID);                % close file
S=S(find(abs(S)~=10));      % remove all carriage returns
CURRENT_DIR=pwd;
DATA_DIR=input('enter directory containing the AH files :','s');
eval (['cd ' DATA_DIR])
eval( ['!cat ' S ' > ' CURRENT_DIR '/temp.ah'] ) ; 
eval (['cd ' CURRENT_DIR])
clear TEMP FID MESSAGE CURRENT_DIR DATA_DIR




