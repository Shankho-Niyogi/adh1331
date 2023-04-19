WIN_INDEX=header1(5,:);
TEMP=setstr(Station(1:6,WIN_INDEX)');
[FID,MESSAGE]=fopen('sta_list','w');
if length(MESSAGE)>0,
  disp(MESSAGE);
  return
end
for i=1:size(TEMP,1);
  fprintf(FID,'%s\n',TEMP(i,:));
end;
fclose(FID);

%TEMP=reshape(TEMP',1,size(OUTPUT,1)*size(OUTPUT,2));

clear WIN_INDEX TEMP FID MESSAGE




