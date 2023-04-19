% plot the radiation pattern amplitudes along the right 10% of the window
% to use this, first cut out data with respect to a phase, then run ray_syn, 
% then plot 1 then run this
XLIMS=get(gca,'Xlim');
YF=[1:length(FF)]';
YF=yval';
XMAX=XLIMS(2)*ones(size(YF));
XMIN=XMAX - diff(XLIMS)*abs(FF')/10;
hold on; h_rad=plot([XMIN,XMAX]',[YF,YF]','-','linewidth',5); hold off
