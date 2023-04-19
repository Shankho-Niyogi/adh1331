vs=[4.4 4.35 4.32 4.29 4.29 4.32 4.35 4.39 4.43 4.47 4.51 4.57 4.63 4.68 4.73 4.78 ...
5.00 5.05 5.09 5.14 5.19 5.24 5.29 5.345 5.395 5.445 5.500 5.91 5.98 6.05 6.13 6.20 ...
6.22 6.24 6.26 6.275 6.29 6.305 6.32 6.335 6.350 6.365 6.385 6.405];

vssna=[4.8 4.79 4.775 4.775 4.775 4.775 4.71 4.63 4.64 4.67 4.695 4.72 4.74 4.755 ...
4.765 4.78 5.00 5.05 5.09 5.14 5.19 5.24 5.29 5.345 5.395 5.445 5.500 5.91 5.98 6.05 ...
6.13 6.20 6.22 6.24 6.26 6.275 6.29 6.305 6.32 6.335 6.350 6.365 6.385 6.405];

h=[38 50:25:375 405 406 425:25:625 659 660 675:25:1050];
hiasp=[1:700,710:10:1000];
[vp,vsiasp]=iasp91(6371-hiasp);
[vp,vstna] =tna (6371-hiasp);
[vp,vsprem]=prem(6371-hiasp);
%plot(vs,-h,vssna,-h,vsiasp,-h,vsprem,-h)
plot(vs,-h,'+',vstna,-hiasp)

disc = [750 660 405 275 38];
disc = [750 660 405 200 150 50 38];

% transition zone
i=[find(h==406) : find(h==659)]; L=1;
i=[find(h==275) : find(h==405)]; L=2;
i=[find(h== 38) : find(h==275)]; L=3;

VS=vs(i);H=h(i);y=(6371-H)/6371;
[p,S]=polyfit(y,VS,L);disp(sprintf('%10.5f,',fliplr(p)))
[VS1,delta]=polyval(p,y,S);
plot(VS1,-H,'-',VS,-H,'+');

[vpi,vsi]=iasp91(6371-H); VP = VS .* vpi./vsi;
[p,S]=polyfit(y,VP,L);disp(sprintf('%10.5f,',fliplr(p)))
[VP1,delta]=polyval(p,y,S);
plot(VP1,-H,'-',VP,-H,'+');


r=[0:1:6371]';
[pvel,svel,density,qp,qs,qk] = tna(r);TNA=[pvel,svel,density,qp,qs,qk];
[pvel,svel,density,qp,qs,qk] = iasp91(r);IASP=[pvel,svel,density,qp,qs,qk];
for i=1:3;plot(TNA(:,i),6371-r,IASP(:,i),6371-r);axis([-Inf Inf 0 700]);pause;end
for i=4:6;plot(1./TNA(:,i),6371-r,1./IASP(:,i),6371-r);axis([-Inf Inf 0 700]);pause;end

