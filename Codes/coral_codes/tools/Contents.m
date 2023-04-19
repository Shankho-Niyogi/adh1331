% Seismology tools
%
% Instrument response
%   bb_magn       calculate Richter magnitude
%   conv_response convert units of instrument response
%   corr_inst     remove instrument response 
%   decon_inst    deconvolve instrument response
%   decon_inst_richmag deconvolve old instrument response and convolve a new one
%   get_inst_resp get standard instrument responses
%   inst_response compute impulse response and transfer function
%   response      changed name to inst_response to avoid conflict with matlab routine
%   richmag       Richter magnitude
%   synthwa       deconvolve REFTEK, convolve Wood Anderson instrument response
%
% Spherical geometry, and coordinate transforms
%   coortr        geocentric/geographic coordinate transformation
%   delaz         compute earthquake/station distance and azimuth
%   delts         read table of CMB, inner-core and turning-point PKP distances
%   erot          make rotation matrix
%   euler_trans   Euler Transform rotation matrix
%   interaction_points  compute where rays turn and intersect CMB and inner-core
%   lld2xyz       convert latitude, longitude, depth to cartesian coordinates
%   rot           calculate latitude, longitude from reference location, azimuth, distance
%   great_circle  compute latitudes and longitudes along a great circle
%   scrot         rotation of spherical coordinates
%   rayangle      compute mid point lat and lon and ray angle with respect to spin axis 
%   sph2xyz       convert spherical polar coordinates to cartesian coordinates
%   xyz2lld       convert cartesian coordinates to latitude, longitude, and depth
%   xyz2sph       convert cartesian coordinates to spherical polar coordinates
%
% Time series
%   deglitch      remove a glitch
%   demean        remove mean from columns of matrix
%   ft            Fourier Transform with time shift and sample interval scaling
%   futterman     Futterman Filter Attenuation Operator
%   hilbert_trans Hilbert Transformation
%   ift           Inverse Fourier Transform, time shifts, sample interval scaling
%   make_freq     make frequency vector for Fourier Transforms
%   taper         make hanning taper
%   taperd        apply hanning taper to a vector
%   xcor          normalized cross correlograms
%
% Focal mechanisms
%   harvard2xyz   convert moment tensor from Spherical to Cartesian coordinates
%   focal_sphere  plot point data on a focal sphere
%   radpat        plot moment tensor nodal lines
%   radpat1       plot moment tensor nodal lines
%   radpattern    calculate moment tensor radiation pattern
%   radplt        plot focal mechanism nodal lines
%   moment_mag    used for Richter magnitude? 
%
% Read external files
%   getcmt        read Harvard Centroid Moment Tensor Catalog and find earthquake
%   getcmt1       read Harvard Centroid Moment Tensor Catalog and find earthquake
%   read_cmt      read Harvard CMT Catalog in Harvard 4-line ascii format
%   read_hdf      read earthquake catalog in HDF format
%   read_hdf_old  read earthquake catalog in HDF format
%
% Time
%   time_reformat reformat time array
%   timeadd       add absolute date/times
%   timediff      subtract absolute date/times
%   ymd           convert date format 
%
% General purpose
%   cum_trapz     cumulative integration using the trapezoid rule
%   cut_string    cut a character string into a matrix
%   find_max      return indices of all local maxima of a vector
%   findmax       interpolate to find maximum value
%   ginput_num    get number typed into graphics window
%   interpol      linear interpolation
%   left_justify  left justify strings in a character string matrix
%   plegendre     associated legendre function
%   pltsym        plot symbols
%   remove_2blanks  remove pairs of blanks from string
%   strcmp2       compare two character string arrays
%   v2m           copy a vector n times into a matrix
%   vec2mat       copy a vector n times into a matrix
%   arrow         draw a line with an arrowhead
%
% Other
%   align_seis    align coral seismograms by cross correlation or trace extrema
%   findsta       find station name from list
%   gcTopo        interpolate topography along great circle
%   iasp91        iasp91 radial earth model
%   mod_eval      evaluate a radial earth model
%   mod_evalg     evaluate a radial earth model and its gradients
%   pick_event    pick event from catalog given seismogram start/stop times
%   plot_amp      plot seismic trace data in absolute values
%   pptime        calculate very approximate pP-P times
%   prem          PREM radial earth model
%   prem2         PREM2 radial earth model
%   rot_seis      rotate seismic data
%   sort_ah       sort data in matlab/ah format
