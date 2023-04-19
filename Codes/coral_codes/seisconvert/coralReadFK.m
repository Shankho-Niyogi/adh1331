% Matlab script to read FK synthetics and plot a record section
% The FK program does not pass the source or receiver locations through the headers
% so this code assumes the source is at latitude=0, longitude=0
% Make sure the eqDepth specified here matches that entered into 'fk' and that the
% azimuth entered here matches that entered in 'syn'
% The distance is passed through the SAC headers, so the station latitude and longitude 
% are calculated here once the azimuth is known.

clear;

Directory = '.';     % directory containing the synthetics
eqLat=0; eqLon=0;           % can always arbitrarily set source lat and lon to 0
eqDepth=8;                  % source depth (see fk)
azim=90;                    % source-receiver azimuth (see syn)

for channel = 1:3   % loop over three channel orientations
  % file is a list of files that match the wild card designations
  % verRed is the reducing velocity for the record sections
  % tlim are the time limits for the plots
  % titl are the plot titles
  if channel==1; 
    files=dir([ Directory '/*syn.t']); velRed=3.5; tlim=[-3 12];  titl='transverse displacement'; plot_file='syn_t.jpg';
  elseif channel==2; 
    files=dir([ Directory '/*syn.r']); velRed=6.2; tlim=[-3 25];  titl='radial displacement';     plot_file='syn_r.jpg';
  elseif channel==3; 
    files=dir([ Directory '/*syn.z']); velRed=6.2; tlim=[-3 25];  titl='vertical displacement';   plot_file='syn_z.jpg';
  end

	for k=1:length(files)   % loop over the files, reading in the data and setting locations parameters.
    filename = [ Directory '/' files(k).name ];
    [D0,hdr]=coralReadSAC(filename);
    D0.eqLat   = eqLat;
    D0.eqLon   = eqLon;
    D0.eqDepth = eqDepth;
    eqDist = hdr(51);    % earthquake distance comes from the sac header (km)
    [staLat,staLon] = rot(eqLat,eqLon,azim,eqDist/111.1);  % calculate station coordinates along the great circle at the specified azimuth and distance
    D0.staLat = staLat;
    D0.staLon = staLon;
    D(k,1)=D0;
	end
	
	D=coralIntegrate(D);  % integrate to get displacement
	opt.scal=40;          % scale each seismogram by a factor of opt.scal
	eqDist = delaz([D.eqLat],[D.eqLon],[D.staLat],[D.staLon],0)*111.1;     % earthquake to station distance (km)
	opt.y_offset = eqDist; % offset seismograms by their distance (km) 
	% offset time axis of each seismogram by first correcting for the time difference between the event origin time 
	% and the record start time and then applying a reducing velocity
	opt.tshift = timediff([D.recStartTime],[D.eqOriginTime]) - opt.y_offset/velRed;  
	if channel<3; 
    figure(channel);      % open a new figure window
	  clf;
  end
	h=coralPlot(D,opt);     % plot the seismograms as a record section
	xlim(tlim);           % set the limits of the plot along the x axis
	ylim([0 150]);        % set the limits of the plot along the y axis
	title(titl);
	ylabel('distance (km)')
	xlabel(sprintf('T - X/%.1f (s)',velRed))
	orient tall
  %print('-djpeg',plot_file);  % make a jpg file for each record section (replace -djpeg with -dpss to make a postscript file for printing)
end
	%opt.opt='Deco from n to n gaus 8 0';D1=coralDeconInst(D(1),opt);clf;coralPlot(D1);coralPlot(D(1));
