function [ST1, ierr] = sort_struct(ST1,ind);
%   sort_struct   sort or remove data from a structure
% USAGE: [ST1, ierr] = sort_struct(ST1,ind);
% 
% Input: 
%   ST1 is a structure
%   ind is a vector of integers of observations to be kept
%   
%
% Output: ST1 is output structure
% 
%   ierr:         =0 : no errors
%                 =1 : input is not a structure
%                 =2 : input is not dimensioned 1x1
%                 =3 : dimensions of fields are not all the same
%                 =4 : max(ind) is greater than the number of data in 
%                      the input structure
%
%  calls whatsin_struct

%  Ken Creager: 6/15/97

ierr=0;
[field_names1, class1, dims1, ierr1] = whatsin_struct(ST1);  % check that ST1 is valid

if ierr1>0,  % the input structure has an error as described in whatsin_struct
  ierr=ierr1;
  return
end

Nfield1=size(dims1,1);                    % number of fields in ST1
N1=dims1(1,1);                            % number of observations in ST1

if max(ind)>N1,
  disp(sprintf(' The input structure contains %d observations, while the %dth was requested',...
       N1, max(ind)))
  ierr=4;
end

for i1=1:Nfield1                      % loop over each field
  fname=field_names1{i1,:};           % get field name
  eval (['V1=ST1.' fname ';']);       % get data from ST1
  V3=V1(ind,:);                       % sort this field
  eval(['ST1.' fname ' = V3;']);      % replace ST1 with merged data
end

% check to make sure all is well with merged structure
[field_names0, class0, dims0, ierr0] = whatsin_struct(ST1); 
ierr=ierr0;
