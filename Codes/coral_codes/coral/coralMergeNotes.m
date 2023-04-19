     
     
     
     
     
     if gap <= 0;                                          % there is no hole in the seismogram, so merge them
       NumDataAdd = NumDataNext - gap;                       % add this many samples to the end of the last seismogram
       if NumDataAdd <= 0; 
     
     if gap <= -NumDataNext
     
     new_data = [];
     if gap==0;  %  they fit together: MERGE them:  (append D(next).data to D(last).data; change D(last).recNumData, end_time(last), comment;
       new_data     = D(next).data;
       num_data     = length(new_data);
       D(last).data = [D(last).data ; new_data];
       D(last).recNumData = D(last).recNumData + num_data
       D(last).recLog = sprintf('%smerge %d;',D(last).recLog,num_data);
       recEndTime(last)=recEndTime(last) + recSampInt(last)*num_data;
     elseif gap<0      % seismograms overlap
       if recEndTime(next) <= recEndTime(last)+time_tol; % next is a subset of last; DELETE NEXT (by simply skipping it)
       else
         next_ind_offset = round(time_gap/D(next).recSampInt);
         new_start_time  = recStartTime(next) + next_ind_offset*D(next).recSampInt;
         if abs(new_start_time - recEndTime(last)) > tol ; keyboard; end %  SQUAWK,  this should never happen
         else % MERGE PART
           new_data = D(next).data(new_start_time+1 : end);
           num_data = length(new_data);
           D(last).data = [D(last).data ; new_data];
           D(last).recNumData = D(last).recNumData + num_data
           D(last).recLog = sprintf('%smerge %d;',D(last).recLog,num_data);
           recEndTime(last)=recEndTime(last) + recSampInt(last)*num_data;
         end
       
       elseif time_gap>time_tol   % there is a real gap in the data
         if time_gap < max_gap then MERGE AND FILL IN WITH ZEROS; delete next
%         else REAL GAP;  do not change last, simply set it aside as a seismogram to keep;  start a new seismogram using (next).
%         increment new_seis_counter; new_seis_ind(new_seis_counter)=last; last = next;
%       end
%     end
%   end
%   keep seismograms (new_seis_ind) 
%  end
% end
      
      new_seis_counter=1; 
      last = D(1);
      
      
      
      
      
      timeGaps = timediff(recStartTime(:,2:end) , recEndTime(:,1:end-1) ); % start time of next minus end time of last seismogram
      
      recEndTimeDiff   = timediff([ recStartTime(:,1) recEndTime]); recEndTimeDiff(1)=[]; 
      
      
      gap_ind     = find(timeGaps<-gap_tol);      % index to seismograms with data gaps relative to next seismogram
      overlap_ind = find(timeGaps> gap_tol);      % index to seismograms with data that overlaps next seismogram
      nOverlap    = length(overlap_ind);
      nGap        = length(gap_ind);
      
      if nGap | nOverlap
        fid = fopen('/Users/kcc/matlab/working/040707/mergelog','a');
        for j=1:nGap
          disp( sprintf('%s %5s %s %4d %2d %2d  %2d %2d %6.3f  %10.3f',day,sta{1},chan{1},recEndTime(:,gap_ind(j)), timeGaps(gap_ind(j)) ) );
          fprintf(fid,'%s %5s %s %4d %2d %2d  %2d %2d %6.3f  %10.3f\n',day,sta{1},chan{1},recEndTime(:,gap_ind(j)), timeGaps(gap_ind(j)) );
        end
        for j=1:nOverlap
          disp( sprintf('%s %5s %s %4d %2d %2d  %2d %2d %6.3f  %10.3f',day,sta{1},chan{1},recEndTime(:,overlap_ind(j)), timeGaps(overlap_ind(j)) ) );
          fprintf(fid,'%s %5s %s %4d %2d %2d  %2d %2d %6.3f  %10.3f\n',day,sta{1},chan{1},recEndTime(:,overlap_ind(j)), timeGaps(overlap_ind(j)) ); 
        end
        fclose(fid);
      end
      
      % if data overlap check to see if it is an integer amount and if so remove overlap from end of seismograms
      if nOverlap>0;                              
        numOverlapSamples = timeGaps(overlap_ind)./recSampInt(overlap_ind);
        if abs([numOverlapSamples - round(numOverlapSamples)]) < gap_tol; % this probably will not happen... if it does, stop the program and deal with it
          keyboard
        else
          numOverlapSamples = round(numOverlapSamples);
          for j=1:nOverlap
            D(j).data = D(j).data(1:end-numOverlapSamples(j));
            D(j).recNumData = D(j).recNumData - numOverlapSamples(j);
          end
        end
      end
      
      clear Dmerge;
      k0=0;
      
      for j=1:nGap+1
        if     nGap==0;    kstart=1;              kend=N;
        elseif j==1;       kstart=1;              kend=gap_ind(j);
        elseif j==nGap+1;  kstart=gap_ind(j-1)+1; kend=N;
        else               kstart=gap_ind(j-1)+1; kend=gap_ind(j);
        end
        k0=k0+1;
        data=D(kstart);
        dat=[];
        numData=0;
        for ktime = kstart:kend;
          dat     = [dat;D(ktime).data];
          numData = numData+D(ktime).recNumData;
        end
        data.data = dat;
        data.recNumData = numData;
        Dmerge(k0)=data;
      end
      
	end
