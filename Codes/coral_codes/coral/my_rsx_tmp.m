function [window,button,nskip,d,header]=my_rsx(t,d,delta,header,syn,scale, ...
                            titl,ylab,tlab,pick,windowin,Syn_label);
%   my_rsx        record section plotter
% usage: [window,button,nskip,d,header]=my_rsx(t,d,delta,header,syn,scale, ...
%                           titl,ylab,tlab,pick,windowin,Syn_label);
%
% t     = defines the time axis 
%       if scalar, each trace is offset by t seconds 
%       if row vector, each trace is offset by t(i) seconds 
% d     = matrix of data to be plotted
% delta = epicentral distances (specifies the y coordinate)
% header= header that stores start time of data, sample interval etc
% syn   = array of synthetic travel times
% scale is a vector with 1 or 4 elements
% scale(1) = fraction of maximum peak-to-peak amplitude to total distance range
%          > 0 true relative scale, < 0 all traces normalized
% scale(4) = 0 then (2,3) = fractional distance along x-axis where traces start 
%            and end (eg .2 .8)
% scale(4) = 1 then scale(2) = fractional distance along x-axis where traces start
%            and scale(3) is scale (s/cm) after printing in landscape mode.
% titl  = plot title
% ylab  = set options with syntax like 'yaxi\D\ylabel\distance (deg)\fill\wk\
%         where \ is a string separater and odd strings are keywords, and even 
%         are attributes
%         yaxi = [e,E,d,D] for spacing evenly or by distance, 
%                     lower (upper) case in for increasing from the bottom (top)
%         ylabel = label that is printed along the yaxis
%         fill  == 2 character string to set 2 colors for solid seismogram fill
%               ~= 2 character string for normal lines for seismograms
%                
% tlab  = character matrix of labels for each trace (default is ' ')
% pick  = 0 or not included in argument for no picking
%       = 1 to be able to pick a time window,
%           replot it and return the window indices
% windowin= window start, width (both in seconds) and trace number
% window= window start, width in seconds from beginning of the plot

%   notes on time of seismograms:
%
%   if the input argument "t" is given as a scalar then the seismograms are 
%   displayed such that they are aligned relative to the first elements of the 
%   data matrix.  Note that the first elements may be NaN so that noting is displayed
%   at that time.  The time assigned to the first element of the matrix is "t".
%
%  
%  there are two time systems:
% 1) relative to origin time of earthquake (top row in diagram)
%    h1 (first row of header) is time of first element in data matrix
% %    h3 (third row of header) is time of first point on seismogram relative to 
%       first element in matrix(data matrix may have NaN at start)
%    ts = h1+h3 is time of first point on seismogram
%    h1-Toff is time of zero time in screen units
% 
% 2) time as displayed on the screen (second row in diagram)
%    is given as time since origin time of earthquake minus (h1-Toff)
% 
%
%  * is origin time of earthquake, h1 is time of first element of matrix, 
%  ts is start time part of trace that is displayed
%
%
%                                               /\   /\  /\     -   /
%  *....................................|.....|/  \ /  \/  |\  / \_/
%                                       |     |    -       | \/
%                                       |     |            |
%  0                                    h1   ts          h1-Toff
%                                           h1+h3
%  
%  Toff-h1                             Toff   Ts           0
%                                           h3+Toff

global h_plot h_tt h_text

window=[];
if nargin < 8, ylab='yaxi\e\ylabel\\'; end;                    % set ylabel
if nargin < 9, tlab(1:size(d,2))=' '; end;                    % set tlabel
if nargin < 10, pick=0; windowin=[]; end;                     % set pick option
if nargin < 12, Syn_label='label of'; end;                    % set phase name labels

