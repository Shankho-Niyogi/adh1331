%  Computes ray paths in a vertically stratified Earth as determined by PREM.  
clear;
clf;

EarthRad = 6730;
lyr_thkns = EarthRad/68000;
rad = [1:lyr_thkns:6730]';
v_sph = prem2(rad);

v_flt = EarthRad*(v_sph.*(rad).^(-1))';
slwns = flipud((v_flt.^(-1))');

rayP = ([0.001:(0.128-0.001)/201:0.128]');

k = 0;
X = 0;
Z = 0;
T = 0;
n = 0;

%axis([0 170, 0, 100]);

for(n = 1:201)
    X = 0;
    T = 0;
    
    for (k = 1:(length(slwns)-2))
        
        [dX, dZ, dT, Irtr] = trace_layer(rayP(n), lyr_thkns, slwns(k), slwns(k+1));
        if(Irtr > 0)
            X = X + dX;
            T = T + dT;
        end
        if(Irtr == 0 | Irtr == 2)
            break;
        end
        
    end
    Xrange(n,1) = 2*X;
    Trange(n,1) = 2*T;
    
    Trdcd(n) = Trange(n) - Xrange(n)/10;
    tau(n) = Trange(n) - rayP(n)*Xrange(n);

end
hold on;
figure(1)
plot(Xrange*180/(pi*6730),(Trange)/60);
figure(2)
plot(Xrange*2*180/(pi*6730),(Trdcd)/60);
