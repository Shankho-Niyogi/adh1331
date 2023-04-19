function [ierr,IND1,IND2, ST1,ST2] = combine_struct(ST1,ST2,mustmatch,match,Tol);
%   combine_struct  Combine  two structures
% USAGE: [ierr,IND1,IND2, ST1,ST2] = combine_struct(ST1,ST2,mustmatch,match,Tol);
% 
% Input:
%  ST1 and ST2 are two structures each of dimension (1,1)
%               they contain fields that are either cell arrays (column vectors) of strings or 
%               columns vectors or matrices of numbers (class = double)
%               all fields withing ST1 (or ST2)  must have the same number of columns
%  mustmatch    is a cell array of field names that must match
%  match        is an optional  cell array of field names that
%               must match if the fields exist and are not empty or NaN
%  Tol          n x 2 cell array containing field names in the first column 
%               and tolerances in the second.  default tolerance is zero
%               tolerance for fields of strings is ignored
%
% Output: ST2 is merged into ST1 if all the requested fields match
% 
%   ierr:         =0 : no errors
%                 =1 : one of inputs is not a structure
%                 =2 : one of inputs is not dimensioned 1x1
%                 =3 : dimensions of fields are not all the same
%                 =4 : a field name is common to ST1 and ST2 but
%                      contains different classes of data
%                 =5 : a field name is common to ST1 and ST2 but
%                      contains different numbers of rows
%
%  calls whatsin_struct
%ST1=Pick1;ST2=Pick1;mustmatch={'StaName' 'PhaseName' 'EqLat' 'EqLon'};match={'NetName' 'LocName'}; Tol = {'EqLat', 0.5 ; 'EqLon',1};
 
%  Ken Creager: 6/15/97


% first check that the two input structures are valid, and get the
% names, classes and dimensions of each field 
ierr=0;

if nargin <3;
  disp('Error:  Not enough input arguments for combine_struct')
  ierr=1;
  return
elseif nargin==3;
  match={}; Tol={'',0};
elseif nargin==4;
  Tol={'',0};
end

  
[field_names1, class1, dims1, ierr1] = whatsin_struct(ST1);  % check that ST1 is valid
[field_names2, class2, dims2, ierr2] = whatsin_struct(ST2);  % check that ST2 is valid

if ierr1>0 | ierr2>0,  % one of these structure has an error as described in whatsin_struct
  ierr=max(ierr1,ierr2);
  return
end

Nmust = length(mustmatch);     % number of fields that must match
N1    = dims1(1,1);            % number of observations in ST1
N2    = dims2(1,1);            % number of observations in ST2
ind1  = [];
ind2  = [];
Ffield= mustmatch(:);


% For each of the field names in cell array "match" add that name to cell array "mustmatch" 
% if that field exists in each of the input structures; put result in "Ffield"
for imatch=1:length(match);
  fname=match{imatch};                    % get field name that must match
  i1 = find(strcmp(fname,field_names1));  % i1 is index to same field name in 1
  i2 = find(strcmp(fname,field_names2));  % i2 is index to same field name in 2
  if length(i1)==1 & length(i2)==1;
	Ffield{end+1,1} = fname;
  end
end

