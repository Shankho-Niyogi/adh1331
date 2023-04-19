function [D, results, problem, problem1] = coralUnique(D,opt);
% coralUnique     find unique seismograms in a coral structure
% USAGE: [D1, results, problem, problem1] = coralUnique(D,opt);
%
% Delete seismograms from coral structure (D) that are duplicates in all the specified fields
% It may take multiple passes calls to this function to remove all duplicates
% This is done is two passes.  The first pass (opt.pre_match) finds unique/duplicate seismograms 
% based on network, station, channel, location, QC and/or seismogram start/end times
% The second pass compares the first seismogram in each group (defined in the first pass) with all
% the other seismograms in that group.  All fields in opt.exact_match and opt.exact_match are compared.
% Duplicates are removed. 
% Problems are defined as seismograms that match in the first pass but not the second.  The fields that 
% do not match are listed in structures problem and problem1.
%
% Input:  
%   D       coral structure containing seismograms
%   opt     optional structure containing any or all of the following fields
%           default values are given 
%            'pre_match', 'exact_match' , 'approx_match', 'tol_match', 'plot_duplicates'
%   opt.pre_match  cell array containing names of coral fields which must match on the first pass
%            these must be a subset of staNetworkCode, staCode, staChannel, staLocationCode, staQualityCode
%            in addition, the string 'time%.2f' will fource the start AND stop times of a sesimogram to match
%            within the format given (in this case to within .01 seconds).  This string should contain the word 'time
%            followed immediately by a format.
%   opt.exact_match  cell array containing names for coral fields whose values must match exactly on second pass.  
%   opt.approx_match cell array containing names for numerical coral fields whose values match approximately on second pass.
%   opt.tol_match    cell array containing tolerances form matches of fields given in opt.approx_match.    
%   opt.plot_duplicates = 0 to not make plots and 1 to plot time durations of duplicate stations
%
% Output: D        coral structure containing unique seismograms
%         results  row vector containing the following 4 numbers:
%                  number of input seismograms,
%                  number of unique station/network/location/channels,
%                  number of unique station/seismogram start/end times
%                  number of output seismograms removing those that are exact duplicates
%         problem  structure array containing information regarding problem stations
%         problem1 structure array containing information summarizing problem stations/fields
% % Requirements: Coral structure read into matlab called 'D'
%
% e.g.
% D=coralReadAH('/Users/kcc/Desktop/20050101_062544.8.ah');
% opt2.pre_match = {'staNetworkCode', 'staCode', 'staChannel'};                    opt2.plot_duplicates=1;
% opt1.pre_match = {'staNetworkCode', 'staCode', 'staChannel', 'staLocationCode'}; opt1.plot_duplicates=1;
% [D1, results, problem,problem1] = coralUnique(D,opt1);
%
%
% Code written by Ken Creager and Weston Thelen 04/10/2006


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%   NOTES   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% input D
%
% remove duplicates and merge seismograms where possible: (should add check to see if overlapping regions are same, and to see if
% statistical properties of seismogram change across the cut bewteen seismograms)
% find unique:     staNetworkCode, staCode, staChannel, staLocationCode, staQualityCode
% loop over each unique set
%  if there is just one seismogram in a set, KEEP it
%  else
%   compare sample intervals of all seismograms (SQUAWK IF THEY ARE DIFFERENT)
%   calculate the start_time of each seismogram relative to the start time of the earliest seismogram (s)
%   calculate the predicted start_time of the following seismogram (ie, the end time plus the time of one sample)
%   calculate rem(start_times / sample_interval , 1)*sample_interval SQUAWK if any of these exceeds the tolerance
%
%   order seismograms by their start_times
%   new_seis_counter=1;
%   get the first seismogram (call it last); new_seis_ind(new_seis_counter)=last;
%   loop over the rest of the seismograms from next = 2:N
%     get the next seismogram (caLl it next)
%     compare the entire structures for last and next
%     if last and next are identical in all respects, DELETE NEXT (by skipping it)
%     else if they are identical except for their start time, number of samples, and data vector then
%       time_gap = start_time(next) - end_time(last);
%       if abs(time_gap)<tol then MERGE them:  (append D(next).data to D(last).data; change D(last).recNumSamp, end_time(last), comment;
%       elseif gap<tol   % seismograms overlap
%         if end_time(next) <= end_time(last)+tol % next is a subset of last; DELETE NEXT (by skipping it)
%         elseif seismograms overlap: merge them by adding a subset of next to last:
%           next_ind_offset = round(time_gap/D(next).recSampInt);
%           new_start_time = start_time(next) + next_ind_offset*D(next).recSampInt;
%           if abs(new_start_time - time_end(last)) > tol   SQUAWK,  this should never happen
%           else MERGE_PART D(next).data(new_start_time+1 : end) to D(last).data; change D(last).recNumSamp, end_time(last), comment; delete next
%           end
%         end
%       elseif gap>tol   % there is a real gap in the data
%         if gap < max_gap then MERGE AND FILL IN WITH ZEROS; delete next
%         else REAL GAP;  do not change last, simply set it aside as a seismogram to keep;  start a new seismogram using (next).
%         increment new_seis_counter; new_seis_ind(new_seis_counter)=last; last = next;
%       end
%     end
%   end
%   keep seismograms (new_seis_ind)
%  end
% end
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DEFAULT VALUES FOR OPT
%
%
% FIRST PASS - These must match exactly:  
% can incude any or all of: {'staNetworkCode', 'staCode', 'staChannel', 'staLocationCode', 'staQualityCode','time%.2f'} 
% format for time should be as shown where %0.2f means 2 decimal places (.01 second tolerance)
pre_match = {'staNetworkCode', 'staCode', 'staChannel', 'staLocationCode', 'staQualityCode', 'time%.2f'};

% SECOND PASS - These must match exactly:
exact_match = {'staCode', 'staChannel', 'staNetworkCode', 'staLocationCode', 'staQualityCode', 'staType', 'staRespType', 'recLog', 'recComment'...
  'recDip', 'recAzimuth', 'data', 'recNumData',...
  'staGain', 'staGainUnit', 'staGainFreq', 'staNormalization', 'staNormalizationFreq', 'staPoles', 'staZeros', 'extras'};
%
% SECOND PASS - These need to match to within given tolerances:
approx_match = {'staLat', 'staLon', 'staElev', 'recSampInt', 'recStartTime'   };
tol_match    = {  1e-4  ,   1e-4  ,     10   ,    1e-6     , [0;0;0;0;0;1e-4] };
%These do not have to match:
%{'eqLat', 'eqLon', 'eqOriginTime', 'eqDepth', 'eqMagnitude', 'eqMagnitudeType', 'eqMomentTensor', 'eqComment', 'eqStaDistance', 'eqStaAzimuth', 'staEqAzimuth'}
%
plot_duplicates = 0;  % 0 to not plot duplicates and 1 to plot times of duplicate seismograms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flds      = {'pre_match', 'exact_match' , 'approx_match', 'tol_match', 'plot_duplicates'}; % list of all possible fields in opt
% if values are passed in throught 'opt' change them from their defaults
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  FIRST PASS
%
%  construct cell arrays StaOnly and StaTime 
%  StaOnly contains the desired station/channel names (opt.pre_match)           e.g. IU-OTAV-BHZ-10-Q
%  StaTime contains the same info as StaOnly plus data start and duration times e.g. IU-OTAV-BHZ-10-Q-392.54-720.00

% calculate start and end times of each seismogram (seconds) relative to start time of first seismogram
recStartTime    = timediff([D.recStartTime]);    % 
recNumData      = [D.recNumData];
recSampInt      = [D.recSampInt];
recDuration     = (recNumData-1).* recSampInt;
recEndTime      = recStartTime + recDuration;

% Construct a cell array with lists of fields in the coral structure D
% Cell Arrays
if any(strcmp('staNetworkCode',pre_match));  cell_1={D.staNetworkCode};  else cell_1=cell(size(D)); end
if any(strcmp('staCode',pre_match));         cell_2={D.staCode};         else cell_2=cell(size(D)); end
if any(strcmp('staChannel',pre_match));      cell_3={D.staChannel};      else cell_3=cell(size(D)); end
if any(strcmp('staLocationCode',pre_match)); cell_4={D.staLocationCode}; else cell_4=cell(size(D)); end
if any(strcmp('staQualityCode',pre_match));  cell_5={D.staQualityCode};  else cell_5=cell(size(D)); end


% Construct strings for each record
N       = length(D);
StaOnly = cell(size(D));
StaTime = cell(size(D));

StaOnlyFormat='%s-%s-%s-%s-%s';
StaTimeFormat='%s';
uniqueTime = 0;
for k=1:length(pre_match); 
  if findstr(pre_match{k},'time') 
    tmp=pre_match{k}(5:end);
    StaTimeFormat=['%s-' tmp '-' tmp];
    uniqueTime=1;
    break
  end;
end
if uniqueTime==0; 
  StaTimeFormat='%s-%.2f-%.2f'; 
end

for k=1:N
  StaOnly{k} = sprintf(StaOnlyFormat, cell_1{k}, cell_2{k}, cell_3{k}, cell_4{k}, cell_5{k});
  StaTime{k} = sprintf(StaTimeFormat, StaOnly{k}, recStartTime(k), recDuration(k));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Now determine the unique station/channels (StaOnly) and  station-channel time windows (StaTime)
% and the set to base the FIRST pass on (StaUniq) which is one of StaOnly or StaTime
%
% Find unique values (get rid of repeats of strings constructed above)
[BStaOnly,IStaOnly,JStaOnly] = unique(StaOnly);
[BStaTime,IStaTime,JStaTime] = unique(StaTime);
if uniqueTime;
  StaUniq = StaTime;
else
  StaUniq = StaOnly;
end
[BStaUniq,IStaUniq,JStaUniq] = unique(StaUniq);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SECOND PASS
% Now loop over all duplicates (as defined from the first pass in StaUniq)
%   and compare each seismogram with the first in a group of duplicates
%   this comparison considers all fields in the structure that are named in  
%   exact_match and approx_match and determines which seismograms are true duplicates.
%   these are then removed
%   Because this only compares to the first seismogram of a set, it is possible that it
%   does not catch all duplicates.  Thus it is best to run this function multiple times 
%   until all duplicates are removed.
%   


field_names = fieldnames(D);% names of all fields in the input coral structure
problem_count=0;
p = 0;                    % Keeper vector counter
M = length (IStaUniq);    % number of unique sta/seismogram/time spans
if plot_duplicates; clf; figure(1); kplot=0; end


for k=1:M                 % Loop over each unique station/channel
  
  j = find( k == JStaUniq );  % Index into original data for all seismograms at this station/channel
  p = p + 1;                  % always keep the first one of the group
  keeper(p) = j(1);
  
  if length(j) > 1;        % There are multiple records, check to see if they are the same
    
    if plot_duplicates     % plot duplicates
      kplot=kplot+2;       % offset the plot to separate it from the last station
      for c=1:length(j);   % loop over all the seismograms for this station and plot each seismogram
        kplot=kplot+1;
        plot([recStartTime(j(c)),recEndTime(j(c))],[0,0]+kplot,'b-','linewidth',2);hold on;
        plot([recStartTime(j(c)),recStartTime(j(c))] , [.9 length(j)+.1]+kplot-c,'-k')
      end;
      text(max(recEndTime(j)),kplot-length(j)/2,BStaUniq{k});
    end

    % loop over each seismogram in the group and compare it with the first seismogram, if it is identical don't keep it
    for c = 2 : length(j)
      [diff_field1,diff_field2,ierr] = coralCompareStruct( D(j(1)), D(j(c)) );  % compare values in all fields between 2 seismograms
      if ierr>0 | max(abs(diff_field1)) > 0  |  max(abs(diff_field2)) > 0;      % are there any differences?
        indx = find(diff_field1);
        % loop over all fields that are different and set problem_flag=1 if the field should match exactly 
        % or if it should match approximately and doesn't
        problem_flag=zeros(size(indx));
        for kk=1:length(indx);                                     
          if any(strcmp(field_names{indx(kk)},exact_match));       % does this field have to match exactly?
            problem_flag(kk)=1;
          elseif any(strcmp(field_names{indx(kk)},approx_match));  % does this field have to match approximately?
            problem_field_indx = strcmp(field_names{indx(kk)},approx_match);
            problem_field=approx_match{problem_field_indx};
            problem_tol  =tol_match{problem_field_indx};
            eval(sprintf('V1 = D(j(1)).%s;',problem_field));
            eval(sprintf('V2 = D(j(c)).%s;',problem_field));
            if any(abs(V2-V1)>problem_tol)                         % set problem_flag if it does not match to tolerance
              problem_flag(kk)=1;
            end
          end
        end
        if any(problem_flag)
          p = p + 1;              % something is different about these data, so keep them
          keeper(p) = j(c);
          problem_count=problem_count+1;
          problem(problem_count).indx=[j(1),j(c)];
          problem(problem_count).fields=indx(find(problem_flag));
          problem(problem_count).fieldnames=field_names(problem(problem_count).fields);   
        end
        % this seismogram is identical to j(1), do not keep it
      end
    end
  end
end

if plot_duplicates; drawnow; end

results = [length(D), length(BStaOnly), length(BStaTime), length(keeper)];
if problem_count==0; 
  problem={};
  problem1={};
  problem_summary={};
else
  problem_indx = reshape([problem.indx],2,length(problem))';
  uniq_sta_indx = unique(problem_indx(:,1));
  for k=1:length(uniq_sta_indx);
    j=find(problem_indx(:,1)==uniq_sta_indx(k));
    tmp=[]; for jj=1:length(j); tmp(jj).fields=problem(j(jj)).fields';end; 
    tmp_flds=[tmp.fields];
    %tmp_flds = [problem(j).fields(:)];
    uniq_flds= field_names(unique(tmp_flds(:)));
    uniq_flds_str=sprintf('%s, ',uniq_flds{1:end});
    sta_str = sprintf('%s                        ',StaUniq{uniq_sta_indx(k)});
    problem_summary{k} = sprintf('%s %4d %s', sta_str(1:24), length(j), uniq_flds_str);
    problem1(k).sta=StaUniq{uniq_sta_indx(k)};
    problem1(k).indx=[ uniq_sta_indx(k) ; problem_indx(j,2)];
    problem1(k).fields = uniq_flds;
  end
end
% Display seismogram data to standard output
disp(sprintf(...
  '%5d input seismograms; %5d unique stations; %5d unique station/start/end times %5d; unique seismograms',...
  results))
disp(sprintf('%s\n',problem_summary{1:end}))


[NN,MM]=size(D);
if MM==1;             % D is a column vector
  keeper=keeper(:);   % make keeper be a column vector
elseif NN==1;        % D is a row vector
  keeper = keeper(:)';% make keeper be a row vector
end
D = D(keeper);


return

%function coralCompareSpecial(D,diff_field1,diff_field2)

% if only difference is in start time, find out how much and return difference
% if only difference is in data (or data and recMaxAmp) then
% determine the nature of the differenced and report it
%return




difference = D( j( 1 ) ).data - D(j( c )).data;  % difference in data vectors
if max( abs ( difference ) ) > eps;    % Abritrary tolerance of 0.01
  D0 = [ D(j( 1 )), D(j( c )) ];     % Assign two seismograms to D0


  % Calc time diff, the number of records and the sample
  % interval each record
  recStartTime0   = timediff([D0.recStartTime]);
  recNumData0     = [D0.recNumData];
  recSampInt0     = [D0.recSampInt];

  % Compare the start times, number of samples and sample
  % interval for x-correlation
  compRecStartTime   = max(abs(diff(recStartTime0)));
  compRecNumData     = max(abs(diff(recNumData0)));
  compRecSampInt     = max(abs(diff(recSampInt0)));

  if compRecStartTime < 0.01 & compRecNumData==0 & compRecSampInt==0;
    [cc, t, indx, CLag, maxC, ierr] = coralCrossCorr(D0);

    if max(max(abs(CLag)))>0.01;     % If time lag exists
      % Calculate statistics for seismograms with time lag
      sum = 0;
      % Display station name and index in D structure
      % for ID
      disp ( sprintf('Name: %s', D(j( c )).staCode ));
      disp ( sprintf('Index: %d', j( c ) ));

      N = D(m).recNumData;     % Assign num of samples in record
      for w=1:N                % Loop over samples
        sum = sum + (D(j( c )).data(w))^2;
      end
      sum = sqrt ( sum );
      % Display statistics
      disp ( sprintf('Root mean square: %f', sum ));
      disp ( sprintf('Mean: %f', mean(D(j( c )).data)));
      disp ( sprintf('Max Time lag: %.2f',...
        max(max(abs(CLag)))));
      disp ( sprintf('Max Cross Corr Coef: %f',...
        max(max(abs(maxC)))));

      % If time shift, keep record
      p = p + 1;
      keeper ( p ) = j ( c );
    end
  end
end