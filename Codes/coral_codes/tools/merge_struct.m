function [ST1, ierr] = merge_struct(ST1,ST2);
%   merge_struct  Merge two structures
% USAGE: [ST1, ierr] = merge_struct(ST1,ST2);
% 
% Input: two structures
%   ST1 and ST2 are two structures
%
% Output: ST1 is ST2 appended to the end of ST1
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
 
%  Ken Creager: 6/15/97

ierr=0;
[field_names1, class1, dims1, ierr1] = whatsin_struct(ST1);  % check that ST1 is valid
[field_names2, class2, dims2, ierr2] = whatsin_struct(ST2);  % check that ST2 is valid

if ierr1>0 | ierr2>0,  % one of these structure has an error as described in whatsin_struct
  ierr=max(ierr1,ierr2);
  return
end

Nfield1=size(dims1,1);                    % number of fields in ST1
Nfield2=size(dims2,1);                    % number of fields in ST2
N1=dims1(1,1);                            % number of observations in ST1
N2=dims2(1,1);                            % number of observations in ST2

for i1=1:Nfield1                          % loop over each field in 1
  fname=field_names1{i1,:};               % get field name in 1
  i2 = find(strcmp(fname,field_names2));  % i2 is index to same field name in 2 (if it exists)
  if length(i2)==1,                       % ST2 contains this field name
    if strcmp(class1{i1},class2{i2}) & (dims1(i1,2) == dims2(i2,2)); % do class and dimension match?
      eval (['V1=ST1.' fname ';']);       % get data from ST1
      eval (['V2=ST2.' fname ';']);       % get data from ST2
      V3=[V1 ; V2];                       % merge data
      eval(['ST1.' fname ' = V3;']);      % replace ST1 with merged data
    else;                                 % ERROR: class or dimension does not match
      if strcmp(class1{i1},class2{i2}) 
        ierr=4;
        disp(sprintf('ERROR in ''merge_struct'': field name: %s; dimensions do not match: %d  %d',...
             fname,dims1(i1,2),dims2(i2,2)))
      else
        ierr=5;
        disp(sprintf('ERROR in ''merge_struct'': field name: %s; classes do not match: %s  %s',...
             fname,class1{i1},class2{i2}))
      end
      return
    end
  else;                                   % ST2 does not contain this field name
    disp(sprintf('Field %s is in ST1 but not ST2', fname))
    eval (['V1=ST1.' fname ';']);         % get data from ST1
    if strcmp(class1{i1},'double');       % ST1 contains array of numbers
      V2= NaN+zeros(N2,dims1(i1,2));      % V2 is array of NaN
    elseif strcmp(class1{i1},'cell');     % ST1 contains cell array of character strings
      V2=cell(N2,1);
      for ii=1:N2; V2{ii}=''; end         % fill V2 with empty strings
    end
    V3=[V1 ; V2];                         % merge data
    eval(['ST1.' fname ' = V3;']);        % replace ST1 with merged data
  end
end


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
