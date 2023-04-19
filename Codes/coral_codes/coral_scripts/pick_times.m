% matlab script to pick times and shift seismograms accordingly.
% First plot data in data1 using 'yaxi e' and setting the time scale so that
% time 0 appears in the window. (See widt)
% Use the mouse to pick times for each trace.  A plus will appear where the pick 
% was made. Picking a trace twice will move the plus and reset the pick.  If you 
% pick each trace it will shift the traces and write them into data1.  If you pick 
% some, but not all traces, the traces will be moved by the actual time values chosen
% for the picked times, and the non picked traces will be moved as if you had picked
% them at time = 0.  
% Exit this script by pushing key on the keyboard.  If you press RETURN the data
% will be time shifted and the time residuals put into obs1.  Any other keyboard key
% will exit this script and do nothing to data1.

hold on
Ndata=length(data1(1,:));
timeshift=zeros(Ndata,1) ;
plot_yn  =timeshift;
bbb=0;
while bbb <4,                       % while key is not a mouse key
   [xxx,yyy,bbb]=ginput(1),         % enter a key stroke in the plot window
   if bbb~=13,                      % if key is not RETURN
     iii=round(yyy);                % determine trace number
     if plot_yn(iii)==1,            % if already picked erase old pick
       h_plot1=plot(timeshift(iii),iii,'+','MarkerSize',20,'Erase','xor');   
     end
     timeshift(iii)=xxx;            % set time shift
     plot_yn(iii)=1;                % plot a + at new pick
     h_plot1=plot(timeshift(iii),iii,'+','MarkerSize',20,'Erase','xor');   
  end
end


hold off
timeshift
if bbb==13,                          % if RETURN then determine and apply time shifts
   del_t=demean(timeshift);
   Tdur=header1(2,:);
   window=[del_t';Tdur;(1:length(Tdur))];
   obs1(1,:)=header1(1,:)+del_t';
   obs1(1,:)=obs1(1,:) - mean(obs1(1,:)-header1(9,:)); % differential travel time (s)
   obs1(2,:)=obs1(1,:) - header1(9,:);               % differential travel time residual (s)

%   obs1(1,:)=header1(1,:)-del_t'
%   obs1(2,:)=demean(obs1(1,:)'-header1(9,:)')';
   [data1,header1,label1,obs1]=apply_window(data1,header1,label1,obs1,window);
end

