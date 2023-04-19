function corr = mb_corr(depth, dist);
%   mb_corr       attenuation correction for body wave magnitude (mb) 
% USAGE: corr = mb_corr(depth, dist);
% 
% Evaluate the distance and depth corrections for body wave magnitude
% from Veith and Clawson, BSSA, (62), 435-453, 1972
% input is column vectors of earthquake depths (km) and epicentral distances (deg)
% output is the corrections
% mb = log10(A/T) + corr
% where A is the peak-to-peak amplitude of the first few cycles of the short period  P wave
% in milli microns (10^-9) m and T is the dominant period (s)
% written by Ken Creager 2/1/00


global MB_TABLE MB_DEPTH MB_DISTANCE 

if length(MB_TABLE) ~= 101;   % if MB_TABLE has not been read, read it
  A=[0   0     15     40    100    200    300    400    500    600    700    800
  0      0  -1.82  -1.44  -0.80  -0.36  -0.10   0.08   0.22   0.34   0.44   0.52
  1   0.89   2.92   2.16  -0.31  -0.19  -0.01   0.12   0.25   0.36   0.46   0.53
  2   2.07   2.02   2.29   0.39   0.17   0.19   0.25   0.33   0.42   0.50   0.56
  3   2.20   2.23   2.53   0.94   0.55   0.44   0.41   0.45   0.50   0.57   0.62
  4   2.55   2.53   2.72   1.36   0.89   0.69   0.60   0.58   0.61   0.65   0.68
  5   2.76   2.73   2.87   1.68   1.19   0.93   0.78   0.73   0.73   0.75   0.76
  6   2.90   2.86   2.99   1.95   1.46   1.14   0.95   0.87   0.84   0.84   0.84
  7   3.02   2.97   3.08   2.18   1.69   1.32   1.10   1.00   0.95   0.94   0.92
  8   3.10   3.04   3.13   2.37   1.88   1.47   1.23   1.12   1.06   1.04   1.00
  9   3.15   3.09   3.17   2.52   2.03   1.59   1.35   1.24   1.17   1.14   1.09
 10   3.19   3.13   3.19   2.63   2.14   1.69   1.45   1.34   1.27   1.23   1.17
 11   3.23   3.16   3.20   2.72   2.21   1.76   1.54   1.43   1.37   1.32   1.25
 12   3.25   3.18   3.21   2.79   2.25   1.79   1.62   1.52   1.47   1.41   1.32
 13   3.26   3.19   3.21   2.84   2.26   1.82   1.68   1.60   1.56   1.49   1.39
 14   3.26   3.19   3.21   2.85   2.23   1.86   1.74   1.68   1.64   1.57   1.45
 15   3.25   3.17   3.17   2.79   2.18   1.90   1.80   1.76   1.72   1.64   1.50
 16   3.21   3.11   3.08   2.68   2.15   1.95   1.87   1.84   1.80   1.71   1.55
 17   3.10   3.00   2.94   2.54   2.16   2.01   1.95   1.92   1.87   1.78   1.60
 18   2.98   2.85   2.75   2.46   2.19   2.07   2.02   2.00   1.94   1.84   1.64
 19   2.79   2.71   2.63   2.45   2.24   2.14   2.10   2.07   2.01   1.88   1.68
 20   2.77   2.71   2.62   2.48   2.30   2.22   2.18   2.15   2.07   1.91   1.71
 21   2.80   2.75   2.65   2.54   2.38   2.30   2.27   2.22   2.13   1.93   1.74
 22   2.85   2.82   2.71   2.61   2.46   2.39   2.35   2.28   2.17   1.94   1.76
 23   2.94   2.89   2.79   2.69   2.56   2.48   2.43   2.33   2.19   1.94   1.78
 24   3.04   2.99   2.87   2.78   2.66   2.56   2.50   2.37   2.20   1.95   1.80
 25   3.15   3.09   2.97   2.88   2.74   2.62   2.54   2.39   2.20   1.96   1.82
 26   3.25   3.19   3.06   2.97   2.80   2.66   2.56   2.39   2.19   1.97   1.84
 27   3.35   3.27   3.13   3.04   2.83   2.68   2.57   2.38   2.19   1.98   1.86
 28   3.42   3.33   3.18   3.07   2.84   2.69   2.56   2.38   2.18   1.99   1.88
 29   3.44   3.35   3.19   3.08   2.85   2.69   2.54   2.38   2.18   2.00   1.90
 30   3.42   3.33   3.20   3.08   2.85   2.68   2.53   2.37   2.18   2.01   1.92
 31   3.38   3.31   3.20   3.07   2.84   2.67   2.52   2.37   2.19   2.03   1.94
 32   3.36   3.29   3.19   3.06   2.83   2.66   2.51   2.37   2.20   2.04   1.96
 33   3.36   3.28   3.18   3.05   2.82   2.66   2.51   2.37   2.21   2.05   1.97
 34   3.35   3.27   3.16   3.04   2.81   2.65   2.51   2.37   2.22   2.06   1.99
 35   3.34   3.26   3.15   3.03   2.80   2.64   2.51   2.37   2.23   2.07   2.00
 36   3.34   3.25   3.14   3.02   2.80   2.64   2.51   2.37   2.24   2.09   2.02
 37   3.34   3.25   3.13   3.01   2.79   2.64   2.51   2.38   2.24   2.10   2.04
 38   3.33   3.24   3.12   3.00   2.79   2.63   2.51   2.38   2.25   2.11   2.05
 39   3.33   3.24   3.12   3.00   2.79   2.63   2.51   2.39   2.26   2.12   2.07
 40   3.32   3.24   3.11   2.99   2.78   2.63   2.52   2.40   2.27   2.13   2.08
 41   3.32   3.24   3.11   2.99   2.78   2.64   2.52   2.40   2.28   2.15   2.09
 42   3.32   3.24   3.11   2.99   2.79   2.64   2.53   2.41   2.29   2.16   2.11
 43   3.33   3.24   3.11   2.99   2.79   2.65   2.54   2.42   2.30   2.17   2.12
 44   3.33   3.24   3.11   2.99   2.80   2.65   2.54   2.43   2.31   2.18   2.13
 45   3.34   3.25   3.11   3.00   2.81   2.66   2.55   2.43   2.32   2.19   2.15
 46   3.34   3.25   3.12   3.00   2.81   2.67   2.56   2.44   2.33   2.21   2.16
 47   3.35   3.26   3.12   3.01   2.82   2.67   2.57   2.45   2.34   2.22   2.17
 48   3.36   3.26   3.13   3.02   2.83   2.68   2.57   2.46   2.35   2.23   2.18
 49   3.36   3.27   3.14   3.02   2.83   2.69   2.58   2.47   2.36   2.24   2.19
 50   3.37   3.28   3.14   3.03   2.84   2.70   2.59   2.48   2.37   2.26   2.21
 51   3.37   3.28   3.15   3.04   2.85   2.70   2.60   2.49   2.38   2.27   2.22
 52   3.38   3.29   3.16   3.04   2.86   2.71   2.61   2.50   2.39   2.28   2.23
 53   3.39   3.30   3.16   3.05   2.86   2.72   2.62   2.51   2.40   2.29   2.24
 54   3.39   3.30   3.17   3.06   2.87   2.73   2.63   2.52   2.41   2.31   2.25
 55   3.40   3.31   3.18   3.06   2.88   2.73   2.64   2.53   2.42   2.32   2.26
 56   3.40   3.32   3.18   3.07   2.88   2.74   2.64   2.54   2.43   2.33   2.27
 57   3.41   3.32   3.19   3.08   2.89   2.75   2.65   2.54   2.44   2.34   2.29
 58   3.42   3.33   3.19   3.08   2.90   2.76   2.66   2.55   2.45   2.35   2.30
 59   3.42   3.34   3.20   3.09   2.91   2.76   2.67   2.56   2.46   2.37   2.31
 60   3.43   3.34   3.20   3.10   2.91   2.77   2.68   2.57   2.47   2.38   2.32
 61   3.44   3.35   3.21   3.10   2.92   2.78   2.68   2.58   2.48   2.39   2.33
 62   3.44   3.35   3.21   3.11   2.93   2.79   2.69   2.59   2.49   2.40   2.34
 63   3.45   3.36   3.22   3.12   2.93   2.80   2.70   2.60   2.50   2.41   2.35
 64   3.45   3.36   3.22   3.12   2.94   2.80   2.71   2.61   2.51   2.42   2.36
 65   3.46   3.37   3.23   3.13   2.95   2.81   2.72   2.62   2.52   2.43   2.37
 66   3.46   3.38   3.24   3.14   2.95   2.82   2.73   2.62   2.53   2.44   2.38
 67   3.47   3.38   3.24   3.14   2.96   2.83   2.74   2.63   2.54   2.45   2.39
 68   3.48   3.39   3.25   3.15   2.97   2.84   2.74   2.64   2.55   2.46   2.40
 69   3.48   3.39   3.25   3.16   2.98   2.84   2.75   2.65   2.56   2.47   2.41
 70   3.49   3.40   3.26   3.16   2.98   2.85   2.76   2.66   2.56   2.48   2.42
 71   3.50   3.40   3.26   3.16   2.99   2.86   2.77   2.67   2.57   2.49   2.43
 72   3.50   3.41   3.27   3.17   3.00   2.86   2.77   2.68   2.58   2.49   2.44
 73   3.51   3.42   3.27   3.17   3.00   2.87   2.78   2.68   2.59   2.50   2.45
 74   3.51   3.42   3.28   3.18   3.01   2.88   2.79   2.69   2.59   2.50   2.46
 75   3.52   3.43   3.28   3.18   3.01   2.88   2.79   2.70   2.60   2.51   2.47
 76   3.53   3.43   3.29   3.19   3.02   2.89   2.80   2.70   2.61   2.52   2.47
 77   3.53   3.44   3.29   3.19   3.02   2.89   2.80   2.70   2.61   2.52   2.48
 78   3.54   3.44   3.30   3.20   3.02   2.90   2.81   2.71   2.62   2.52   2.48
 79   3.54   3.45   3.30   3.20   3.03   2.90   2.81   2.71   2.62   2.53   2.49
 80   3.55   3.45   3.31   3.20   3.03   2.90   2.81   2.72   2.63   2.54   2.50
 81   3.56   3.46   3.31   3.20   3.03   2.91   2.83   2.73   2.64   2.56   2.52
 82   3.57   3.46   3.32   3.21   3.04   2.92   2.85   2.74   2.66   2.58   2.55
 83   3.58   3.47   3.33   3.23   3.05   2.94   2.87   2.76   2.68   2.60   2.58
 84   3.59   3.49   3.34   3.25   3.06   2.96   2.89   2.78   2.70   2.63   2.61
 85   3.61   3.51   3.36   3.27   3.08   2.99   2.91   2.80   2.73   2.66   2.65
 86   3.64   3.53   3.38   3.30   3.10   3.01   2.93   2.83   2.76   2.69   2.69
 87   3.66   3.55   3.40   3.32   3.14   3.03   2.95   2.87   2.80   2.73   2.73
 88   3.68   3.58   3.44   3.34   3.18   3.07   2.99   2.91   2.84   2.77   2.78
 89   3.72   3.62   3.48   3.38   3.22   3.11   3.03   2.95   2.88   2.82   2.84
 90   3.76   3.66   3.52   3.42   3.26   3.15   3.08   3.00   2.94   2.88   2.91
 91   3.80   3.70   3.56   3.46   3.31   3.20   3.13   3.06   3.00   2.96   2.97
 92   3.85   3.75   3.61   3.51   3.37   3.26   3.20   3.13   3.08   3.03   3.03
 93   3.91   3.81   3.67   3.57   3.44   3.34   3.28   3.21   3.16   3.11   3.11
 94   3.98   3.89   3.75   3.65   3.52   3.42   3.36   3.29   3.24   3.19   3.19
 95   4.06   3.97   3.83   3.73   3.60   3.50   3.44   3.37   3.32   3.27   3.27
 96   4.14   4.05   3.91   3.81   3.68   3.58   3.52   3.45   3.40   3.36   3.35
 97   4.22   4.13   3.99   3.89   3.76   3.66   3.60   3.53   3.48   3.43   3.43
 98   4.30   4.21   4.07   3.97   3.84   3.74   3.68   3.61   3.56   3.51   3.51
 99   4.38   4.29   4.15   4.05   3.92   3.82   3.76   3.69   3.64   3.59   3.59
 100  4.46   4.37   4.23   4.13   4.00   3.90   3.84   3.77   3.72   3.67   3.67];

 MB_DISTANCE = A(2:end,1); 
 MB_DEPTH = A(1,2:end); 
 MB_TABLE =A(2:end,2:end);
end

corr = interp2(MB_DEPTH,MB_DISTANCE,MB_TABLE,depth(:),dist(:),'linear'); 