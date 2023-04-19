% Create a single depth grid to be used for beam backprojection
clear

% Velocity model
model = [ 
  3.66      0.0
  3.96      0.4
  5.03      0.9
  5.79      1.5
  5.95      2.5
  6.2       8.0
    ];

fileloc = 'sta_loc_Kansas.txt'; % coordinates of stations

station_data = readtable(fileloc);
sta_lat = mean(table2array(station_data(:,3))); % center of the array lat
sta_lon = mean(table2array(station_data(:,2))); % center of the array lon


dist_inc = 0.05; % grid increments in x,y,z in kms
depth_inc = 0.01;

%creating initial parameters for the grid
grd.lon = -97.7:km2deg(dist_inc):-97.2; % degrees
grd.lat = 37.1:km2deg(dist_inc):37.6; % degrees
grd.depth = 1.09; % kms

[TTgrid,LAT,LON,DEP] = makeTTgrid(sta_lat, sta_lon, grd, model); % passing values to create TTgrid

%%

[nrows,ncols,nlayers] = size(DEP);
% initializing empty arrays for calculation
gr_slnx = zeros(nrows,ncols,nlayers);
gr_slny = zeros(nrows,ncols,nlayers);
gr_km = zeros(nrows,ncols,nlayers);

%assigning the required values to arrays to be used in beam_bp code
gr_lat = LAT;
gr_lon = LON;
gr_dep = DEP;

gr_az = TTgrid.XI;
gr_sln = TTgrid.S;
%% Calculation of parameters for slowness 3D cube
for i=1:nrows
    progressbar(i/nrows)
    for j=1:ncols
        for k=1:nlayers
            [sln_x, sln_y] = sln2xy(TTgrid.S(i,j,k),TTgrid.XI(i,j));% azimuth values are in 2D array
            gr_slnx(i,j,k) = sln_x; gr_slny(i,j,k) = sln_y;
            % calculating 3D cartesian disatnce from center of the array to
            % every grid point,(this was however unused later), make sure
            % start and end coordinates of grid are same
            gr_km(i,j,k) =  ((deg2km(sta_lat - LAT(i,j,k)))^2 + (deg2km(sta_lon - LON(i,j,k)))^2 + (DEP(i,j,k))^2)^0.5;
        end
    end
end


save Kansas_gr_single_depth_2500feet.mat gr_km gr_az gr_dep gr_lat gr_lon gr_sln gr_slnx gr_slny