% interpret string ylab to define the y axis
temp=findstr('yaxi\',ylab);             % change 'yaxi'
if length(temp)>0
  yaxi=ylab(temp+5);
else
 yaxi='e'
end

temp=findstr('ylabel\',ylab);           % change 'ylabel'
if length(temp)>0
  temp_str=ylab(temp+7:length(ylab));
  temp=min(findstr('\',temp_str));
  ylabl=temp_str(1:temp-1);
else
 ylabl=' ';
end

temp=findstr('fill\',ylab);           % change 'fill'
if length(temp)>0
  temp_str=ylab(temp+5:length(ylab));
  temp=min(findstr('\',temp_str));
  s_fill=temp_str(1:temp-1);
else
 s_fill='';
end

if yaxi=='E' | yaxi=='D', reverse_ydir='t';
else,                     reverse_ydir='f';
end

[n,m]=size(d);                                                % #pts, #traces

% set time parameters

tic
t_in=t;

if     length(t)==1,   t_offset=t*ones(1,m);
elseif length(t)==m,   t_offset=t(:)';
end

[istart,iend]=find_nonzero(header); % find indices of first and last non-zero samples for each trace
t_start=header(3,:) + t_offset;     % start time of first non-zero sample relative to first sample
n_time_samples = iend-istart+1;     % number of non-zero samples to plot
sintr=header(6,:);                  % sample interval (s)
tmin=t_start;
tmax=t_start + (n_time_samples-1).*sintr;
xmin=min(tmin);xmax=max(tmax);      % min and maximum times to use for setting axis limits

% Set the x-scale according
% to input parameter scale as described at start of this routine
% in the x direction for labels
% up to this point xmax and xmin are maximum and minimum times of traces
if length(scale>1)
  if(scale(4)==0)
    ttemp=(xmax-xmin)/(scale(3)-scale(2));
    xmax=xmin+(1.-scale(2))*ttemp;xmin=xmin-scale(2)*ttemp;
  else
    xmin=xmin-scale(2)*scale(3)*20.96;
    xmax=xmin+scale(3)*20.96;
  end
end


% get distance range

delrange=max(delta)-min(delta);if delrange == 0, delrange = 1; end;
ylim=[min(delta) max(delta)]; 
if ylim(1)==ylim(2),ylim=ylim+[-.5 .5]; end;

% get data amplitude range (if zero, reset drange equal to 1);

drange  =max(d)-min(d);
drange  =(drange==0) + drange;

% normalize amplitude if scale(1)<0

if scale(1) < 0,
  factor=abs(scale(1))*delrange;
else
  factor=abs(scale(1))*delrange/max(drange);
  drange=ones(m,1);
end



%%%%%%%%%%%%%%%%%
%   PLOT DATA   %
%%%%%%%%%%%%%%%%%

h_plot=zeros(m,1);
is_hold=ishold;
if reverse_ydir=='t'; sca=-factor; % if yaxis is inverted then invert data as well
else                  sca= factor;
end
if length(s_fill)==2;
  clf
  for i=1:m
    ttemp=t_start(i)+[0:n_time_samples(i)-1]*sintr(i); indx=istart(i):iend(i);
    fill_seismogram(ttemp',d(indx,i)*sca/drange(i),delta(i),s_fill)
    if i==1, hold on; set(gca,'drawmode','fast');end
  end
else
  for i=1:m
    ttemp=t_start(i)+[0:n_time_samples(i)-1]*sintr(i); indx=istart(i):iend(i);
    h_plot(i)=plot(ttemp,d(indx,i)*sca/drange(i)+delta(i),'-k','EraseMode','normal'); 
    if i==1, hold on; set(gca,'drawmode','fast');end
  end
end
if reverse_ydir=='t';      % invert yaxis is specified in ylab 
  set(gca,'YDir','reverse')
end

if(~is_hold), hold off; end
title(titl);
% find maximum and minimum of data
% this can be replaced by axis([xmin,xmax,-Inf,Inf]);
% once a ginput bug is fixed by matlab.  The bug is that when
% the -Inf,Inf is used to define the axis, ginput returns y=NaN
% when the button pressed is from the keyboard, not from a mouse.
% ymin=1e100;ymax=-ymin;
% for i=1:length(h_plot); 
%   ydata=get(h_plot(i),'ydata');
%   ymin=min(ymin,min(ydata)); 
%   ymax=max(ymax,max(ydata));
% end
%axis([xmin,xmax,ymin,ymax]);
axis([xmin,xmax,-Inf,Inf]);
xlabel('time (s)');ylabel(ylabl); 

%%%%%%%%%%%%%%%%%%%%%%% 
%  draw trace labels  %
%%%%%%%%%%%%%%%%%%%%%%%

yval=delta;
xval=ones(1,length(yval))*(0.99*xmin+0.01*xmax);
if     m<30, font_size=11;
elseif m<60, font_size=10;
elseif m<90, font_size= 9;
elseif m<105,font_size= 8;
elseif m<120,font_size= 7;
else        ,font_size= 6;
end 
if length(tlab(:,1)) == 30,
  temp=tlab([17:29],:);
  temp1=setstr(abs(temp)*0+abs(' '));
  for i=1:m
    temp2=remove_2blanks(temp(:,i));
    temp1(1:length(temp2),i)=temp2;
  end
  temp1=[tlab(1:13,:);temp1];
  h_text=text(xval,yval,temp1','FontSize',font_size);
%  h_text=text(xval,yval,temp1');set(h_text,'FontSize',font_size);
else 
  h_text=text(xval,yval+.1,tlab','FontSize',font_size);
%  h_text=text(xval,yval+.1,tlab');set(h_text,'FontSize',font_size);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PLOT travel time curves  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(syn)>0,
  syn1=syn(:,header(5,:));
  [n_syn,n_temp]=size(syn1);
  hold on
  for i_syn=1:n_syn
    syn1(i_syn,:)=syn1(i_syn,:)-header(1,:)+t_offset;
  end
  if (length(yval) == 1 | ...     % jpw: This allows plotting of tt curves for only one seismogram.
	  (yaxi=='d'&(sum(yval)/yval(1))==length(yval))) % or for any number of superimposed
	ytmp = zeros(length(h_plot),2);                  % seismograms.
	for ihp = 1:length(h_plot)
	  ytmp(ihp,:)=[min(get(h_plot(ihp),'ydata')),max(get(h_plot(ihp),'ydata'))];
	end
	ymin0 = min(ytmp(:,1));
	ymax0 = max(ytmp(:,2));
	for isyn = 1:n_syn
	  h_tt = plot([syn1(isyn,1) syn1(isyn,1)],[ymin0 ymax0],':k');
	end
  else
	h_tt = plot(syn1',yval,':k');
  end
  % make labels for travel-time curves
  if findstr(Syn_label(n_syn+1,:),'label on'), 
    for i_syn=1:n_syn
      if Syn_label(i_syn,1)~='s' & Syn_label(i_syn,1)~='p' ; % plot labels for all but depth phases
        indx=find(~isinf(syn1(i_syn,:)));  % find indices of finite-valued points on this travel time curve
        if length(indx)>0,
          indx1=max(find(max(yval(indx))==yval(indx)));  % find index of maximum yval for this curve
          if length(indx1)==1,
            indx=indx(indx1);
            text(syn1(i_syn,indx),yval(indx),deblank(Syn_label(i_syn,:)), ...
                'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',8);
          end
        end
      end
    end
  end
  hold off
end

old_win1=[];
old_win2=[];

% if length(window(1,:)) < 3, is improper definition of window, ignore it...

if length(windowin) > 0,
  if length(windowin(1,:)) < 3,
    echo_ml(' ')
    echo_ml('Improper definition of input windows, ignoring input windows...')
    windowin = [];
  end;
end;

% if a window was included, plot it...
if nargin >= 11 & length(windowin) > 0,
  button=1;
  hold on;
  window=windowin;
  if length(window(:,1)) == 1,
    win1=(window(:,1))*[1 1.000001];
    win2=sum(window(:,1:2))*[1 1.000001];
    if window(:,2)>0,
      h_plot1=plot(win1,ylim,'-b','Erase','xor');     % plot window
      h_plot2=plot(win2,ylim,'-b','Erase','xor');
    end;
    old_win1(1,:) = win1;
    old_win2(1,:) = win2;
  else
    for j = 1:length(window(:,1)),
      newwind(1) = window(j,1);
      newwind(2) = sum(window(j,1:2));
      win1 = newwind(1)*[1 1];
      win2 = newwind(2)*[1 1];
      oldno = window(j,3);
      h_plot1(j)=plot(win1,[delta(oldno)+0.4 delta(oldno)-0.4],'-b','Erase','xor');
      h_plot2(j)=plot(win2,[delta(oldno)+0.4 delta(oldno)-0.4],'-b','Erase','xor');
      old_win1 = [old_win1; win1];
      old_win2 = [old_win2; win2];
    end;
  end;
end;

% if user input is allowed (pick == 1), take the input using ginput...

if pick ~= 0;
  hold on;
  nskip=0;
  done='f';

  % take user input here...

  newin = 0;                       % test if new window limits entered

  while done=='f',
    [xx,yy,button]=ginput(1); if length(button)==0; button=13; end

% if center or right mouse button, entering a new window...
%   first enter window for a given trace, width held constant for
%   other traces, so just enter left coordinate for those traces...
%   hit return to continue (or third mouse button), escapes if only
%   one window is selected.

    if button==1 | button==2 | button==3;      % entered first new window limit
      newin = 1;
      wflag = 0;
      merror = 0;
      newwind(1)=xx;
      [tempdiff, tempindx] = sort(abs(yy-delta));
      traceno = tempindx(1);
      echo_ml(' ')
      echo_ml('Select second limit for this trace with middle')
      echo_ml('     or right mouse button...')
      [xx,yy,button]=ginput(1); if length(button)==0; button=13; end
      while (button == 1 | button == 2 | button == 3),
        [tempdiff, tempindx] = sort(abs(yy-delta));
        traceno = tempindx(1);
        if wflag == 0,
          if length(old_win1) > 0,
            if length(old_win1(:,1)) == 1,
              set(h_plot1,'Visible','off');
              set(h_plot2,'Visible','off');
            else
              for j = 1:length(window(:,1)),
                oldno = window(j,3);
                set(h_plot1(j),'Visible','off');
                set(h_plot2(j),'Visible','off');
              end
            end
          end
          newwind(2)=xx;
          newwind(:) = sort(newwind(:));
          start = newwind(1);
          dwidth = newwind(2) - newwind(1);
          width = dwidth/2;
          win1=newwind(1)*[1 1];
          win2=newwind(2)*[1 1];
          window = [start dwidth traceno];
          old_win1 = [];
          old_win2 = [];
        else,
          if button == 1,
            newwind(1)=xx;
            newwind(2)=newwind(1)+dwidth;
            win1=newwind(1)*[1 1];
            win2=newwind(2)*[1 1];
          elseif button == 2,
            center = xx;
            win1 = (center-width)*[1 1];
            newwind(1) = win1(1);
            win2 = (center+width)*[1 1];
          elseif button == 3,
            newwind(2)=xx;
            newwind(1)=newwind(2)-dwidth;
            win1=newwind(1)*[1 1];
            win2=newwind(2)*[1 1];
          end
          start = newwind(1);
        end
        i = find(traceno == window(:,3));
        if length(i) == 0 | wflag == 0,		% haven't done this trace yet
          if wflag ~= 0,
            window = [window; [start dwidth traceno]];
          end
          old_win1 = [old_win1; win1];
          old_win2 = [old_win2; win2];
          i=length(window(:,3));
        else					% this trace was the i-th trace
          set(h_plot1(i),'Visible','off');
          set(h_plot2(i),'Visible','off');
          old_win1(i,:) = win1;
          old_win2(i,:) = win2;
          window(i,:) = [start dwidth traceno];
        end
        h_plot1(i)=plot(win1,[delta(traceno)+0.4 delta(traceno)-0.4],'-b','Erase','xor');
        h_plot2(i)=plot(win2,[delta(traceno)+0.4 delta(traceno)-0.4],'-b','Erase','xor');
        if wflag == 0,
          wflag = 1;
          disp('  Select one of limits for each trace of interest using the mouse buttons')
          disp('      LB -> set left limit, RB -> right limit, CB -> center,')
          disp('     ''c'' to copy window to all traces')
        else
          disp('  Select next trace, <CR> to cut out windows, ''r'' or ''q'' to disregard new windows:')
        end
        [xx,yy,button]=ginput(1); if length(button)==0; button=13; end
      end;
      if length(button)==0, button=13; end; % if button does not exist initialize it

      if wflag == 0,                          % forgot to enter second limit...
        disp('Middle or Right mouse button must be used to enter')
        disp('   second limit after first limit is entered, start again')
      elseif button == 13,
        done='t';
      elseif button == 'p',
        orient tall
        print
      elseif button == 'l',
        orient landscape
        print
      elseif setstr(button) == 'r',           % start over again...
        nskip = 0;
        done='t';
      elseif setstr(button) == 'c',      % copy current window to all traces
        tempwind = window(1,1:2);
        win1=(tempwind(1))*[1 1];
        win2=sum(tempwind)*[1 1];
        window = [tempwind 1];
        for j = 2:length(d(1,:)),
          window = [window; tempwind j];
        end;
        for j = 1:length(d(1,:)),
          h_plot1(j)=plot(win1,[delta(j)+0.4 delta(j)-0.4],'-b','Erase','xor');
          h_plot2(j)=plot(win2,[delta(j)+0.4 delta(j)-0.4],'-b','Erase','xor');
        end;
      elseif setstr(button) == 'q',
        done='t';
      end;

% move seismograms

    elseif setstr(button) == 'm',
      disp(' ')
      disp('Select a trace to move with left mouse, move with center or right mouse')
      disp('<CR> applies moves to D1, ''q'' undoes all data moving')
      if length(window)==0, 
        [ndata,ntrace]=size(d);
        window_mv=[t_offset;header(2,:);(1:ntrace)]';
      else
        window_mv=window;
      end
      temp=0;
      temp_last=0;
      traceno=0;
      while temp<4 
        [x, y, temp] = ginput(1); if length(temp)==0; temp=13; end
        if     temp>3 & temp~=13 & temp~=113
          disp(' In move mode you must enter: left mouse to select a new trace')
          disp('                            : center or right mouse to move the trace')
          disp('                            : <CR> to apply all moves to D1')
          disp('                            : or ''q'' to quit plot 1 and not apply moves to D1')
          temp=0;
        else 
          if (temp==1 | temp==13) & (temp_last==2 | temp_last==3); % save last move
            if traceno>0
              window_mv(traceno,1)=window_mv(traceno,1)+x0-x1;
              disp(sprintf(' move %d by %.2f s',traceno,x1-x0))
            end
          end
          if      temp==1;                            % select and mark a new trace
            [tempx, tempi] = sort(abs(delta - y));
            traceno = tempi(1);
            x0=x;
            plot(x0,delta(traceno),'yo');
            xxx=get(h_plot(traceno),'xdata');
          elseif (temp==2 | temp==3) & traceno>0,      % move the selected trace
            x1=x;
            set(h_plot(traceno),'xdata',xxx+x1-x0)
          elseif temp==13 & traceno>0,
            window=window_mv; window(:,3)
            button=13;
            done='t';
          end
          temp_last=temp;
        end 
      end

% plot point, return time...

    elseif setstr(button) == 't',
      [tempx, tempi] = sort(abs(delta - yy));
      traceno = tempi(1);
      [ntlab,mtlab]=size(tlab);
      disp(sprintf('%s : time from earthquake is %.2f s',tlab(1:5,traceno)', xx + header(1,traceno) - t_offset(traceno)))
      plot(xx,delta(traceno),'yo');

% exit and skip n traces...

    elseif setstr(button) == 's',
      echo_ml(' ')
      echo_ml('In plot window, enter number of records to skip: ');
      echo_ml('     (press <return> to indicate end of integer):      ');
      nskip = ginput_num;
      if nskip >= 0,
        nskip = nskip - 1;
      else,
        nskip = nskip + 2;
      end;
      done='t';

% exit and go to nth trace...

    elseif setstr(button) == 'g',
      echo_ml(' ')
      echo_ml('In plot window, enter trace number you wish to analyze');
      echo_ml('     (press <return> to indicate end of integer):      ');
      nskip = ginput_num;
      done='t';

% flip trace indicated by mouse input...

    elseif setstr(button) == 'f',
      echo_ml(' ')
      echo_ml('Select traces to flip with mouse (<CR> to exit flip mode)')
      temp=1;
      while temp~=13,
%        [x, y, temp] = ginput(1); if length(temp)==0; temp=13; end

% JCC June 13 - 1997
        [x, y, temp] = ginput(1); if length(temp)==0; temp=13; end
% JCC End
        if temp<=3
          [tempx, tempi] = sort(abs(delta - y));
          traceno = tempi(1);
          d = flip_trace(d, traceno);
          header(7,traceno)=-header(7,traceno);
          if header(7,traceno)>0,
            tlab(29,traceno)='+';
          else
            tlab(29,traceno)='-';
          end
          yyy=get(h_plot(traceno),'ydata');
          set(h_plot(traceno),'ydata',2*delta(traceno)-yyy)
        elseif temp~=13
          echo_ml('In flip mode you must enter a mouse button or <CR>');
        end
      end
%      hold off;
%      my_rsx(t_in,d,delta,header,syn,scale,titl,ylab,tlab,0,window,Syn_label);
%      hold on;

% kill (remove) trace indicated by mouse input...

    elseif setstr(button) == 'k',
      echo_ml(' ')
      echo_ml('Select traces to remove with mouse (each mouse ckick removes a trace)')
      echo_ml('<CR> removes selected traces from D1, ''q'' undoes all data removals')
      if length(window)==0, 
        [ndata,ntrace]=size(d);
        window_rm=[t_offset;header(2,:);(1:ntrace)]';
      else
        window_rm=window;
      end
      temp=1;
      while temp~=13 & temp~=113,      % quit if button = <CR> or 'q'
        [x, y, temp] = ginput(1); if length(temp)==0; temp=13; end
        if temp<=3, 
          [tempx, tempi] = sort(abs(delta - y));
          traceno = tempi(1);
          itrace=find(window_rm(:,3)~=traceno);
          if length(itrace)>0,
            window_rm=window_rm(itrace,:);
          end
          [ntlab,mtlab]=size(tlab);
          if traceno<=mtlab, disp([tlab(:,traceno)' '    removed']); end
          set(h_plot(traceno),'Visible','off')
        elseif temp~=13 & temp~=113
          echo_ml('in data remove mode you must enter a mouse button, <CR>, or ''q''');
        end
      end
      if temp==13, 
        window=window_rm; window(:,3)
        button=13;
        done='t';
      end
      if temp==113,
        echo_ml('Quitting trace remove mode, no traces removed, enter new command') 
      end

% extract phase name

    elseif setstr(button) == 'x',
      if length(Syn_label)==0,
        disp(' cannot extract phase name because no travel time curves')
        disp(' have been calculated.  see TT')
      else
        % first find trace that is closest to the cursor
        % then find the travel time (at that trace) that is closes to that trace
        % then get and print the phase name 
        [tempx, tempi] = sort(abs(delta - yy));
        traceno = tempi(1);
        [tempx, tempi] = sort(abs(syn1(:,traceno) - xx));
        tt_no = tempi(1);
        disp( deblank(Syn_label(tt_no,:)) ) 
      end

% deglitch trace indicated by mouse input...

    elseif setstr(button) == 'd'
      temp = [];
      echo_ml(' ')
      echo_ml('Select trace to deglitch with right or left mouse button...')
      [x, y, temp] = ginput(1); if length(temp)==0; temp=13; end
      if temp == 3,
        [tempx, tempi] = sort(abs(delta - y));
        traceno = tempi(1);
        d = deglitch(d, 1, traceno);
        hold off;
        my_rsx(t_in,d,delta,header,syn,scale,titl,ylab,tlab,0,window,Syn_label);
        hold on;
      elseif temp == 1;
        [tempx, tempi] = sort(abs(delta - y));
        traceno = tempi(1);
        echo_ml(' ')
        echo_ml('  In plot window, enter number of glitches to remove');
        echo_ml('     (press <return> to indicate end of integer):      ');
        nglitch = ginput_num;
        d = deglitch(d, nglitch, traceno);
        hold off;
        my_rsx(t_in,d,delta,header,syn,scale,titl,ylab,tlab,0,window,Syn_label);
        hold on;
      end;


% exit and analyze this trace if <RETURN>...

    elseif button == 13,
      done='t';

% exit and then replot this trace...

    elseif setstr(button) == 'r',
      hold off;
      my_rsx(t_in,d,delta,header,syn,scale,titl,ylab,tlab,0,window,Syn_label);
      hold on;

% exit and skip to next trace...

    elseif setstr(button) == 'n',
      done='t';

% exit and go back to last trace...

    elseif setstr(button) == 'b',
      done='t'; 

% exit and quit...

    elseif setstr(button) == 'q',
      done='t';

% print plot in tall format...

    elseif setstr(button) == 'p',
      orient tall 
      print

% print plot in landscape format...

    elseif setstr(button) == 'l',
      orient landscape
      print

% help, gives list of possible commands...

    elseif setstr(button) == 'h',  % help, gives list of possible commands
      echo_ml(' ')
      echo_ml('The following commands exit RSX (return to calling routine):')
      echo_ml('  n    go to next record')
      echo_ml('  b    go back to last record')
      echo_ml('  r    replot current record')
      echo_ml('  q    exit and quit')
      echo_ml(' <CR>  exit with current window')
      echo_ml(' ')
      echo_ml('The following request a number in command window then exit RSX:')
      echo_ml('  s    skip n records (must enter n then <CR>; can be negative)')
      echo_ml('  g    go to nth record (must enter n then <CR>)')
      echo_ml(' ')
      echo_ml('The following commands do not exit RSX:')
      echo_ml('  c    copy current window to all traces')
      echo_ml('  t    return x and y values of current location, plot o there')
      echo_ml('  p    print current plot in tall format')
      echo_ml('  l    print current plot in landscape format')
      echo_ml('  x    write travel time curve phase name nearest the cursor')
      echo_ml('  t    write travel time at cursor')
      echo_ml('  m    enter move a trace mode:')
      echo_ml('          use left mouse to select a new trace')
      echo_ml('          center or right mouse to move the trace')
      echo_ml('          <CR> to apply all moves to D1')
      echo_ml('          or ''q'' to quit plot 1 and not apply moves to D1')
      echo_ml('  f    enter flip a trace mode:')
      echo_ml('          use any mouse button to choose traces to flip')
      echo_ml('          traces are flipped and redisplayed after <CR>')
      echo_ml('          mouse buttons are ignored if character q is entered')
      echo_ml('  k    enter kill (delete) a trace mode:')
      echo_ml('          use any mouse button to select traces to delete')
      echo_ml('          traces are deleted from Data1 after <CR>')
      echo_ml('          mouse buttons are ignored if character q is entered')
      echo_ml('  d    deglitch trace from current file:')
      echo_ml('          asks for mouse input...if LB used, user must input')
      echo_ml('           number of glitches to remove; if RB used, removes')
      echo_ml('           largest glitch...in either case removes glitch from')
      echo_ml('           trace closest to mouse input')
      echo_ml(' ')
      echo_ml('Summary of mouse commands:')
      echo_ml('  (Note:  LB, CB, RB are left, center and right mouse buttons)')
      echo_ml('    (1) When picking first window;')
      echo_ml('           LB, CB or RB used to pick window limits...')
      echo_ml('    (2) For all successive windows;')
      echo_ml('           LB -> choose left window limit')
      echo_ml('           RB -> choose right window limit')
      echo_ml('           CB -> choose window center')
      echo_ml('    (3) to escape from window selection;')
      echo_ml('           <CR> -> continues analysis')
      echo_ml('             r  -> replot current file')
      echo_ml('             q  -> exit and quit')
      echo_ml(' ')
    else
      echo_ml('command not recognized, try h for list of commands...')
    end;
  end;
end;
if length(window)>0, window(:,1)=window(:,1)-t_offset(window(:,3))'; end
hold off;

