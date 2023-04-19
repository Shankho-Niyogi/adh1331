
function [ dx, dt, irtr ] = layertx ( p, h, utop, ubot )

% Layertx: Calculate dx and dt
%
% Layertx calculates dx and dt for a ray in a layer with a 
% linear velocity gradient.  This is a highly modified version 
% of a subroutine in Chris Chapman's WKBJ program. This code is 
% also translated from a fortran code by Peter Shearer.
%
% Inputs:   p       =   horizontal slowness
%           h       =   layer thickness
%           utop    =   slowness at top of layer
%           ubot    =   slowness at bottom of layer
%
% Returns : dx      =   range offset
%           dt      =   travel time
%           irtr    =   return code
%                   =   -1, zero thickness layer
%                   =   0, ray turned above layer
%                   =   1, ray passed through layer
%                   =   2, ray turned in layer, 1 leg counted


if ( p >= utop )    % Ray turned above layer
    dx = 0;
    dt = 0;
    irtr = 0;
    return;
elseif ( h == 0 )   % Zero thickness layer
    dx = 0;
    dt = 0;
    irtr = -1;
    return;
end

% Find slope of velocity gradient
u1 = utop;
u2 = ubot;

v1 = 1/u1;
v2 = 1/u2;
b = ( v2 - v1 )/h;

eta1 = sqrt ( u1.^2 - p.^2 );   % Horizontal slowness (upper boun.)

if ( b == 0 )       % Constant velocity layer
    dx = ( h * p )/ eta1;
    dt = ( h * u1.^2 )/ eta1;
    irtr = 1;
    return;
end

% Equations from pg 41--Shearer, Indroduction to Seismology
x1 = eta1 / ( u1 * b * p );
tau1 = ( log ( ( u1 + eta1 )/ p ) - eta1 / u1 ) / b;

% Ray turned within layer, no contribution to integral from bottom 
% point.
if ( p >= ubot )    
    dx = x1;
    dtau = tau1;
    dt = dtau + ( p * dx );
    irtr = 2;
    return;
end

irtr = 1;

eta2 = sqrt ( u2.^2 - p.^2 );   % Horizontal Slowness (lower boun.)
x2 = eta2 / ( u2 * b * p );
tau2 = ( log ( ( u2 + eta2 )/ p ) - eta2 / u2) / b;

dx = x1 - x2;
dtau = tau1 -tau2;

dt = dtau + p * dx;

return;
    function plotTT(depth, pVel, pMin, pMax, pNumber)
% PlotTT
%
% Find and plot a T(x) plot, X(p) plot and tau(p) plot of a range
% of slownesses.

pModel = [depth pVel];


% Read velocity model into matrices
%s = load ('velModel');
%pModel = [ s( : , 1 ), s( : , 2 ) ];
%sModel = [ s( : , 1 ), s( : , 3 ) ];
%density = [ s( : , 1 ), s( : , 4 ) ];

%depth = [s( : , 1 )];

%pMin = 0.1236;  % Hardcoded
%pMax = 0.2217;  % Hardcoded

%pNumber = 100;  % Defined by problem

pInterval = ( pMax - pMin )/ pNumber;

p = [ pMin: pInterval : pMax ];

pData = zeros ( length (p), 3 );    % Initialize for speed
iInd = 1;                           % Counter for saving data

for  w = pMin : pInterval : pMax    % Loop over ray parameters
    
    dx = 0;             % Initialize all variable in depth loop
    dt = 0;
    dxOld = 0;
    dxNew = 0;
    dtOld = 0;
    dtNew = 0;
    dxTotal = 0;
    dtTotal = 0;
    jInd = 1;
    
    for z = 1 : length ( depth ) - 1            % Loop over depth
        % Calc slowness at top
        utop = 1/ ( pModel( jInd, 2 ) ); 
        % Calc slowness at bottom   
        ubot = 1/ ( pModel ( jInd + 1, 2 ) ); 
        % Calc thickness
        h = ( depth ( jInd + 1 ) - depth ( jInd )); 
        
        % Calculate dx and dt
        [ dx, dt, irtr ] = layertx ( w, h, utop, ubot );
        
        % Add dx and dt to total until ray turns, or until end of
        % model is reached.  All rays that hit the bottom of the 
        % model are reflected.
        dxNew = dxOld + dx;
        dtNew = dtOld + dt;
        dtOld = dtNew;
        dxOld = dxNew;            
        
        jInd = jInd + 1;    % Increment depth index
        
    end
    
    % Multiply dx and dt by two to get total traveltime
    dxTotal = dxOld * 2;
    dtTotal = dtOld * 2;
    
    % Save dx and dt for each ray parameter
    pData ( iInd, 1 ) = w;
    pData ( iInd, 2 ) = dxTotal;
    pData ( iInd, 3 ) = dtTotal;
    
    iInd = iInd + 1;    % Increment ray parameter index
    
end

% Convert from km to degrees
pData( :, 2 ) = pData( :, 2 ).*(360/(2*pi*6371));

% T(x) plot 
figure (1);
clf
%subplot (511);
subplot(2,1,1);
%reduceDT = pData ( :, 3 ) - ( pData ( :, 2 )/ 8 );
plot ( pData ( :, 2 ), pData(:, 3), 'ro', 'LineWidth', 2.0 );
title ( 'T(x) Plot','FontWeight', 'bold','FontSize',12);
xlabel ( 'Range, Degrees' );
ylabel ( 'T, sec' );
subplot(2,1,2);
reduceDT = pData ( :, 3) - (pData ( :, 2)/0.1);
plot ( pData( :, 2 ), reduceDT, 'r-', 'LineWidth', 2.0 );
xlim([10 30]);
ylim([20 100]);
xlabel ( 'Range, Degrees' );
ylabel ( 'T, sec' );
% X(p) plot 
%figure (2);
%subplot (513);
%plot ( pData ( :, 1 ), pData ( :, 2 ), 'b-', 'LineWidth', 2.0 );
%title ( 'X(p) Plot', 'FontWeight', 'bold', 'FontSize', 12 );
%xlabel ( 'Ray Parameter' );
%ylabel ( 'Range' );

% Tau(p) plot
%figure (3);
%subplot (515);
%tau = pData(:,3) - pData(:,1) .* pData(:,2);
%plot ( pData ( :, 1 ), tau, 'g-', 'LineWidth', 2.0 );
%title ( 'Tau(p) Plot', 'FontWeight', 'bold', 'FontSize', 12 );
%xlabel ( 'Ray Parameter' );
%ylabel ( 'Tau [ T(p)-p*X(p) ]' );

% Plot model
%figure (4);
%hold on;
%plot ( pModel ( :, 2 ), -1*pModel ( :, 1 ), 'r-','Linewidth', 2.0);
%plot ( sModel ( :, 2 ), -1*sModel ( :, 1 ), 'b-','Linewidth', 2.0);
%plot ( density ( :, 2 ), -1*density ( :, 1 ), 'g-','Linewidth', 2.0);
%yLimit = -1*(max ( depth ));
%ylim ([yLimit, 0]);
%ylabel ( 'Depth' );
hold off;
%######################################################
%	Problem 4.7 from Shearer 1999			#
%							#
%########################################################
clear;
cntr = 0;
pMin = 0.001;
pMax = 0.1128;
pNumber = 201;
%Get prem model and make earth-flattening transformation
r = linspace(6371, 11, 6360);
pVel = prem(r);
a = 6371;
rTransform = a - r;
depth = (-a*log(r./a))';
pVel = ((a./r).*pVel)';
plotTT(depth, pVel, pMin, pMax, pNumber);
