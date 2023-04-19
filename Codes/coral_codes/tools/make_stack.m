function [t3,s3,s2,slowness,timephases,slownessphases] = ...
            make_stack(data1,Delta,header1,Loc,Station,Mag,phases,Nroot,slowness1,...
	                       slowness2,step,env,scale,decimate,relative)
% 					Matlab function to make an n-th root slant stack
% function [t3,s3,s2] = make_stack(data1,Delta,header1,Loc,Station,Mag,Nroot,slowness1,slowness2,step,env,scale,decimate)

% env = 0; 				% env=1 --> do envelope
% decimate = 1*header1(6,1); 			% decimate data for display(seconds)
% step=0.025; 				% steperval of slownesses
% slowness1= -.5;slowness2=.5; 		% start and end values of stack
% scale = 2.5;				% a scaling factor for plotting

titl=set_title(Loc(:,1),Station(:,1),Mag(:,1));  %  title  for   plots
w_index=header1(5,:); 			% index to data if they are not in order
delta=Delta(w_index); 		        % source-receiver distance (deg)
meanX = mean (Loc(2,:));      meanY = mean (Loc(1,:));
[mnd, AzimMean, BakazimMean] = delaz(Loc(4,1),Loc(5,1),meanY,meanX,0);
% mnd=mean(delta); 		        % mean offset
sintr1=header1(6,1); 			% sample interval
t=[0:length(data1)-1]'*sintr1; 		% time vector
slowness= slowness1: step: slowness2; 	% range of differential slownesses (s/deg)
relative_distance=delta-mnd; 		% relative distances (mean removed)
l=length(slowness);[m,n]=size(data1); 	% array dimensions
size_data1=max(abs(data1)); 		% rescale all seismograms so they each 
DATA1=data1./vec2mat(size_data1',m)'; 	% have unit maximum amplitude
DATA1=(abs(DATA1)).^(1/Nroot) .* sign(DATA1);% take Nroot-th root and keep sign
[s,t1,dt]=slantstack(DATA1,sintr1,relative_distance,-slowness); % slant-stack data
s=(abs(s).^(Nroot))  .* sign(s); 		% raise stack to Nroot-th power

% s is the stack, s1 is the envelope of the stack, s2 is offset for plot
s1=s;
if env == 1
  for i=1:l
    s1(:,i)=abs(hilbert(s(:,i))); 	% form envelope
  end
end

% decimate data
% decr=decimate/sintr1
decr=decimate; index=1:decr:size(s,1); t3=t1(index);s3=s1(index,:);

% force s2 to clip at maxs - make nice plots
maxs=step/(scale+.1);s2=(abs(s3)>maxs)*maxs.*sign(s3)  +  (abs(s3)<=maxs).*s3;

% s2=abs(s2);

% move data up and down page for plotting
for i=1:l;  s2(:,i) = s2(:,i)*scale + slowness(i);  end

% reset time to peak at zero
[tmp1,tmp2] = min (abs(s2(1,:)));
tryTOgetONLYpwave =min(floor(40/sintr1),size(s3,1));
[tmp3,tmp4] = max (abs(s3(1:floor(tryTOgetONLYpwave),tmp2)));
tmp5=t3(tmp4);
t3=t3-tmp5;					

%  add unclipped signal to top
s4=s3(:,tmp2);
% s4=abs(s4);
mmax=max(abs(s4)); s4 = s4*step/mmax*2 + slowness2 + 3 * step;
s2 = [s2, s4]; 

% Look up arrival times and slowness
 phases = ['P     ';'S660P ';'S1200P';'S920P ';'S800P ';'s520P ';'s410P ';'s300P ';'s210P ';'p520P ';'p410P ';'p300P ';'p210P ';'pP    '];
% phases = ['P       ';phases];
[timephases,slownessphases] = get_ttt(phases, Loc(6,1), mnd);
% %%%
        tS660P = timephases(2);
        pS660P = slownessphases(2);
	tP = timephases(1);
	pP = slownessphases(1);
	[tmp6, tmp7] = min (abs(s2(1,:)- (pS660P - pP)));
		% tmp7 = # of trace at slowness closest to S660P
	[tmp8, tmp9] = min (abs(t3 - (tS660P-tP-2)));
		% tmp9 = # of time 2 sec before theo S660P arrival
	[tmp10, tmp11] = min (abs(t3 - (tS660P-tP+5)));
		% tmp11 = # of time 5 sec after theo S660P arrival
	[tmp12, tmp13] = max (abs(s3((tmp9:tmp11), tmp7)));
		% tmp13 = time of largest amp. in window
	S660Pdelay = [t3(tmp13+tmp9-1) - (tS660P - tP), t3(tmp13+tmp9-1)];

% %%% 
% plot stacks
% h=figure;
whitebg(gcf,'w');
h=gcf;
set(h,'PaperType','a4letter');
hold on;
plot(t3,s2,'-k');grid;xlabel('time(s)');ylabel('slowness(s/deg)')
[a,b]=size(timephases);
if relative ==1;
if b>1
  for i=2:b
    plot (timephases(i)-timephases(1),slownessphases(i)-slownessphases(1),'mo')
    plot (timephases(i)-timephases(1),slownessphases(i)-slownessphases(1),'b*')
  end
end
else 
if b>1
  for i=2:b
    plot (timephases(i)-timephases(1),slownessphases(i),'mo')
    plot (timephases(i)-timephases(1),slownessphases(i),'b*')
  end
end
end  
title([titl, ',   \Delta min=', num2str(min(delta)), ', \Delta max=', num2str(max(delta))]);
axis ([floor(min(t3)/10)*10-10 ceil(max(t3)/10)*10+10 slowness1-step*2 max(s4)+2*step])
plot ([floor(min(t3)/10)*10-10 floor(min(t3)/10)*10-10 ...
    ceil(max(t3)/10)*10+10 ceil(max(t3)/10)*10+10], [slowness1-step*2 ...
     max(s4)+2*step max(s4)+2*step slowness1-step*2 ], 'k-')
set(gca,'TickDir','out')
% orient landscape
return
