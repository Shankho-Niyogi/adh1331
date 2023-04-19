function trampl=synthwa(ahdatafile);
%   synthwa       deconvolve REFTEK, convolve Wood Anderson instrument response
% usage: trampl=synthwa(ahdatafile);
% "synthwa.m" is getting the instrument response of REFTEK ('n'-NS and 'e'-EW 'z'-vert)
% and deconvolves it from the raw REFTEK data file in counts. Thus we
% are given the true ground displacement in meters.
% Later it convolves it with the Wood-Anderson('w') instrument response.
% This way we obtain two synthetic WA seismograms for NS and EW.
% Finally the Maximum zero to peak (0-P) amplitude n millimeters is given.
% see "bb_magn.m", "decon_inst_richmag.m", "ah2ml".
% written by Gia Khazaradze			June, 1994 

global PLOS SAVD;

tr_ampl=zeros(1);

[Station,Loc,CalibX,Comment,Record,Extras,Data] = ah2ml(ahdatafile);

% put an error trapping, in case if there is no instr. response data
% inside the "ahdatafile" header.

% following is the instrument response of the standard Wood-Anderson
% tprsion seismometer. NOTE: geometric amplification is: 2800; damping=0.8; natural period=0.8;

calibWA=zeros(62,1);
calibWA(1:3) = [2.8E+03 1 2]; 
calibWA(33)=2;
  poles=[
  -0.62832E+01  0.47124E+01
  -0.62832E+01 -0.47124E+01];
calibWA(4:5) = poles(:,1)+i*poles(:,2);

nbb=Record(3,1);			% number of data points
sintrbb=Record(4,1);			% sample interval in seconds 
tbb=0+[0:nbb-1]*sintrbb;             	% make time vectors
dbb=demean(Data(1:nbb,1));             	% remove mean
dbb=taperd(dbb,.05);			% taper data

% deconvolve broad band response from the data and convolve it with
% the Wood-Anderson seismometer response

dbbDS=decon_inst_richmag(dbb,CalibX,calibWA,sintrbb,1,.00001);
dbbDS=dbbDS*1000;                   	% convert into millimeters 

% in "bb_magn.m" PLOS and SAVD were declared as global variables
% they determine whether following two "if" statements will be executed

if PLOS=='y'|PLOS=='Y',
figure('Position',[50 700 900 400],'Name','Synthetic Wood-Anderson');
     plot(tbb,dbbDS);
     title (['"Synthetic" Wood-Anderson Seismogram  ',ahdatafile]);
     xlabel('Time (s)');
     ylabel('Displacement (millimeters)');
     grid;
%     disp(['Press any key to proceed']);
%    pause;
eval(['print ',ahdatafile,'.ps']);
end

%if SAVD=='y'|SAVD=='Y',
%  eval(['save ',ahdatafile,'.wa dbbDS']);  		% save data column (binary)
%  eval(['save ',ahdatafile,'.time.wa tbb']);       	% Save time column
%end

trampl = max(abs(dbbDS));				% max 0-P in millimeters
