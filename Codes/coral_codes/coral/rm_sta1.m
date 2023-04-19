function [keep_key,rm_from]=rm_sta(opt,Calib,Label,header1,Delta,Azim,Bakazim);
%   rm_sta        choose seismograms to delete
% Usage: [keep_key,rm_from]=rm_sta(opt,Calib,Label,header1,Delta,Azim,Bakazim);
% called by coral to return indices of seismograms to remove from Data0 or data1
% opt is string matrix containing commands
% Calib and Label are calibration and Labels from Data0
% header1 is header information from data1
% Delta, Azim, and Bakazim are given in degrees for seismograms in Data0
%
% keep_key is an index vector pointing to seismograms to keep
% rm_from is 0 ro 1 to remove data from Data0 or data1
%
% rm ANMO COL PAS ...                     deletes data from Data 0 for listed stations
% rm noinstr                              deletes data with no inst responses from Data 0 
% rm {0 1} {delta azim backazim} min max  deletes data from Data0 or data1 if they lie
%                                         within the min, max bounds
% rm {0 1} index [1:4,9,7]                deletes data from Data0 or data1 given by
%                                         the index vector which must not contain spaces

rm_from=-1;

[smat,n_smat]=cut_string(opt);
comnd = deblank(smat(1,:));   % this should be either 'rm' or 'keep';
if n_smat==1,
  disp(sprintf(' %s requires at least one argument--retry',comnd))
else 
  m_data=length(Calib(1,:));    % number of seismograms
  arg2 = deblank(smat(2,:));
  if strcmp(arg2,'noinstr'),    % remove all stations which do not contain response information
    rm_from=0;
    keep_key=find(Calib(1,:)~=0 & Calib(2,:)~=0);
  elseif any( strcmp(arg2,{'0','1'}))
    % remove data from data 0 or 1 by delta, azim, backazim, index, sample interval or channel
    keep_key=1:m_data; 
    if n_smat<=4
      disp(sprintf('%s 0 or %s 1 requires at least 3 arguments eg. rm 1 delta 40 180',comnd,comnd));
    else
      rm_from=str2num(arg2);
      if rm_from==1,
        if exist('header1')
          INDEX=header1(5,:);
        else
          disp('data1 does not exist--retry')
          break
        end
      else
        INDEX=1:m_data;
      end
      rm_type=deblank(smat(3,:));
      rm_type_index = find( strcmp(rm_type,{'delta','azim','backazim','sintr','index'}) );
      if length(rm_type_index)==1; % rm_type exactly matches one of the options above
        if rm_type_index<=4;  % first 4 styles require lower and upper limits
          if n_smat==5;
            [lower_lim,tmp,err_msg1] = sscanf(smat(4,:),'%f'); 
            [upper_lim,tmp,err_msg2] = sscanf(smat(5,:),'%f'); 
            if length(err_msg1) | length(err_msg1); % if can't interpret as a number
              disp(sprintf('argments 4 and 5 are %s and %s, they must be numbers--retry',smat(4,:),smat(5,:)));
              break
            end
          else
            disp(sprintf('%s by %s requires 4 arguments: eg. rm 0 delta del_min del_max',comnd,rm_type))
          end
          if     rm_type_index==1; vector_key = Delta(INDEX);
          elseif rm_type_index==2; vector_key = Azim(INDEX);
          elseif rm_type_index==3; vector_key = Bakazim(INDEX);
          elseif rm_type_index==4; vector_key = header1(6,INDEX); % sample interval (s)
          elseif rm_type_index==2; vector_key = Azim(INDEX);
          elseif rm_type_index==2; vector_key = Azim(INDEX);
          elseif rm_type_index==2; vector_key = Azim(INDEX);

      if findstr(rm_type,'delta')
        if n_smat==5
          delta_min=str2num( smat(4,:) );
          delta_max=str2num( smat(5,:) );
          keep_key=find(Delta(INDEX)<delta_min | Delta(INDEX)>delta_max );
        else
          disp('rm by delta requires 4 arguments: rm 0 delta del_min del_max')
        end
      elseif findstr(rm_type,'azim')
        if n_smat==5
          azim_min=str2num( smat(4,:) );
          azim_max=str2num( smat(5,:) );
          keep_key=find(Azim(INDEX)<azim_min | Azim(INDEX)>azim_max );
        else
          disp('rm by azim requires 4 arguments: rm 0 azim azm_min azm_max')
        end
      elseif findstr(rm_type,'backazim')
        if n_smat==5
          azim_min=str2num( smat(4,:) );
          azim_max=str2num( smat(5,:) );
          keep_key=find(Bakazim(INDEX)<azim_min | Bakazim(INDEX)>azim_max );
        else
          disp('rm by backazim requires 4 arguments: rm 0 backazim azm_min azm_max')
        end
      elseif findstr(rm_type,'index')
        if n_smat==4
          index_rm=eval(smat(4,:));
          temp=ones(size(INDEX));
          temp(index_rm)=zeros(size(index_rm));
          keep_key=find(temp);
        else
          disp('rm by index requires 4 arguments: rm 0 index [1:3,5,7:9]')
        end
      end
    end
  else

% remove stations from Data 0 by station name

    rm_from=0;
    sta_nam=smat(2:n_smat,:);
    [n_sta,len_sta]=size(sta_nam);
    if len_sta==1
      sta_nam=[sta_nam blanks(n_sta)' blanks(n_sta)' blanks(n_sta)'];
    elseif len_sta==2
      sta_nam=[sta_nam blanks(n_sta)' blanks(n_sta)'];
    elseif len_sta==3
      sta_nam=[sta_nam blanks(n_sta)'];
    else
      sta_nam=sta_nam(:,1:4);
    end
    jj=0; keep_key=zeros(1,m_data);
    for i=1:m_data;
      keep=1;
      for ii=1:n_sta
        if strcmp(sta_nam(ii,:),Label(1:4,i)')
          keep=0;
          break
        end
      end
      if keep, 
        jj=jj+1; 
        keep_key(jj)=i; 
      end
    end
    keep_key=keep_key(1:jj);
  end
end

% print to screen names of deleted stations
if rm_from==0
  INDEX=1:m_data;
  rm_from_label= 'Data';
elseif rm_from==1
  m_data=size(header1,2);
  INDEX=1:m_data;
  INDEX=header1(5,INDEX);
  rm_from_label= 'data1';
end

% make remove key from keep key
temp=ones(1,m_data);
temp(keep_key)=zeros(size(keep_key));
rm_key=find(temp);

% if the command was keep, swap the rm and keep keys
if abs(opt(1:4))==abs('keep')
  temp=rm_key;
  rm_key=keep_key;
  keep_key=temp;
  keep_label=' kept from ';
  key=keep_key;
else
  keep_label=' deleted from ';
  key=rm_key;
end

key
INDEX(key)
if rm_from==0 | rm_from==1,
  if length(keep_key)~=m_data & length(keep_key)
    for k=1:length(key)
      disp([Label(1:4,INDEX(key(k)))' keep_label rm_from_label]);
    end 
  end
end
