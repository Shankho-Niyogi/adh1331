% TRACE_LAYER      trace a sysmic ray through a layer with a linear velocity gradient
% USAGE: [dx, dz, dt, irtr] = trace_layer(p, h, utop, ubot);
% 
% Input:
% -----
% p - horizontal slowness (sin(i)/v) (s/km)
% h - layer thickness (km)
% utop - slowness at top of layer (s/km)
% ubot - slowness at bottom of layer (s/km)
%
% Output:
% ------
% dx - range offset (km)
% dz - vertical distance traveled (km)
% dt - travel time (s)
% irtr - return code: 
%          -1, zero thickness layer
%           0, ray turned above layer
%           1, ray passed through layer
%           2, ray turned in layer, 1 leg counted in dx, dt, dz
%
%  Modified from Peter Shearer's book

    % check input
    function[dx, dz, dt, irtr] = trace_layer(p, h, utop, ubot);
    if (p >= utop) % ray turned above layer
        dx = 0;
        dt = 0;
        dz = 0;
        irtr = 0;
        return;
    end

    if (h == 0)  % zero thickness layer (discontinuity)
        dx = 0;
        dt = 0;
        dz = 0;
        irtr = -1;
        return;
    end
    
    % set slowness
    u1 = utop;
    u2 = ubot;
    
    % get velocities
    v1 = 1/u1;
    v2 = 1/u2;
    
    b = (v2-v1)/h;  % slope of velocity gradient
    
    eta1 = sqrt(u1^2 - p^2);  % vertical slowness at top
    
    if (b == 0)     % constant velocity layer
        dx = h*p/eta1;
        dt = h*u1^2/eta1;
        dz = h;
        irtr = 1;
        return;
    end
    
    x1 = eta1/(u1*b*p);
    tau1 = (log((u1+eta1)/p)-eta1/u1)/b;
    
    if (p == ubot)  % ray turns within layer
        dx = x1;
        dtau = tau1;
        dt = dtau + p*dx;
        dz = (1/p - v1)/b;
        irtr = 2;
        return;
    end
    
    irtr = 1;   % ray passed through layer
    
    eta2 = sqrt(u2^2 - p^2);
    x2 = eta2/(u2*b*p);
    tau2 = (log((u2+eta2)/p)-eta2/u2)/b;
    
    dx = x1 - x2;       % calculate range offset
    dtau = tau1 - tau2;
    
    dt = dtau + p*dx;   % calculate travel time
    dz = h;
    
    return;
% end of function trace_layer