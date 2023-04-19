function mat=vec2mat(vec,n);
%   vec2mat       copy a vector n times into a matrix
% usage: mat=vec2mat(vec,n);
% vec must be a column vector
% mat is a matrix with n columns containing n copies of vector vec.

if size(vec,2) > 1,
  error('error in vec2mat.m, vec must be a column vector')
else
  mat = vec(:,ones(1,n));
end
