% Plots a map of stations in data 0

lonmin = min(Loc(2,:));
lonmax = max(Loc(2,:));
axlonmin = lonmin-(lonmax-lonmin)*0.1;
if axlonmin<-180; axlonmin=-180; end
axlonmax = lonmax+(lonmax-lonmin)*0.1;
if axlonmax>180; axlonmax=180; end

latmin = min(Loc(1,:));
latmax = max(Loc(1,:));
axlatmin = latmin-(latmax-latmin)*0.1;
if axlatmin<-90; axlatmin=-90; end
axlatmax = latmax+(latmax-latmin)*0.1;
if axlatmax>90; axlatmax=90; end

figure; clf; hold on
plot (Loc(2,:),Loc(1,:),'^k','Markerfacecolor','b','Markersize',7)
for i = 1:length(Loc(2,:)),
 text(Loc(2,i)+(lonmax-lonmin)*0.01,Loc(1,i)+(latmax-latmin)*0.01,[char(Station(1:5,i))]','FontSize',7)
end
xlabel ('longitude (deg)')
ylabel ('latitude (deg)')

mapp_ares(-1)


axis([axlonmin axlonmax axlatmin axlatmax])
