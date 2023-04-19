function [D, overlap] = coralMerge(D, opt);
%   coralMerge    merge seismograms in coral structure
% USAGE [D, overlap] = coralMerge(D, opt);
%
% Merge all the seismograms in D together if possible
% See coral for explanation of data structure
%
% check beforehand that all input seismograms are for the same station/channel
% output D is one or more seismograms depending on whether there are gaps in
% the input seismogram.  Input seismograms can be in any order, while output
% seismograms are ordered in time.
%
% opt is on optional structure with optional fields:
%
% opt.time_tol time at the start of each input seismogram that
%      is merged must match time in merged seismogram to this 
%      tolerance (s) (default=.001)
%
% opt.fill_max if there is a gap between seismograms, merge them
%      anyway if the gap is less than opt.fill_max samples (default=0)
%
% opt.fill_type {Inf | NaN | 0 | 1} fill gaps with Inf, NaN, 0, or linear 
%      interpolation if opt.fill_type=1; (default=0)
%
%
% overlap [Nx2] matrix where N is the number of input seismograms
% first column: 
%   0   means data aligned with previous seismogram 
%   <0 means there is a gap before this seismogram of that many samples 
%   >0 is the number of samples in that seismogram that overlap
%      with previous seismograms (and are therefore discarded)
% second column is the maximum difference among overlapping data (if any)
%
%  required data fields: data, recLog, recSampInt, recNumData
%
% K. Creager  kcc@ess.washington.edu   2/17/2004  mod: 10/26/2005

%  METHOD
%   compare sample intervals of all seismograms (SQUAWK IF THEY ARE DIFFERENT)
%   sort seismograms by start times (and by duration if they have the same start time)
%   calculate the start_time of each seismogram relative to the start time of the earliest seismogram (s)
%   calculate the predicted start_time of the following seismogram (ie, the end time plus the time of one sample)
%   calculate rem(start_times / sample_interval , 1)*sample_interval SQUAWK if any of these exceeds the tolerance
%   calculate the sample number of the start and end times of each seismogram
%
%   new_seis_counter=1; 
%   get the first seismogram (call it last); new_seis_ind(new_seis_counter)=last;
%   loop over the rest of the seismograms from next = 2:N
%     get the next seismogram (caLl it next)
%     gap  = number of samples between end of last seismogram and start of next
%     gap = 0 if there is no gap, negative if they overlap, positive if there is a gap
%     if gap > fill_max;  gap in seismograms is too big to fill;  do not change last, simply set it aside as a seismogram to keep;  
%                         start a new seismogram by setting last to equal next; keep track of overlap
%     otherwise merge data from next seismogram onto last seismogram
%        if gap==0     
%               they fit together perfectly: MERGE them by appending all of D(next).data to last 
%        eiseif  end-time of next is before end-time of last  
%               next is a subset of last; don't add it, but check to see if overlapping data are same
%        elseif gap<0 and end-time of next is after end-time of last
%               seismograms overlap partly, add new data from next to last and check to see if overlapping data are same
%        elseif there is a gap, but it is less than fill_max
%               merge seismograms anyway and fill the gap according to value of fill_type
%               if fill_type is 1 then linear interpolation
%        end
%        change the data structure D according to parameters determined above
%     end
%  end loop
%  the only part of D that is changed are D(last) (where last is the first seismogram, then icrements for every
%  new seismogram separated by gaps in the data).  These are the ones that are kept, the others are removed
%  The header info is kept from those sesimograms as is, only fields : data, recLog, recSampInt, recNumData
%  are changed
%  finally, usnort the overlap array so it is in the same order as the input data.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% set defalut values for time_tol, fill_max, fill_type
%%%%% then change their values if they are passed through as fields in opt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time_tol = 0.001;     % time tolerance
fill_max = 0;         % maximum number of samples in a gap to fill
fill_type= 0;         % fill with zeros

flds     = {'time_tol' , 'fill_max', 'fill_type'};
% if values are passed in through 'opt' change them from their defaults
if nargin >1;
  if isstruct(opt);
    for k=1:length(flds);
      fld = flds{k};
      if any(strcmp(fields(opt),fld));
        eval(sprintf('%s=opt.%s;',fld,fld));
      end
    end
  end
end
if fill_type~=0 & fill_type~=1 & ~isnan(fill_type) & ~isinf(fill_type);  % if fill_type is not one of these three values then set it to 0
  fill_type=0;
end


N        = length(D);     % number of seismograms
overlap  = zeros(N,2);

