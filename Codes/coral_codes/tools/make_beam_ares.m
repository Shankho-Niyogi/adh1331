function [time,beam] = make_beam_ares(data1,header1)
% Matlab function 
% function [time,beam] = make_beam_ares(data1,header1)
% matlab script to make a beam - linear stack

beam = sum(data1'); [a,b]=max(abs(beam)); beam = beam/abs(beam(b));

% set time to peak at zero
[tmp1,tmp2] = size(beam);
time = (b*header1(6,1)*(-1):header1(6,1):(tmp2-b-1)*header1(6,1));

beam = rot90(beam,-1);
beam = taperd(beam,0.05);

% plot beam
hold off;
h=figure;
plot(time,beam,'g'); grid; xlabel('Time (s)');ylabel('Amplitude')
axis ([floor(min(time)) ceil(max(time)) -1 1])
title('Beam')
orient landscape
return
