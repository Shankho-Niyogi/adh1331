% display the maximum amplitude of each trace in view (view_no)
if exist('view_no')~=1,
  view_no=1;
end
if view_no>=1 & view_no<=3,
  eval(['HEADER=header' num2str(view_no) ';']);
elseif view_no==0,
  eval('HEADER=Header;');
else
  disp('retry: view_no must be 0, 1, or 2');
  return
end

WIN_INDEX=HEADER(5,:);
OUTPUT=setstr(Station(1:10,WIN_INDEX)');
MAX_AMP=max(abs(data1));
MAX_P_TO_P=max(data1)-min(data1);
EPI_DIST=Delta(WIN_INDEX);
disp(' sta  chan  delta        max amplitude     peak-to-peak amp')
disp('')
for II=1:length(WIN_INDEX)
  disp(sprintf('%s %6.2f %20.10f %20.10f',OUTPUT(II,:), EPI_DIST(II), MAX_AMP(II), MAX_P_TO_P(II)))
end

H_TEMP=gcf;                                   % get handle for current figure
handles=get(0,'Children');
for iii=1:length(handles);
  if strcmp(get(handles(iii),'Name'),'Relative Amplitudes'),
    h_rel_amp=iii;
    iii=0;
    break
  end
end
if iii~=0,  % open a new plot window
  h_rel_amp=figure('NumberTitle','off','Name','Relative Amplitudes');
end
figure(h_rel_amp);  % make this the current figure

semilogy(EPI_DIST,MAX_P_TO_P,'o');            % plot amplitudes
xlabel('Epicentral Distance (deg)'); 
ylabel('Peak-to-Peak amplitude');
figure(H_TEMP);                               % make old figure current

clear HEADER WIN_INDEX OUTPUT MAX_AMP MAX_P_TO_P EPI_DIST II

