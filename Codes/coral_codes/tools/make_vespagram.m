function  make_vespagram(timestack, slowness, stackeddata, Delta, Loc, Station, Mag,...
             env, scal, phases, relative,timephases,slownessphases));
% 					Matlab function to make a color vespagram

titl=set_title(Loc(:,1),Station(:,1),Mag(:,1));  %  title  for   plots
mnd=mean(Delta); 		        % mean offset
[a,b]=size(stackeddata);
if env == 1
  for i=1:b
    s3(:,i)=abs(hilbert(stackeddata(:,i))); 	% form envelope
  end
  else
    s3 = stackeddata;
end


% Look up arrival times and slowness
%phases = ['P     ';phases];
%[timephases,slownessphases] = get_ttt(phases, Loc(6,1), mnd);

% plot stacks
hold off
plot (10000,100000)
hold on;
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
axis ([floor(min(timestack)/10)*10-10 ceil(max(timestack)/10)*10+10 min(slowness) ...
    max(slowness)])
 plot ([floor(min(timestack)/10)*10-10 floor(min(timestack)/10)*10-10 ...
    ceil(max(timestack)/10)*10+10 ceil(max(timestack)/10)*10+10], [min(slowness) ...
     max(slowness) max(slowness) min(slowness) ], 'k-')
set(gca,'TickDir','out')

rnd= round(.5/(timestack(3)-timestack(2)));
timestack=decimate(timestack,rnd); 
[tmp1,tmp2]=size(s3);s2=s3;
clear s3;
for tmp1 = 1:tmp2 
	  s3(:,tmp1)=decimate(s2(:,tmp1),rnd,'FIR'); 
end
maxs=scal;s3=(abs(s3)>maxs)*maxs.*sign(s3)  +  (abs(s3)<=maxs).*s3;  
s=surf(timestack,slowness,-s3');view(0,90);shading flat; colormap('hot'); 
ylabel('Differential Slowness (Seconds / Degree)');xlabel('Time after P Arrival (Seconds)')
title(titl);
orient landscape
return
