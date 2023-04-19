%Beam backprojection code

clear
close all

datadir = 'D:/Kansas_clipped_data/for_location/20160124_92400_92730_ZA/';
st_time = [2016 1 24 9 24 0]';
%st_time = [2013 5 3 10 15 0]';
durt = 210; %in secs

fnames = dir([datadir '*.SAC']);
%%
for ist = 1: length(fnames)
    
    data(ist) = coralReadSAC([datadir fnames(ist).name]);
    
end

optcut.cutType = 'absTime';
optcut.absStartTime = st_time;
optcut.absEndTime = st_time+[0 0 0 0 0 durt]';

data = coralCut(data, optcut);
data = coralDemean(data);
data = coralDetrend(data);
data = coralTaper(data);

data = coralFilter(data, [1 5], 'bandpass');

figure (1)
clf
coralPlot(data)

% keyboard
% 
% x = ginput(2);

x = ones(2,1);
x(1,1) = 0;
x(2,1) = durt;

optcut.absStartTime = st_time + [0 0 0 0 0 x(1,1)]';
optcut.absEndTime = st_time + [0 0 0 0 0 x(2,1)]';
datac = coralCut(data, optcut);

datac = coralDemean(datac);
datac = coralDetrend(datac);
datac = coralTaper(datac, -0.5);

%% beamform
dt=datac(1).recSampInt;  % sampling interval
Fmax=1/dt; % maximum frequency
Nfft = datac(1).recNumData; % number of sample in each chopped seismogram (i.e. number in fft)
frq = Fmax/2*linspace(0,1,Nfft/2+1); % central frequencies

%vhelp = fft(sinsig); % fft of the data

acoor = [[data.staLon]' [data.staLat]'];
acent = mean(acoor); % Center of the array


distN = (acoor(:,2) - acent(2))*111.0; % NS offset in km
distE = (acoor(:,1) - acent(1))*111.0 * cos(acent(2)*pi/180); % EW offset in km

% Slowness
% NsloV = [-0.5:0.01:0.5];
NsloV = [-1.0:0.05:1.0];
EsloV = NsloV;

beam = NaN*ones(length(NsloV));
h = waitbar(0,'Please wait...');

for ind1 = 1: length(NsloV)

    waitbar(ind1/length(NsloV))
    
    for ind2 = 1: length(EsloV)
        
        stdel = datac(1).data*0;
        for ind3 = 1: size(acoor,1)
            
            delay = distN(ind3)*NsloV(ind1) + distE(ind3)*EsloV(ind2);  % compute lag from slownesses
            
            rep = exp(1i*2*pi*frq*-delay);
            vhelp = fft(datac(ind3).data);
            dshft = rep.*shiftdim(vhelp(1:length(frq)),1); % phase-shift(shifting in time)
            s_sh = double(2*real(ifft(dshft, datac(1).recNumData))); % taking it back to the time domain with correct amplitude
            
            stdel = stdel + s_sh';
            clear delay rep dshft s_sh
            
        end
        stpower = sum((stdel/ind3).^2);
        beam(ind1,ind2) = stpower;
        clear stpower stdel vhelp
    end
end

close(h)

[mxrw, mxcl] = find(beam == max(max(beam)));
mx_slx = EsloV(mxcl);
mx_sly = NsloV(mxrw);

figure(2)
clf
imagesc(EsloV, NsloV, beam)
set(gca,'YDir','normal')
hold on
plot(0,0, 'w+')
xlabel('EW slowness (s/km)', 'fontsize', 16)
ylabel('NS slowness (s/km)', 'fontsize', 16)
title ('Beam', 'fontsize', 18)
colorbar
%plot(s_x, s_y, 'p', 'markersize', 20, 'markerfacecolor', 'g', 'markeredgecolor', 'k')
plot(mx_slx, mx_sly, '*', 'markersize', 20, 'markerfacecolor', 'w', 'markeredgecolor', 'w')

% %% locating
% 
% resmap = sqrt(((gr_slnx-mx_slx).^2)+((gr_slny-mx_sly).^2));
% [iloc_rw, iloc_cl] = find(resmap == min(min(resmap)));
% loc_kmd = [gr_km(1,iloc_cl) gr_dep(iloc_rw,1)];
% 
% figure(5)
% clf
% %imagesc(gr_sln)
% %imagesc(gr_az)
% %imagesc(gr_km)
% %imagesc(gr_dep)
% %imagesc(gr_lat)
% %imagesc(gr_lon)
% imagesc(resmap)
% hold on
% plot(loc_kmd(1), loc_kmd(2), 'p', 'markersize', 20, 'markerfacecolor', 'g', 'markeredgecolor', 'k')
% colorbar