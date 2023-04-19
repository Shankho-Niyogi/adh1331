function [diff_field1,diff_field2,ierr,summary] = coralCompareStruct(ST1,ST2);
%     coralCompareStruct    compare two coral structures
%
% Input:  two structures of dimension 1x1
%
% Output:
%   diff_field1   vector of length number of fields in ST1
%   diff_field1   = 0 if the field exists in ST2 and has the same contents
%                 = 1 if field name does not exist in ST2
%                 = 2 if field has different class, dimensions or values
%                 = 3 if field is not of class double or char
%   diff_field2   same as diff_field1 except it keeps track of ST2
%   ierr          = 0 no errors
%                 = 1 if ST1 or ST2 is not a structure
%                 = 2 if ST1 or ST2 is not of dimension 1x1
%   summary       structure containing fields:
%     in1butNot2  cell array of names of fields in ST1 but not in ST2
%     in2butNot1  cell array of names of fields in ST2 but not in ST1
%     diffValues  cell array of names of fields that contain different values
%               
%  Ken Creager: 08/18/2005

diff_field1=[];
diff_field2=[];
[field_names1, class1, dims1, ierr1] = whatsin_struct(ST1);  % check that ST1 is valid
[field_names2, class2, dims2, ierr2] = whatsin_struct(ST2);  % check that ST2 is valid

ierr=0;
if (ierr1>0 & ierr1~=3) ierr=ierr1; end
if (ierr2>0 & ierr2~=3) ierr=ierr2; end
if ierr>0; return; end

Nfield1=size(dims1,1);                    % number of fields in ST1
Nfield2=size(dims2,1);                    % number of fields in ST2

diff_field1=zeros(Nfield1,1);
diff_field2=ones(Nfield2,1);              % assume fields in ST2 are missing until found

for i1=1:Nfield1                          % loop over each field in 1
  fname=field_names1{i1,:};               % get field name in 1
  i2 = find(strcmp(fname,field_names2));  % i2 is index to same field name in 2 (if it exists)
  if length(i2)~=1,                       % ST2 does not contain this field name
    diff_field1(i1)=1;
  else                                    % ST2 contains this field name
    diff_field1(i1)=0;
    diff_flag=2;
    if strcmp(class1{i1},class2{i2}) & (dims1(i1,1) == dims2(i2,1)) & (dims1(i1,2) == dims2(i2,2)); % do class and dimension match?
      if sum(dims1(i1,:)) == 0;             % field is empty for both structure so they are the same
        diff_flag=0;                      
      else
        eval (['V1=ST1.' fname ';']);       % get data from ST1
        eval (['V2=ST2.' fname ';']);       % get data from ST2
        if strcmp(class1{i1},'double');
          V1f=isfinite(V1);
          V2f=isfinite(V2);
          if max(abs((V2f(:)-V1f(:)))) == 0; % do both fields contain finite data in the same places
            if sum(V1f(:)) == 0;             % all are non-finite, so fields are the same
              diff_flag=0;
            elseif max(abs(V2(:)-V1(:))) < eps;  % are the data identical to machine precision?
              diff_flag=0;
            end
          end
        elseif strcmp(class1{i1},'char');
          if strcmp(V2,V1);                  % are character strings identical?
            diff_flag=0;
          end
        end
      end
    end                                  
    diff_field1(i1)=diff_flag;            % = 0 if data in the field have same class, dimensions and values
    diff_field2(i2)=diff_flag;            % = 0 if data in the field have same class, dimensions and values
                                          % = 2 otherwise
  end
end

if nargout>3;
  summary.in1butNot2 = sort( field_names1( find(diff_field1==1) ) );
  summary.in2butNot1 = sort( field_names2( find(diff_field2==1) ) );
  summary.diffValues = sort( field_names1( find(diff_field1==2) ) );
end
