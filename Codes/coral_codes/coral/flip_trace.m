function [data] = flip_trace(data, trace_vec);
%   flip_trace    flip the sign of a seismogram
% usage: [data] = flip_trace(data, trace_vec);
%
%  flips the data traces for the columns of the data vector indicated
%  by the trace_vec... if a column out of the limits of the data
%  array is indicated in the trace_vec vector, returns after error message

[n,m] = size(data);
max_no = max(trace_vec);
if max_no > m,
  ncols = int2str(m);
  maxcol = int2str(max_no);
  echo_ml(' ')
  echo_ml(' Data matrix unchanged, column number larger than size of')
  echo_ml('  input data matrix given in trace vector...')
  echo_ml(['     number of columns = ',ncols,'    max of trace_vec = ',maxcol]);
else,
  data(:,trace_vec) = (-1) .* data(:,trace_vec);
end;
