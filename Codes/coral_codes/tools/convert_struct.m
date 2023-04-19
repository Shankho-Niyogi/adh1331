function [ST1] = convert_struct(ST);
%   convert_struct convert structure format from 'element' to 'plane'
% USAGE: [ST1] = convert_struct(ST);
%
% matlab script to change a 'element' structure
% to a 'plane' structure
% this assumes the input structure is a vector of length N_data
% containing Nfield fields.  Fields are assumed to be either
% double precission numbers, or cells of character arrays.  

% Ken Creager 6/97

field_names=fieldnames(ST);             % get the field names
Nfield=size(field_names,1);             % get the number field names
N_data=size(ST,2);                      % get the number of elements in the strucutre

for i=1:Nfield                          % loop over each field
  fname=field_names{i,1};
  eval([ 'class_temp=class(ST(1).' fname ');']); % get class of field (numbers or characters)
  if strcmp(class_temp,'double');                % if vector of numbers
    eval (  ['temp= [ST.' fname '];' ]  ); 
    temp=temp';
  elseif strcmp(class_temp,'char') ;             % if cell of character strings 
    eval (  ['temp= {ST.' fname '};' ]  )
    temp=temp';    
  end
  eval (['ST1.' fname '= temp;'])                % dump data into new structure called ST1
end 
