function lonLatZinterp = gcTopo( lon, lat, numPts, elevFlagOptional )
%   gcTopo        interpolate topography along great circle
%    usage: lonLatZinterp = gcTopo( lon, lat, numPts, elevFlagOptional )
%
%    Given the coordinates of two points on the globe specified by the
%    column vectors LON and LAT in geographic degrees, gcTopo returns
%    a NUMPTS x 4 matrix LATLONZINTERP of evenly spaced points along the
%    great circle path between the two points with the elevation at each
%    of the NUMPTS points. The elevation data is interpolated from the
%    reduced form of the etopo5 global relief data set which gives average
%    and extreme elevations in .5 x .5 degree bins. Setting the optional
%    argument ELEVFLAGOPTIONAL to 0 uses the average elevation data (default),
%    setting ELEVFLAGOPTIONAL to 1 uses the extreme elevation data.
%    More information about this data set is given in the file
%    /data7/winch/etopo/README.
%
%    Input:
%           lon = [lon(1); lon(2)] = column vector of input longitudes.
%           lat = [lat(1); lat(2)] = column vector of input latitudes.
%           numPts = number of points on the great circle path between
%                    (lon(1), lat(1)) and (lon(2), lat(2)) at which the
%                    interpolated elevation information is desired.
%           elevFlagOptional = 1: use extreme elevation data.
%                            = 0: use average elevation data (default).
%
%    Output:
%           lonLatZinterp = [ lon(i), lat(i), delta(i), zInterp(i)
%                           where delta(i) is the distance in degrees along
%                           the great circle of (lon(i),lat(i)) from the
%                           given (lon(1),lat(1)) and zInterp(i) is the
%                           elevation in meters interpolated at the 
%                           corresponding longitudes and latitudes. The
%                           longitudes and latitudes are in geographic degrees.
%
%    Dependencies:  coortr.m and delaz.m 

%
%        Make longitudes > 0 and read in the appropriate subset of the data:
%
lon = lon + 360*(lon<0);
latBottom = min(lat);
latTop = max(lat);
lonLeft = min(lon);
lonRight = max(lon);
locationString = [num2str(latBottom,5),' ', num2str(lonLeft,5),' ',num2str(latTop,5),' ',num2str(lonRight,5)];
eval(['!/data7/winch/etopo/topoRead ', locationString, ' > topo.dat']);
load topo.dat;
%
%        Set the elevation option:
%
if nargin < 4
  elevFlagOptional = 0;
end
if elevFlagOptional == 0    % use average elevation data
  zTopo = topo(:,4);
elseif elevFlagOptional == 1                % use extreme elevation data
  zTopo = topo(:,3);
else
  disp(['The 4th argument should be 0 if the average elevation is desired'])
  disp(['or 1 if the extreme elevation is desired.'])
end
%
%        Grid the data by longitude (x axis) and latitude (y axis):
%
tmin = min(topo); tmax = max(topo);
y = [tmin(1):0.5:tmax(1)]';
x = [tmin(2):0.5:tmax(2)];
zmat = reshape(zTopo, length(x), length(y));
zmat = zmat';
%
% Convert input points to geocentric radians:
%
[latgc, longc] = coortr(lat,lon,0);
[delta, az, backAz] = delaz(latgc(1),longc(1),latgc(2),longc(2), 1);
%
% get intervening points on great circle:
%
r2d = 180/pi;
delVec = [0:delta/numPts:delta]';
[latPtsGc,lonPtsGc] = rot(latgc(1)*r2d,longc(1)*r2d,az,delVec);
%
% Convert to geographic degrees:
%
[latPts,lonPts] = coortr( latPtsGc/r2d,lonPtsGc/r2d, 1 );
lonPts = lonPts + 360 * (lonPts < 0);
%
%  Interpolate elevations:
%
zInterp = interp2(x,y,zmat,lonPts, latPts);
lonLatZinterp = [lonPts, latPts, delVec, zInterp];
