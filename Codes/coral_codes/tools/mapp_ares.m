function mapp_ares(args,lon,lat,data,quality,qual_plt,scale,titl)
% USAGE: mapp(args,lon,lat,data,quality,qual_plt,scale,titl)
% 
% Make a world map and plot data with symbol size proportional to absolute
% value of data, symbol is red + for positive times, blue o for negative times.
% Plot line segments instead of symbols if lat, lon are arrays instead of 
% column vectors.
%
%
% the first argument (args) may be an integer that is interpreted as key=args
% or it may be a structure that optionally contains several arguments
% such as args.key, args.file, args, map_limits, etc.
%
% abs(key) = 1 plot only map, do not need any other input parameters
%            2 plot only data
%            3 plot map and data
% key      > 0 make new plot
%          < 0 add to existing plot
% lon        column vector of longitudes (or arrays)
% lat        column vector of latitudes  (or arrays)
% data       column vector of data values
% quality    column vector of quality factors
% qual_plt   vector of qualities to be plotted (ie [1 2 3])
% scale      symbol size is proportional to absolute value of data scaled such
%            that 'scale' degrees of latitude = one data unit.
% titl       plot title (character string)
% lat, lon, data, quality must all be of the same size.
% args       structure of optional arguments:
% args.key   key as described above
% args.file  name of mat file to read and plot 
% args.mat_limits 4x1 vector of lon and lat limits for map

% Code to fix problem of lines going across the page.  The problem
% was 5 points that should be 180 and were -180: KCC 5/30/00
% load world_ares
% for imap=2:length(points); ind=[points(imap-1)+1:points(imap)]; if length(ind)>0; 
% if max(xmap(ind))>0 & min(xmap(ind))<0; xmap(ind)=xmap(ind)+380*(xmap(ind)==-180); end;end;end
% save world_ares points xmap ymap


%default values
key    = -1;
file   = 'world_ares';
limits = [-180 180 -90 90];

if strcmp(class(args),'struct');   % key is a structure
  if sum(strcmp(fieldnames(args),'key'))
    key=args.key;
  end
  if sum(strcmp(fieldnames(args),'file'))
    file=args.file
  end
  if sum(strcmp(fieldnames(args),'map_limits'))
    limits=args.map_limits;
  elseif strncmp(file,'puget',5)
    limits=[-Inf Inf -Inf Inf];
  end
else
  key=args;
end

if key>0,
   axis(limits); % set map limits
else
   hold on
end

if abs(key)==1 | abs(key)==3,          % draw coastlines
  eval ( ['load ' file] );
  for imap=1:length(points)
    if imap==2, hold on, end
    if imap==1
       ind=[1:points(1)];
    else
      ind=[points(imap-1)+1:points(imap)];
    end
    plot(xmap(ind),ymap(ind),'-k'); 
  end
end

if abs(key)==2 | abs(key)==3,
  % determine which data match quality requirements
  ind=[];
  for i=1:length(qual_plt);
    ind=[ind find(quality==qual_plt(i))'];
  end
  ind=sort(ind);
  if length(ind)>0,
    [N,M]=size(lon);
    lon=lon+360*(lon<zeros(N,M));%change lon range from -180->180 to 0->360
    % set symbol size proportional to data, scaled by scale, and with an aspect
    % ratio of 1:1 when plotted in landscape mode on laserwriter
    if M==1,            % plot symbols
      siz1=abs(data);
      siz=[siz1*1.4762 siz1]*scale;
      symbol=1+(data>zeros(length(data),1)); % set symbol=1 if data<0, else symbol=2
      pltsym(lon(ind),lat(ind),siz(ind,:),symbol(ind));  % plot data

      % make a key and draw it, add labels
      % xkey=[20;20];ykey=[-75;-85];
      % sizkey=[1.4762 1;1.4762 1]*scale;symbolkey=[1;2];
      % hold on
      % pltsym(xkey,ykey,sizkey,symbolkey);
    else
      plot(lon(ind,:)',lat(ind,:)','-g');
    end
    %text(29,-76-scale/2,'-1 s'); text(27,-86-scale/2,'+1 s');
    xlabel ('longitude'),; ylabel('latitude'); 
    title (titl); 
  end
end

axis(limits);
set(gca,'box','on')
if sum(limits == [0 360 -90 90]) == 4; 
  set(gca,'xtick',[0:30:360],'ytick',[-90:15:90])
  ylabel('latitude(deg)');
  xlabel('longitude(deg)')
end

hold off

