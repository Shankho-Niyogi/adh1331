% Plots a map of event, stations and raypaths in data 0

lonmin = min([Loc(2,:) Loc(5,1)]);
lonmax = max([Loc(2,:) Loc(5,1)]);
axlonmin = lonmin-(lonmax-lonmin)*0.1;
if axlonmin<-180; axlonmin=-180; end
axlonmax = lonmax+(lonmax-lonmin)*0.1;
if axlonmax>180; axlonmax=180; end

latmin = min([Loc(1,:) Loc(4,1)]);
latmax = max([Loc(1,:) Loc(4,1)]);
axlatmin = latmin-(latmax-latmin)*0.1;
if axlatmin<-90; axlatmin=-90; end
axlatmax = latmax+(latmax-latmin)*0.1;
if axlatmax>90; axlatmax=90; end

figure; clf; hold on
plot (Loc(2,:),Loc(1,:),'^k','Markerfacecolor','b','Markersize',7)
plot (Loc(5,1),Loc(4,1),'pk','Markerfacecolor','r','Markersize',12)
text (Loc(5,1)+(lonmax-lonmin)*0.01,Loc(4,1)+(latmax-latmin)*0.01,'Event','FontSize',7)
for i = 1:length(Loc(2,:)),
 text(Loc(2,i)+(lonmax-lonmin)*0.01,Loc(1,i)+(latmax-latmin)*0.01,[char(Station(1:5,i))]','FontSize',7)
 delta_int = Delta(i)/20;
 deltas = [0:delta_int:Delta(i)]';
 [lats,lons] = great_circle(Loc(4,i),Loc(5,i),Loc(1,i),Loc(2,i),deltas,0);
 ii = find(lons>180); lons(ii) = lons(ii)-360;
 plot (lons,lats,'k')
 plot (lons(11),lats(11),'or');
 clear lats lons ii deltas delta_int
end
xlabel ('longitude (deg)')
ylabel ('latitude (deg)')

mapp_ares(-1)


axis([axlonmin axlonmax axlatmin axlatmax])
clear axl* latmax latmin lonmax lonmin i