function [time,beam] = make_beam(data1,header1)
% Matlab function 
% function [time,beam] = make_beam(data1,header1)
% matlab script to make a beam - linear stack

beam = sum(data1'); [a,b]=max(abs(beam)); beam = beam/beam(b);

% set time to peak at zero
[tmp1,tmp2] = size(beam);
time = (b*header1(6,1)*(-1):header1(6,1):(tmp2-b-1)*header1(6,1));

% plot beam
hold off;
h=figure;
plot(time,beam,'g-');grid;xlabel('time(s)');ylabel('Amplitude')
axis ([floor(min(time)/10)*10-10 ceil(max(time)/10)*10+10 -1.1 1.1])
title('Beam')
orient landscape
return
