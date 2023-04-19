function calib=get_inst_resp(inst_type);
%   get_inst_resp get standard instrument responses
% usage  calib=get_inst_resp(inst_type);
%
% return a complex column vector containing 62 elements that stores 
% a standard instrument response
% enter one of s, l, or i for the DWWSSN short, long, or intermediate-period
% response with a gain of one
% or try 'r' for the vertical component of the REFTEK response for the UW station at LON.

calib=zeros(62,1);

if      inst_type=='s',

  % short-period DWSSN instrument response
  calib(1:3)=[0.11500E+08 1.0 9]'; calib(33)=5;
  poles=[       
  -0.17500E+02  0.00000E+00
  -0.42400E+01  0.63700E+01
  -0.42400E+01 -0.63700E+01
  -0.83800E+01  0.00000E+00
  -0.83800E+01  0.00000E+00
  -0.15700E+03  0.00000E+00
  -0.15700E+03  0.00000E+00
  -0.62800E-01  0.00000E+00
  -0.62800E-01  0.00000E+00];
  calib(4:12)=poles(:,1)+i*poles(:,2);

elseif  inst_type=='b'
  % IRIS/USGS Response at COR, PAS, and TUC for broad-band and long-period channels
  calib(1:3)= [0.314339e+05 1.0 4]; calib(33)=3;
  poles=[
  -0.0123   0.0123
  -0.0123  -0.0123
 -39.1800  49.1200
 -39.1800 -49.1200  ];
   calib(4:7)=poles(:,1)+i*poles(:,2);

elseif  inst_type=='l'
  % long-period DWSSN instrument response
  calib(1:3)= [0.24300E-01 1.0 11]; calib(33)=5;
  poles=[
  -0.36900E+00  0.19900E+00
  -0.36900E+00 -0.19900E+00
  -0.62800E+00  0.00000E+00
  -0.27300E+00  0.00000E+00
  -0.27300E+00  0.00000E+00
  -0.27300E+00  0.00000E+00
  -0.27300E+00  0.00000E+00
  -0.27300E+00  0.00000E+00
  -0.27300E+00  0.00000E+00
  -0.20900E-01  0.00000E+00
  -0.20900E-01  0.00000E+00];
   calib(4:14)=poles(:,1)+i*poles(:,2);

elseif  inst_type=='i'
  % intermediate-period DWSSN instrument response
  calib(1:3) = [0.35200E+03 1.0 8]; calib(33)=5;
  poles=[
  -0.36900E+00  0.19900E+00
  -0.36900E+00 -0.19900E+00
  -0.24100E+01  0.58000E+01
  -0.24100E+01 -0.58000E+01
  -0.58100E+01  0.24000E+01
  -0.58100E+01 -0.24000E+01
  -0.20900E-01  0.00000E+00
  -0.20900E-01  0.00000E+00];
  calib(4:11)=poles(:,1)+i*poles(:,2);

elseif  inst_type=='r'
  % REFTEK RESPONSE for vertical component of station LON
  % this instrument is flat to velocity, and the gain is 
  % 2.87e+08, 3.20e+08 and 3.42e+08 for the Z,N, and E channels (counts/(M/S))
  % response has been converted to displacement (M) by adding a zero and 
  % correcting both the gain and normalization by 2*pi*f0
  % change calib(2)=1.60e+08*2*pi*f0 or 1.71e+08*2*pi*f0 for the N or E orientations
  % response is displacement (m).
  f0=.05;        % reference frequency
  calib(1:3) = [1.64355e+19/2/pi/f0 2.87e+08*2*pi*f0 8]; calib(33)=3;
  w0=2*pi/30;    %  seismometer period=30s; 
  beta=0.707;    %  seismometer damping     
  p=[];
  p(1)=-beta*w0 + i*w0*sqrt(1-beta*beta); p(2)=conj(p(1));
  p(3)= -406.55 + i*1517.27;              p(4)=conj(p(3));
  p(5)=-1110.72 + i*1110.72;              p(6)=conj(p(5));
  p(7)=-1517.22 + i*406.55 ;              p(8)=conj(p(7));
  calib(4:11)=p';

elseif  inst_type=='u'
  % USNSN RESPONSE for vertical component of station NEW
  % response is displacement (m).
  % only information from USGS is gain * normalization = 7.523E+10
  % I choose an arbitrary reference frequency of 0.045 Hz
  % to evaluate the gain and the normalization
  f0=.05;        % reference frequency
  calib(1:3)=[4.2219e+11 0.17819 6];calib(33)=3;
  p=[-.031420 0.00
     -.197900 0.00
     -201.100 0.00
     -697.400 0.00
     -754.000 0.00
     -1056.00 0.00];
  calib(4:9)=p(:,1) + i*p(:,2);

elseif  inst_type=='p'
  % PASCALL Guralp RESPONSE for vertical component of station NEW

  % The sensitivity for the 24 bit data is such that 2**23 is 16 volts or
  % each count at unity gain represents 1.9074e-6 volts.
  % cmg3t_vel 1.2 1/6/93
  % cmg3t    3.33300E-02 hz seismometer
  % Normalized  response relative to velocity
  % 1                   type
  % 2                   num of zeroes
  % 2                   num of poles
  % 0.0                 input sample interval
  % 1                   decim factor
  % 1.0                 normalization factor
  % 1.0                 gain
  % sensitivity  2000 v/m/sec
  % theoretical   1 anti-alias   paz    pz6seismo
  % 1.0
  % 2             Poles
  % -.1481E+00    0.1481E+00    0.0000E+00    0.0000E+00
  % -.1481E+00    -.1481E+00    0.0000E+00    0.0000E+00
  % 2             Zeros
  % 0.0000E+00    0.0000E+00    0.0000E+00    0.0000E+00
  % 0.0000E+00    0.0000E+00    0.0000E+00    0.0000E+00
  % gain is 2000/1.9074e-6 counts/m/s
  % normalization = 1 for f0=1, but is 1.09432 for f0=.05 Hz
  
  f0=.05;        % reference frequency
  calib(1:3)= [1.09432/2/pi/f0 ; 2000/1.9074e-6 *2*pi*f0; 2];calib(33)=3;
  %calib(1:3)=[1 1 2];calib(33)=2;
  calib(4) = -.1481E+00  +i*  0.1481E+00; calib(5) = conj(calib(4));

end
