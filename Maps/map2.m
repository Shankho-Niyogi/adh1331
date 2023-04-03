clear
close all
clc

% This has been tested to be running okay on MATLAB 9.9.0.1538559 (R2020b) Update 3

% The source of the earthquakes is Supplementary data S3 of Peterie, Shelby L., et al. "Earthquakes in Kansas induced by extremely 
% far‐field pressure diffusion." Geophysical Research Letters 45.3 (2018): 1395-1401.

% The faults have been digitized from: Schwab, Drew R., Tandis S. Bidgoli, and Michael H. Taylor. 
% "Characterizing the potential for injection‐induced fault reactivation through subsurface structural mapping and 
% stress field analysis, Wellington Field, Sumner County, Kansas." Journal of Geophysical Research: Solid Earth 122.12 (2017): 10-132.


% importing station coordinates
opts = detectImportOptions('stations_coordinate.xlsx','NumHeaderLines',1);
sc = readtable('stations_coordinate.xlsx',opts);

slon = table2array(sc(:,1));
slat = table2array(sc(:,2));

% Importing Peterie et al 2018 earthquake dataset here
opts1 = detectImportOptions('grl56904-sup-0003-2017gl076334-ds02.csv','NumHeaderLines',1);
data = readtable('grl56904-sup-0003-2017gl076334-ds02.csv',opts1);

dt_peterie = datetime(table2array(data(:,1)));
lat_peterie = table2array(data(:,2));
lon_peterie = table2array(data(:,3));
depth_peterie = table2array(data(:,6));
mag_peterie = table2array(data(:,4));

bubsizes = [min(mag_peterie) quantile(mag_peterie,[0.25 0.5 0.75]) max(mag_peterie)]*10;

%% importing event data from catalog
event_data = readtable('catalog_Kansas_events.dat');
F1 = shaperead('./wellington_faults/Fault1.shp');
f1_lon = [F1.X]';
f1_lat = [F1.Y]';
F2 = shaperead('./wellington_faults/Fault2.shp');
f2_lon = [F2.X]';
f2_lat = [F2.Y]';
F3 = shaperead('./wellington_faults/Fault3.shp');
f3_lon = [F3.X]';
f3_lat = [F3.Y]';
F4 = shaperead('./wellington_faults/Fault4.shp');
f4_lon = [F4.X]';
f4_lat = [F4.Y]';
F5 = shaperead('./wellington_faults/Fault5.shp');
f5_lon = [F5.X]';
f5_lat = [F5.Y]';
F6 = shaperead('./wellington_faults/Fault6.shp');
f6_lon = [F6.X]';
f6_lat = [F6.Y]';

lat_event = table2array(event_data(:,2));
lon_event = table2array(event_data(:,3));

injw_lon = -97.441845;%well 2-32
injw_lat = 37.310455;%well 2-32

one_32_lon = -97.442737;
one_32_lat =  37.315464;

one_28_lon = -97.433702;
one_28_lat =  37.319505;

radi = 0.15;

%% plotting datasets with date

figure()
geoscatter(lat_event,lon_event,100,'filled','MarkerEdgeColor',[0 0 0])
hold on
geoscatter(lat_peterie,lon_peterie,mag_peterie*10,datenum(dt_peterie),'filled')

legentry=cell(size(bubsizes));
for ind = 1:numel(bubsizes)
   bubleg(ind) = geoplot(injw_lat,injw_lon,'ro','markersize',sqrt(bubsizes(ind)),'MarkerFaceColor','red');
   set(bubleg(ind),'visible','off')
   legentry{ind} = num2str(bubsizes(ind)/10);
end


c = colorbar('southoutside');
ticks = linspace(dt_peterie(1),dt_peterie(end),6);
set(c,'YTick',datenum(ticks))
set(c,'YTicklabel',datestr(ticks,'mm-dd-yyyy'))
c.Label.String = 'Time of occurrence (month-year)';

geoscatter(slat,slon,50,'k','v','filled')
geoscatter(injw_lat,injw_lon,100,'b','s','filled')
geoscatter(one_32_lat,one_32_lon,100,'g','s','filled')
geoscatter(one_28_lat,one_28_lon,100,'r','s','filled')
geolimits([injw_lat-radi injw_lat+radi],[injw_lon-radi injw_lon+radi])

legentry = ['Event locations' 'Earthquake locations' legentry 'Station locations' 'Injection well' 'Well 1-32' 'Well 1-28'];
legend(legentry,'Location','northeast')
title('Aseismic events plotted with Peterie et al earthquakes')
hold off
geobasemap landcover