% 
%   See if sample intervals are the same to within single precision values
%
recSampInt       = [D.recSampInt];              % sample intervals  
sampIntDiff = 1 - min(recSampInt)/max(recSampInt);
if sampIntDiff > 1e-7;    % sample intervals should be the same to within single precision numbers
  recSampInt
  disp(sprintf(' ERROR in coralMerge fractional difference in sample intervals is: %.8f',sampIntDiff))
  keyboard
end
clear recSampInt

%
% sort data inversely by number of data and then by record start times so if two files 
% have the same start time the one with the longest duration is first
%
[tmp,key1] = sort(-[D.recNumData]);                  % key to sort by record length
[tmp,key2] = sort(timediff([D(key1).recStartTime])); % key to sort by start time (relative to record length sort)
sort_key   = key1(key2);                             % key to sort by start time (relative to original order)
sort_key_inv(sort_key) = [1:length(sort_key)];       % inverse sort key to unsort seismograms
D          = D(sort_key);                            % sort the seismograms


% get start times and start and end sample numbers for each seismogram
[recStartTime, recStartSampleI, recEndSampleI, recStartSampleErr, recStartTimeDiff, recEndTimeDiff] ...
 = coralGetTimes(D, 1);
     
% 
%   See if differences in start times are multiples of the sample intervals to within the time tolerance 
%
timeErrInd = find(abs(recStartSampleErr) > time_tol);
if length(timeErrInd)>0;    % record start times of some of the data are inconsistent with sample interval
  tmp = recStartSampleErr(timeErrInd);
  disp('ERROR in coralMerge: differences in seismogram start times are not multiples of the sample interval')
  disp('Station number, error (s) pairs are:') 
  disp(sprintf('%4d %7.4f;', [timeErrInd(:) tmp(:) ]'))
  keyboard
end

    
new_seis_counter=1; 
last=1;
new_seis_ind(new_seis_counter)=last;  % get the first seismogram (call it last); 

for next = 2:N                                          % loop over all seismograms
  gap = recStartSampleI(next) - recEndSampleI(last);    % gap in samples between end of last seismogram and start of next
                                                        % gap = 0 if there is no gap , negative if they overlap
  if gap > fill_max;  % gap in seismograms is too big to fill;  do not change last, simply set it aside as a seismogram to keep;  
                      % start a new seismogram using (next); increment new_seis_counter; new_seis_ind(new_seis_counter)=last; last = next;
    new_seis_counter = new_seis_counter+1;
    new_seis_ind(new_seis_counter) = next; 
    last = next;
    overlap(next,1) = -gap;
  else;               % merge data from next seismogram onto last seismogram
    NumDataNext = D(next).recNumData; % number of data in next seismogram
    new_data    = [];                 % initialize new_data
    if gap==0;                        % they fit together perfectly: MERGE them by appending all of D(next).data to last 
      new_data     = D(next).data;    
    elseif gap <= -NumDataNext;       % next is a subset of last; don't add it, but check to see if overlapping data are identical
      new_data     = [];
      overlap(next,1) = length(D(next).data);
      overlap(next,2) = max( abs( D(next).data - D(last).data(end+gap+1:end+gap+NumDataNext) ) );
    elseif gap < 0  &  gap > -NumDataNext;  % data overlap partly
      new_data     =  D(next).data(1-gap:end);
      overlap(next,1) = length(D(next).data(1:-gap));
      overlap(next,2) = max( abs( D(next).data(1:-gap) - D(last).data(end+gap+1:end) ) );
    elseif gap>0 & gap <= fill_max;    % there is a gap in the data, but the gap is within the optional value fill_max
      if fill_type==1;                 % fill gap by linear interpolation 
        dstart = D(last).data(end);    % last point in first seismogram
        dend   = D(next).data(1);      % first point in next seismogram
        interp_data = dstart + [1:gap]'/(gap+1)*(dend-dstart);
        new_data     = [ interp_data ; D(next).data ]; 
      else
        new_data     = [ zeros(gap,1)+fill_type ; D(next).data ];  % fill gap with 0 or NaN or Inf
      end
      overlap(next,1) = -(abs(gap));
    end
    % append the data to the end of the last seismogram and modify the number of data, and record log
    num_data     = length(new_data);
    D(last).data = [D(last).data ; new_data];
    D(last).recNumData = D(last).recNumData + num_data;
    D(last).recLog = sprintf('%smerge %d;',D(last).recLog,num_data);
    recEndSampleI(last)=recEndSampleI(last) + num_data;
  end
end
D=D(new_seis_ind);
overlap = overlap(sort_key_inv,:);
   