% coral_label       write a label (eg: UW-Coral:  06/17/97  11:56)
%                   at lower right corner of Coral plots
% use unix command to get time in GMT rather than local time
% if this does not work then use matlab routine to get local time

% the goal of this code is to get GMT date/time into a of the form:
% TMP = 'UW-Coral:  06/17/97  11:56'
% first try the easy way:  Run unix command date, write output to TMP

[TMP_ERR,TMP] = unix(['date -u ''+UW-Coral: %m/%d/%y  %H:%M''']);

if TMP_ERR==0;                           % this worked!

  TMP1=findstr('UW',TMP);                % strip off ridiculous unix warning (if there)
  if length(TMP1)==1; TMP=TMP(TMP1:end); end

else   

  % there was an error using the "unix" command, try using "!"
  % to write the date to a file called CORAL_DATE_

  !date -u '+UW-Coral: %m/%d/%y  %H:%M' > CORAL_DATE_
  pause(.5);                             % wait for it to finish writing before reading it
  [TMP_FID,FMESSAGE]=fopen('CORAL_DATE_');% try to open the file
  if length(FMESSAGE)==0;                % file opened OK
    [TMP,TMP_COUNT]=fscanf(TMP_FID,'%c');% read the file into string TMP
    if TMP_COUNT>0; TMP_ERR=0; end;      % if this worked set TMP_ERR=0;
    fclose(TMP_FID);                     % close the file

  else                                   % Both UNIX methods failed, 

    TMP=clock;                           % use matlab to get local time
    TMP=sprintf('UW-Coral: %s %2d:%2d',date,TMP(4:5));  % turn time into text string
    TMP_ERR=-1;                          % flag to show that TMP is local time

  end
end

if exist('CORAL_DATE_')==2; % delete the file we made
  !/bin/rm CORAL_DATE_
end
    
if TMP_ERR==0 | TMP_ERR==-1; % time is GMT or LOCAL
  if length(TMP)>0 
    text(1,-.03,TMP,'fontsize',9,'HorizontalAlignment','right', ...
       'VerticalAlignment','cap','Units','normalized');% print time on plot
  end
end
clear TMP TMP0 TMP1 TMP_ERR TMP_FID TMP_COUNT