% For each of the field names in cell array "Ffield" check that this field exists in each 
% of the input structures and that the class and dimensions match for each field
Nfield      = length(Ffield);           % number of fields to match
ind1        = zeros(Nfield,1);
ind2        = zeros(Nfield,1);
for ifield=1:Nfield;                      % loop over each field that must match
  fname=Ffield{ifield};               % get field name that must match
  i1 = find(strcmp(fname,field_names1));  % i1 is index to same field name in 1
  i2 = find(strcmp(fname,field_names2));  % i2 is index to same field name in 2
  if length(i1)==1 & length(i2)==1;         % ST1 and ST2 contains this field name
    if strcmp(class1{i1},class2{i2}) & (dims1(i1,2) == dims2(i2,2)); % do class and dimension match?
	  ind1(ifield)=i1;
	  ind2(ifield)=i2;
    else;                                 % ERROR: class or dimension does not match
      if strcmp(class1{i1},class2{i2}) 
        ierr=4;
        disp(sprintf('ERROR in ''combine_struct'': field name: %s; dimensions do not match: %d  %d',...
             fname,dims1(i1,2),dims2(i2,2)))
      else
        ierr=5;
        disp(sprintf('ERROR in ''combine_struct'': field name: %s; classes do not match: %s  %s',...
             fname,class1{i1},class2{i2}))
      end
      return
    end
  elseif length(i1)~=1;                                   % ST1 does not contain this field name
    disp(sprintf('Field %s is not in ST1', fname));
	ierr=1;
  elseif length(i2)~=1;                                   % ST2 does not contain this field name
    disp(sprintf('Field %s is not in  ST2', fname))
	ierr=2;
  end
end
Cfield = class1(ind1);      % class for each field to match
Dfield = dims1(ind1,2);     % dimensions for each field to match
Tfield = cell(Nfield,1);    % tolerance for each field to match
for ifield=1:Nfield;                      % loop over each field that must match
  fname=Ffield{ifield};               % get field name that must match  fname=Ffield{ifield};               % get field name that must match
  ind = find( strcmp(fname,Tol(:,1)) );
  if length(ind)==1; 
    Tfield{ifield,1} = Tol{ind,2}; 
  else
    Tfield{ifield,1} = 0;
  end
  if (Dfield(ifield,1)>1 & length(Tfield{ifield,1}))==1;
	Tfield{ifield,1} = zeros(1,Dfield(ifield,1)) + Tfield{ifield,1};
  end
end
 
IND2   = zeros(N1,1);

comnd={};
if ierr==0 & length(ind1)>0;
  
  % %%%%%%%  build an vector of 'find' commands for each field  %%%%%%%%%
  
  for ifield=1:Nfield;  % loop over all fields to match
	fname = Ffield{ifield};
    if strcmp(Cfield{ifield},'cell') 
	  if ifield <= Nmust
        comnd{end+1,1} = sprintf ('tmp = find(strcmp(ST1.%s{i1} , ST2.%s(ind)));',fname, fname);
      else
        comnd{end+1,1} = sprintf ('tmp = find(strcmp(ST1.%s{i1} , ST2.%s(ind))  |  strcmp('' , ST1.%s{i1}) | strcmp('' , ST2.%s(ind)));',...
                                 fname, fname, fname, fname);
      end
    elseif strcmp(Cfield{ifield},'double');
	  if ifield <= Nmust
        for icolumn = 1:Dfield(ifield)
          comnd{end+1,1} = sprintf ('tmp = find(abs(ST1.%s(i1,%d)  -  ST2.%s(ind,%d))<=Tfield{%d,1}(%d));', ...
			                     fname, icolumn, fname, icolumn, ifield, icolumn);
        end
      else
        for icolumn = 1:Dfield(ifield)
          comnd{end+1,1} =sprintf ('tmp = find(abs(ST1.%s(i1,%d)  -  ST2.%s(ind,%d))<=Tfield{%d,1}(%d)) | isnan( ST1.%s(i1,%d)) | isnan(ST2.%s(ind,%d));', ...
                                 fname, icolumn, fname, icolumn, ifield, icolumn, fname, icolumn, fname, icolumn);
        end	  
	  end
    end
  end

% now find index from 1 to 2 that makes all the values in the fields ind1 match those in the fields from ind2

  for i1=1:N1;    % loop over each row in ST1
    ind = [1:N2]';
    for icomnd = 1:length(comnd);  % loop over all fields to match
      eval(comnd{icomnd})
      if length(tmp)==0; ind=[]; break; else; ind=ind(tmp); end
    end
    if length(ind)==1;
      IND2(i1)=ind;
    elseif length(ind)>1;  
      IND2(i1) = -length(ind);
    end
  end
