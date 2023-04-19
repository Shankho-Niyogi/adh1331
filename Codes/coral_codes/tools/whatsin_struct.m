function [field_names, classes, dims, ierr] = whatsin_struct(ST);
%   whatsin_struct what is in the structure (field names, classes, dimensions)
% USAGE: [field_names, classes, dims, ierr] = whatsin_struct(ST);
%
% Input:  a structure of dimension 1x1
%
% Output:
%   field_names:  column cell vector containing characters strings of field names
%   classes:      column cell vector containing characters strings of classes for 
%                 each field
%   dims:         (Nx2) matrix containing the dimensions of each of the N fields
%   ierr:         =0 : no errors
%                 =1 : input is not a structure
%                 =2 : input is not of dimensions 1x1
%                 =3 : dimensions of fields are not all the same
%
%  Ken Creager: 6/15/97

ierr=0;field_names=[]; classes=[]; dims=[];
if strcmp(class(ST),'struct');  % Is input parameter a structure?
  field_names=fieldnames(ST);   % get the names of the fields
  Nfield=size(field_names,1);   % get the number of fields
else
  disp('Error in ''whatsin_struct'': Input is not a structure')
  ierr=1;
  return
end

if size(ST)~=[1,1], 
  disp('Error in ''whatsin_struct'': Input structure does not have dimensions of 1x1')
  ierr=2;
  return
end

dims=zeros(Nfield,2);    % initialize the number of dimensions of each field
classes=cell(Nfield,1);  % initialize the class names for each field

for i=1:Nfield                        % loop over each field
  fname=field_names{i};               % get field name
  eval (['tmp = ST.' fname ';']);     % get field
  classes{i}=class(tmp);              % get class of field
  dims(i,:)=size(tmp);                % get dimensions of field
end

if dims(:,1)==dims(1,1);              % check to see if all fields have same number of columns
else
  disp('WARNING in ''whatsin_struct'': some fields have different numbers of columns')
  %dims(:,1)
  ierr=3;
  return
end

