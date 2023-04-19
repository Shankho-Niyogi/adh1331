function mat = v2m(vec,n);
%   v2m           copy a vector n times into a matrix
% usage: mat = v2m(vec,n);
% if vec is a row (column) vector then mat is a matrix with n 
% rows (columns) each of which is a copy of vec.

[vR,vC] = size(vec);

if vR == 1              % vec is a row vector
  if vC == 1
    error('The input data is a scalar, it must be a vector.')
  end
  mat = zeros(n,vC);
  for i = 1:n
    mat(i,:) = vec;
  end
elseif vC == 1          % vec is a column vector
  if vR == 1
    error('The input data is a scalar, it must be a vector.')
  end
  mat = zeros(vR,n);
  for i = 1:n
    mat(:,i) = vec;
  end
else 		        % vec is not a vector
  error('The input data must be a vector')
end


