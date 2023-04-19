function   [data1,header1,label1,obs1] = shift_seis(data1,header1,label1,obs1,Pick1,I);
%  shift_seis    shift seismograms in data1 according to travel time picks
% USAGE:   [data1,header1,label1,obs1] = shift_seis(data1,header1,label1,obs1,Pick1,I);
%
% Input:
% Pick1       structure of column vectors corresponding to data in data1
% either Pick1.TTime or Pick1.TTimeResidual is the only required part of Pick1
% If Pick1.TTime is given, Pick1.TTimeResidual is calculate from it
% Pick1.TTime;         travel-time picks (s) relative to origin time
% Pick1.TTimeResidual  travel-time residuals (s) with respect to predicted time in header1(9,:);
% Pick1.TTimeQual;     pick qualities (user defined)
% Pick1.AmpDefl        peak-to-peak amplitude divided by 2 (m)
% Pick1.AmpPeriod      dominant period of seismogram for this amplitude
% Pick1.SNR            signal to noise ratio
% I                    index into seismograms in data1 that you wish to save and time shif
% 
%
% Realign the data in data1 with respect Pick1.TTime
if length(I)>0;
  if isfield(Pick1,'TTime'); 
    Pick1.TTimeResidual = Pick1.TTime-header1(9,:); 
  elseif isfield(Pick1,'TTimeResidual');
    Pick1.TTime         = Pick1.TTimeResidual+header1(9,:)';
  end
  obs1(1,I) = Pick1.TTime(I)';                   % travel times (s) of picks with respect to origin time
  Pick1.TTimeResidual=Pick1.TTime-header1(9,:)'; % travel time residuals with respect predicted time in header1
  OLD_Shifts= zeros(size(obs1(2,:)))'; 
  ind       = find(isfinite(obs1(2,:)));         %
  if length(ind)>0; OLD_Shifts(ind) = obs1(2,ind); end
  T_Shifts  = Pick1.TTimeResidual - OLD_Shifts;  % time shift relative to data in data1
  obs1(2,I) = Pick1.TTime(I)'-header1(9,I) ;     % travel time residuals with respect predicted time in header1
  if isfield(Pick1,'TTimeQual')
    obs1(4,I) = Pick1.TTimeQual(I)';             % travel time pick quality
  end
  if isfield(Pick1,'AmpDefl');
    obs1(6,I) = Pick1.AmpDefl(I)';             % peak-to-peak amplitude divided by 2 (m)
    obs1(7,I) = Pick1.AmpPeriod(I)';           % dominant period of seismogram for this amplitude 
    obs1(8,I) = Pick1.SNR(I)';                 % signal to noise ratio
  end
  % remove unpicked data from data1 and shift data in time so picks will line up

  window = [ T_Shifts(I)' ;  header1(2,I) ; I(:)' ];
  [data1,header1,label1,obs1] = apply_window(data1,header1,label1,obs1,window);

end