end



if length(IND2)>0;
  IND1 = find(IND2>0);
  IND2 = IND2(IND1);
else
  IND1 = [];
  IND2 = [];
  ST1 = sort_struct(ST1,find(IND1>0));
  ST2 = sort_struct(ST2,IND1);
end

if nargout>3; 
  ST1 = sort_struct(ST1,IND1);
  ST2 = sort_struct(ST2,IND2);
end



return




% now find index from 1 to 2 that makes all the values in the fields ind1 match those in the fields from ind2
if ierr==0 & length(ind1)>0;
  for i1=1:N1;    % loop over each row in ST1
    ind = [1:N2]';
    for ifield=1:Nfield;  % loop over all fields to match
      if strcmp(Cfield{ifield},'cell');
        eval ( sprintf ('tmp = find(strcmp(ST1.%s{i1} , ST2.%s(ind)));',Ffield{ifield}, Ffield{ifield}));
        if length(tmp)==0 break; else ind=ind(tmp); end
      elseif strcmp(Cfield{ifield},'double');
        for icolumn = 1:Dfield(ifield)
          eval ( sprintf ('tmp = find(abs(ST1.%s(i1)  -  ST2.%s)<Tfield(ifield)));',Ffield{ifield}, Ffield{ifield}));
          if length(tmp)==0 break; else ind=ind(tmp); end
        end
      end
    end
    if length(ind)==1;
      IND1(i1)=ind;
    elseif length(ind)>1;  
      IND1(i1) = -length(ind);
    end
  end
end





IND1
return

for i=1:N	  
  k_ev = find(abs( evnt_time1(i) - evnt_time2 ) < opts.event_tol);  % event matches
 if length(k_ev)>0;
  nn=nn+1;I(nn)=i;
  k_st = find(strcmp(D1.StaName{i},D2.StaName(k_ev)));        % and stations match
  if length(k_st)>0;
   disp(sprintf('%f12.4 %c', D1.EqDate(i),D1.StaName{i}));
   k_ph = find(strcmp(D1.PhaseName{i},D2.PhaseName(k_ev(k_st)))); % and phase matches
   if length(k_ph)>0;            % if at least one match
    j=k_ev(k_st(k_ph));         % index of matches
    if length(k_ph)>1;           % if more than one match write error message and use first match
     disp (sprintf('%5d %5d %5d %s %12.6f',i,j,D1.StaName{i},evnt_time1(i)/3600/24));
	 j=j(1);
    end
    n=n+1;
    DT(n)      = pick_time2(j) - pick_time1(i);
    QUAL2(n,:) = [D2.TTimeQual(j) , D1.TTimeQual(i)];
    EqDate(n)  = D1.EqDate(i);
    EqTime(n)  = D1.EqTime(i);
	Indx(n,1:2)= [i,j];    
   end
  end
 end
end
return


for i2=1:Nfield2                          % loop over each field in 2
  fname=field_names2{i2,:};               % get field name in 1
  i1 = find(strcmp(fname,field_names1));  % i1 is index to same field name in 1 (if it exists)
  if length(i1)==0,                       % ST1 does not contain this field name
    disp(sprintf('Field %s is in ST2 but not ST1', fname))
    eval (['V2=ST2.' fname ';']);         % get data from ST2
    if strcmp(class2{i2},'double');       % ST2 contains array of numbers
      V1= NaN+zeros(N1,dims2(i2,2));      % V1 is array of NaN
    elseif strcmp(class2{i2},'cell');     % ST2 contains cell array of character strings
      V1=cell(N1,1);
      for ii=1:N1; V1{ii}=''; end         % fill V1 with empty strings
    end
    V3=[V1 ; V2];                         % merge data
    eval(['ST1.' fname ' = V3;']);        % replace ST1 with merged data
  end
end

% check to make sure all is well with merged structure
[field_names0, class0, dims0, ierr0] = whatsin_struct(ST1); 
ierr=ierr0;
