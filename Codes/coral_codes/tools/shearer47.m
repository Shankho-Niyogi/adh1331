%Uses PREM (Shearer appendix 1) to define a model layer. Then uses
%subroutine TRACE_LAYER provided by Ken to sketch the rays within the layer

% TRACE_LAYER      trace a sysmic ray through a layer with a linear velocity gradient
% USAGE: [dx, dz, dt, irtr] = trace_layer(p, h, utop, ubot);
% 
% Input:
% -----
% p - horizontal slowness (sin(i)/v) (s/km)
% h - layer thickness (km)
% utop - slowness at top of layer (s/km)
% ubot - slowness at bottom of layer (s/km)
clear all;close all;clc


load PREM.m
a=6371;                           %define radius of earth [km]
depth_sph=PREM(:,1);              %depth of layer [km]
r_sph=a-depth_sph;                %define spherical radium
pvel_sph=PREM(:,2)/1000;           %p-wave velocity in layer [km/s]
                      

depth_fl=-a*log(r_sph./a);      %finds the equivalent spherical radii (shearer eq 4.45)
pvel_fl=(a*pvel_sph)./r_sph;     %finds the equivalent spherical velocities (eq. 4.46)

%In order to find the number of layers and their thicknesses, I need to
%remove the values that are repeated

Ndepth_fl=depth_fl;
sizes=length(Ndepth_fl);

for j=1:sizes
    if j<=sizes-1
        if Ndepth_fl(j)==Ndepth_fl(j+1)
            Ndepth_fl(j+1)=[];
            sizes=sizes-1;
        end
    end
end

% OK now i'm in a position to find the thickness of each layer
c=1;
for j=1:sizes
    if j<=sizes-1
        %finds thickness [km] of layers
            H(c,1)=Ndepth_fl(c+1)-Ndepth_fl(c);
            c=c+1;
    end
end

% This step finds Utop, the slowness at the TOP of each layer
c=1;
for j=1:length(depth_fl)
    if j<=length(depth_fl)-1
        %finds top velocites of layers
        if depth_fl(j)<depth_fl(j+1)
            Utop(c,1)=1/pvel_fl(j);
            c=c+1;
        elseif depth_fl(j)==depth_fl(j+1)
            continue
        end
    end
end


%This step find Ubot, the slowness at the BOTTOM of each layer
c=1;
for j=1:length(depth_fl)
    if j<=length(depth_fl)-1
        %finds bottom velocites of layers
        if depth_fl(j)<depth_fl(j+1)
            Ubot(c,1)=1/pvel_fl(j+1);
            c=c+1;
        elseif depth_fl(j)==depth_fl(j+1)
            continue
        end
    end
end


%Initialize P (from problem statement)
P=linspace(0.0001, 0.1128, 201)';



for rayparam=1:length(P)
    Xtot=0;
    Ttot=0;
    Ztot=0;
    for layers=1:length(H)
        p=P(rayparam);
        h=H(layers);
        utop=Utop(layers);
        ubot=Ubot(layers);
        [dx, dz, dt, irtr] = trace_layer(p, h, utop, ubot);
        if irtr < 0
            break
        end
        Xtot=Xtot+dx;
        Ttot=Ttot+dt;
        Ztot=Ztot+dz;
    end
    XtotVec(rayparam,1)=Xtot;
    TtotVec(rayparam,1)=Ttot;
    ZtotVec(rayparam,1)=Ztot;
end

%convert Xtot into deg
XtotVecdeg=XtotVec.*360/40030;
plot(XtotVecdeg, TtotVec,':')
xlabel('Total distance travelled [deg]')
ylabel('Total travel time')
