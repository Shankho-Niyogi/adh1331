function [rm_from,keep_key]=rm_sta(opt,Calib,Station,header,Delta,Azim,Bakazim);
%   rm_sta        choose seismograms to delete
% Usage: [rm_from,keep_key]=rm_sta(opt,Calib,Station,header,Delta,Azim,Bakazim);
% called by coral to return indices of seismograms to remove from Data0 or data1
% opt is string vector containing commands
% Calib and Station are calibration and Station, Network, Channel names from Data0
% header is header information from data1
% Delta, Azim, and Bakazim are given in degrees for seismograms in Data0
%
% keep_key is an index vector pointing to seismograms to keep
% rm_from is 0 ro 1 to remove data from Data0 or data1
%
% rm ANMO COL PAS ...                     deletes data from Data 0 for listed stations
% rm noinstr                              deletes data with no inst responses from Data 0 
% rm {0 1} {delta azim backazim sintr} min max  deletes data from Data0 or data1 if they lie
%                                         within the min, max bounds (sintr is sample interval (s))
% rm {0 1} noinstr                        deletes data from Data0 or data1 that have no 
%                                         instrument response
% rm {0 1} index [1:4,9,7]                deletes data from Data0 or data1 given by
%                                         the index vector which must not contain spaces
% rm {0 1} {sta net chan} str1 str2 ...   deletes data from Data0 or data1 given by
%                                         list of station names, network codes or channel names

rm_from  = -1;
keep_key = [];
key      = [];
[smat,n_smat]=cut_string(opt);

% get the command (either keep or rm)
if     strcmp(opt(1:2),'rm'),   comnd='rm';
elseif strcmp(opt(1:4),'keep'), comnd='keep';
else   disp(sprintf('The command ''%s'' must be either ''rm'' or ''keep'' --retry',opt(1:4)))
end

if n_smat==1,
  disp(sprintf(' %s requires at least one argument--retry',comnd)); return
end

rm_from_str = deblank(smat(2,:));
if any(strcmp(rm_from_str,{'0','1'}));
  rm_from=str2num(rm_from_str);  % keep/rm data from Data0 or data1
  if n_smat<=2, 
    disp(sprintf(' %s %s requires at least two arguments--retry',comnd,rm_from_str)); return
  else 
    rm_type=deblank(smat(3,:));
  end
  start_opts=4;
elseif strcmp(rm_from_str,'noinstr'),    % remove stations from Data 0 which do not contain response information
  rm_from=0;
  rm_type='noinstr';
  start_opts=3;
else
  rm_from=0;
  rm_type='sta';
  start_opts=2;
end  

if nargout == 1; 
  return
end

if n_smat>=start_opts;
  opts   = smat(start_opts:n_smat,:);
  n_opts = n_smat-start_opts+1;
else 
  opts=[];
  n_opts=0;
end
INDEX=header(5,:);

% keep or remove data from data 0 or 1 by delta, azim, backazim, index, sample interval or channel
m_data=length(INDEX);
%key=[1:m_data]'; % default to keeping all data
RM_TYPE={'delta';'azim';'backazim';'sintr';'index';'noinstr';'sta';'chan';'net'};
rm_type_index = find( strcmp(rm_type,RM_TYPE) );
if length(rm_type_index)==1; % rm_type exactly matches one of the options above
  if rm_type_index<=4;  % first 4 styles require lower and upper limits
    if n_opts==2;
      [lower_lim,tmp,err_msg1] = sscanf(opts(1,:),'%f'); 
      [upper_lim,tmp,err_msg2] = sscanf(opts(2,:),'%f'); 
      if length(err_msg1) | length(err_msg1); % if can't interpret as a number
        disp(sprintf('arguments 4 and 5 are %s and %s, they must be numbers--retry',deblank(opts(1,:)),deblank(opts(2,:))));
        return
      end
    else
      disp(sprintf('%s by %s requires 4 arguments: eg. %s 0 delta 45 60',comnd,rm_type,comnd))
      return
    end
    if     rm_type_index==1; vector_key = Delta(INDEX);
    elseif rm_type_index==2; vector_key = Azim(INDEX);
    elseif rm_type_index==3; vector_key = Bakazim(INDEX);
    elseif rm_type_index==4; vector_key = header(6,:); % sample interval (s)
    end
    key=find(vector_key>lower_lim & vector_key<=upper_lim);
  elseif rm_type_index==5;  % fifth style is index
    if n_opts==1
      key=eval(opts(1,:),'0');
      if length(key)==1;  
       if key==0;
        disp(sprintf('%s cannot interpret %s as a vector of integers--retry',comnd,deblank(opts(1,:))));
        return
       end
      end
    else
      disp(sprintf('%s by index requires 3 arguments: eg. %s 0 index [1:3,5,7:9]',comnd,comnd))
    end
  elseif rm_type_index==6;  % sixth style is noinstr ie remove data with no instrument response
    key=find(Calib(1,INDEX)==0 | Calib(2,INDEX)==0); % key to stations with no instrument responses
  elseif rm_type_index>=7 & rm_type_index<=9;  % seventh-ninth style is strings
    if n_opts<1 
      disp(sprintf('%s by %s requires 3 or more arguments: eg. %s 1 %s ANMO PAS',comnd,rm_type,comnd,rm_type))
    else
      keep_str=opts;
      [n_str,len_str]=size(keep_str);
      if     rm_type_index==7; Sta_ind=2:5;  % index to station names
      elseif rm_type_index==8; Sta_ind=8:10; % index to channel names 
      elseif rm_type_index==9; Sta_ind=13:14;% index to network names
      end
      strlen=length(Sta_ind);
      for k=len_str+1:strlen ;keep_str=[keep_str blanks(n_str)']; end; % force names to be correct length
      keep_str  = keep_str(:,1:strlen);
      data_str  = setstr(Station(Sta_ind,INDEX)');       % names from data in data 0 or 1
      key = find(strcmp2(data_str,keep_str));            % key to matches in station names
      if rm_type_index==8;
        if length(findstr('*',keep_str(:)'))>0;          % there are wild cards
          tmp_key=zeros(m_data,1);
          for k=1:n_str 
            ind = find('***' ~= keep_str(k,:));
            if length(ind)==0;
              tmp_key=tmp_key+1;
            else
              tmp_key = tmp_key+strcmp2(data_str(:,ind),keep_str(k,ind));
            end
          end
          key=find(tmp_key);
        end  
      end    
    end
  end
else
  disp(sprintf('%s option for ''%s'' must be one of %s, %s, %s, %s, %s, %s, %s, %s, %s', rm_type,comnd,RM_TYPE{1:9}))
  return
end
% key is the index vector that points to data to be kept (if command is keep)
% or to be removed (if command is rm)
% but this routine returns data to be kept, so if command is rm
% set keep key to the inverse of key
if strcmp(comnd,'keep')
  keep_key=key;
else
  temp=ones(1,m_data);
  temp(key)=zeros(size(key));
  keep_key=find(temp);
end

%keyboard
% if not keeping all or none of the data, write station names being kept or removed
nsta_line=20; % number of stations written on each line
if rm_from==0 | rm_from==1,
  if length(key)~=m_data & length(key)~=0; 
    nkey = length(key);
    for k=1:ceil(nkey/nsta_line);
      ind = (k-1)*nsta_line+1 : min(nkey,k*nsta_line);
      tmp = Station(1:5,INDEX(key(ind)));
      disp(sprintf('%s %d %s',comnd, rm_from, tmp(:)'));
    end
  end
end
