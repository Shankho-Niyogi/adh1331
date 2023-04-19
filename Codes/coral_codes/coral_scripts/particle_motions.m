% Coral Script to display particle motions of many stations in 2-D or 3-D 
% USAGE: eval STA='COL ANMO PAS COR KIP SNZO';particle_motions
% This example will plot the particle motions for each of these stations.
% All three components of the data must be in data1 of coral, 
% and the channel names must each contain three upper case letters
% ending in Z, N, and E, or Z, R, and T.
% You must first run particle_motion to initialize the plot window.
% A menu bar named options allows you to change the plot to
% 3-D, or any of three 2-D views.  Redraw option will not work.  Choose the
% projection you want from the menu bar then rerun this script to get the desired
% projection

% K. Creager 3/23/95
if exist('h_pm')==1, 
  figure(h_pm)
else
  disp('first run particle_motion to initialize plot window')
  return
end
WIN_INDEX=header1(5,:);
STATIONS=left_justify(setstr(Station(1:6,WIN_INDEX)'));
clear e n z ee nn zz NN
if exist('STA')==1,                    % plot data for station STA
  [STA1,NSTA]=cut_string(STA);
  xsub=ceil(sqrt(NSTA));
  ysub=xsub-(NSTA<=xsub*(xsub-1));
  for J=1:NSTA
    STA2=STA1(J,:);
    STA2=[STA2 blanks(6-length(STA2))]; 
    INDEX=find(strcmp2(STATIONS,STA2));
    INDEX1=WIN_INDEX(INDEX); 
    CHANNEL=setstr(Station(10,INDEX1)');
 
    % data1 should contain three components of data in any order
    % the third element of the channel name must be E,N,Z for the three channels
    % The sample interval is stored in header(6,1) (units of s).

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
      disp(' no data for east-west channel, try again'); break 
    elseif exist('n')==0,
      disp(' no data for north-south channel, try again'); break 
    elseif exist('z')==0,
      disp(' no data for vertical channel, try again'); break 
    end    

    % Plot particle motion in 3-D
    subplot(ysub,xsub,J); 
    if view_pm=='3D';     plot3(n,e,z); xlabel(xlabl); ylabel(ylabl); zlabel('Vertical') 
    elseif view_pm=='RZ'; plot(n,z);    xlabel(xlabl); ylabel('Vertical');
    elseif view_pm=='RT'; plot(n,e);    xlabel(xlabl); ylabel(ylabl);
    elseif view_pm=='TZ'; plot(e,z);    xlabel(ylabl); ylabel('Vertical');
    end
    title([Sta_label])
    set(gca,'box','on')
    axis('square'); axis('equal');
    %ee=[ee; e];
    %nn=[nn; n];
    %zz=[zz; z];
    %NN=[NN;length(ee)];
  end
end
