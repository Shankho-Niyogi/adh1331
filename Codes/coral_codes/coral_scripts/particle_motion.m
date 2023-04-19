% Coral Script to display particle motions in 2-D or 3-D 
% USAGE: eval STA='COL';particle_motion
% This example will plot the particle motions for the station COL.
% All three components of the data must be in data1 of coral, 
% and the channel names must each contain three upper case letters
% ending in Z, N, and E, or Z, R, and T.
% A menu bar named options allows you to change the plot to
% 3-D, or any of three 2-D views.  Redraw option redraws the particle 
% motions

% K. Creager 3/23/95

WIN_INDEX=header1(5,:);
STATIONS=left_justify(setstr(Station(1:6,WIN_INDEX)'));
if exist('STA')==1,                    % plot data for station STA
  STA=[STA blanks(6-length(STA))];
  INDEX=find(strcmp2(STATIONS,STA));
else;                                  % plot data for only existing station
  DUMMY=strcmp2(STATIONS,STA);
  if (max(DUMMY)~=1 | min(DUMMY)~=1),
    disp(' there are data for more than one station in data1')
    disp(' specify the station you want by setting STA=station_name and rerun')
    return
  end
  INDEX=1:length(WIN_INDEX);
end
INDEX1=WIN_INDEX(INDEX); 
CHANNEL=setstr(Station(10,INDEX1)');
s = 'dk = ceil(length(e)/1500); for k = 1:dk:length(e)';
s = [s 'set(plt,''xdata'',n(k),''ydata'',e(k),''zdata'',z(k)),'];
s = [s 'drawnow,end'];
if exist('h_pm')==1,
  figure(h_pm)
else
  view_pm='3D';
  h_pm=figure('Position',[910 480 360 480],'NumberTitle','off','Name','Particle Motion');
  options=uimenu('Label','Options');
  uimenu(options,'Label','Redraw','Callback',s);
  uimenu(options,'Label','3-D','Callback','view(3);view_pm=''3D'';');
  uimenu(options,'Label','R-Z(N-Z)','Callback','view(0,0);view_pm=''RZ'';axis(''equal'');axis(''square'')');
  uimenu(options,'Label','R-T(N-E)','Callback','view(0,90);view_pm=''RT'';axis(''equal'');axis(''square'')');
  uimenu(options,'Label','T-Z(E-Z)','Callback','view(90,0);view_pm=''TZ'';axis(''equal'');axis(''square'')');
end

% data1 should contain three components of data in any order
% the third element of the channel name must be E,N,Z for the three channels
% The sample interval is stored in header(6,1) (units of s).

clear e n z
for I=1:min(3,length(CHANNEL))
  if     CHANNEL(I)=='E' | CHANNEL(I)=='T'; e=data1(:,INDEX(I));
  elseif CHANNEL(I)=='N' | CHANNEL(I)=='R'; n=data1(:,INDEX(I));
  elseif CHANNEL(I)=='Z'; z=data1(:,INDEX(I));
  end
  if     CHANNEL(I)=='N'; xlabl='North-South';
  elseif CHANNEL(I)=='E'; ylabl='East-West';
  elseif CHANNEL(I)=='R'; xlabl='Radial';
  elseif CHANNEL(I)=='T'; ylabl='Transverse';
  end
  Sta_label=setstr(Station(1:6,INDEX1(I))');
end
if     exist('e')==0,
  disp(' no data for east-west channel, try again'); return
elseif exist('n')==0,
  disp(' no data for north-south channel, try again'); return
elseif exist('z')==0,
  disp(' no data for vertical channel, try again'); return
end    

delt = header1(6,INDEX(1));
t = delt*(1:length(e))';

% Plot particle motion in 3-D

plot3(n,e,z,'g')
SCAL=[min([e;n;z]) max([e;n;z])];
axis([SCAL SCAL SCAL])
set(gca,'box','on')
xlabel(xlabl)
ylabel(ylabl)
zlabel('Vertical')
title([Sta_label '  Particle Motion']);
hold on
plt = plot3(0,0,0,'.','erasemode','xor','markersize',24);
axis('square');
axis('equal');
if view_pm=='3D'; view(3);
elseif view_pm=='RZ'; view(0,0);
elseif view_pm=='RT'; view(0,90);
elseif view_pm=='TZ'; view(90,0);
end
eval(s)
hold off



