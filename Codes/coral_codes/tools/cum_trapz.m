function z = cum_trapz(y);
%   cum_trapz     cumulative integration using the trapezoid rule
% Usage: z = cum_trapz(y);
%    data must be evenly spaced, multiply by sample interval to get integral
%    use trapezoidal rule to integrate the columns of a matrix (or vector) and
%    return a matrix or vector of the same size as that input.  The cumulative
%    integral is returned.
%
%    see also CUMSUM and TRAPZ

z=cumsum(y) - (vec2mat(y(1,:)',size(y,1))' + y)/2;
