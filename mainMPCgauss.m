%%% tempMPC.m
%%% Daniel Fernández
%%% August 2015
%%% new MPC

clc 
close all
clear global
clear variables
warning('off', 'MATLAB:odearguments:InconsistentDataType')

[ time ] = loadTimeParameters( );
t = time.t;
IC = [0, -15, 0, 0, 0, 0]; %all initial conditions, pos, vel, acc (x and z)
DC = [0, -15, 0, 0, 0, 0]; %all desired conditions, pos, vel, acc (x and z)

[ waves ] = loadTempWaves( );
waves.swl = zeros(1, numel(time.t)); %still water line
[ seaParticles, waves ] = getSeaStateParticles( time.t, IC(1), IC(2), waves );

for i = 1:50
[ volturnus ] = loadSeaBotix( time.t, IC, DC, seaParticles );

counter = 1; 
U = [ IC(1), IC(2), seaParticles.vx(1), seaParticles.vz(1), seaParticles.ax(1), seaParticles.az(1) ];
[ volturnus.particlePlots ] = updatePlotHistory( U, volturnus.particlePlots, counter, 0 );

oldInput = zeros( (time.tSteps-1), 2 ) + NaN;

[ gWaves ] = loadTempWaves( );
gWaves.H = awgn( gWaves.H, 10 );
gWaves.T = awgn( gWaves.T, 25 );
gWaves.E = awgn( gWaves.E, 25 );
[ gParticles, gWaves ] = getSeaStateParticles( time.t, IC(1), IC(2), gWaves );

while counter ~= numel(time.t)-time.tSteps %&& counter < numel(time.t)-time.tSteps
    tic
    [ input, time.tCalc ] = getForecast( time, volturnus, gWaves, counter, oldInput );
    [ volturnus ] = mpcMoveRobot( time.dt, volturnus, waves, counter, input(1,:) );
    volturnus.robotPlots.uX(counter) = input(1,1);
    volturnus.robotPlots.uZ(counter) = input(1,2);
    oldInput = input(2:end,:);
    [ gWaves ] = loadTempWaves( );
    gWaves.H = awgn( gWaves.H, 10 );
    gWaves.T = awgn( gWaves.E, 20 );
    gWaves.E = awgn( gWaves.E, 25 );
    [ gWaves.w, gWaves.L, gWaves.k ] = dispersion( waves.d, waves.T, 9.81 );
    counter = counter + 1;
end
pErrorX = volturnus.errors.pErrorX;
pErrorZ = volturnus.errors.pErrorZ;
[ volturnus ] = updateErrors( volturnus, counter, pErrorX, pErrorZ );
volturnus.errors.tErrorX = sum( abs( volturnus.errorPlots.pErrorX(1:counter-1) ) );
volturnus.errors.tErrorZ = sum( abs( volturnus.errorPlots.pErrorZ(1:counter-1) ) );

volturnus.RMS = sqrt( 1/length(t) * (sqrt( ...
    volturnus.errors.tErrorX^2 + volturnus.errors.tErrorZ^2 ))^2 );
clear counter U pErrorX pErrorZ input oldInput

allRobots(i) = volturnus;
end

%%
tt = t(1:numel(time.t)-time.tSteps);
etaeta = waves.eta(1:numel(time.t)-time.tSteps);
simulator( tt, etaeta, waves.d, DC, volturnus.robotPlots );

temp2 = [ volturnus.errorPlots.pErrorX; volturnus.errorPlots.pErrorZ ]; 
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1)
plot( t(1:numel(t)-20), temp2(1,1:numel(t)-20), 'b' ); 
line( [t(1),t(numel(t)-20)], [0,0],'LineWidth', 1, 'Color', 'r' );
title('Position Error, x');
subplot(2,1,2)
plot( t(1:numel(t)-20), temp2(2,1:numel(t)-20), 'b' );
line( [t(1),t(numel(t)-20)], [0,0],'LineWidth', 1, 'Color', 'r' );
title('Position Error, z');

figure; plot(t, waves.eta); xlabel('time, s'); ylabel('elevation, m');

figure('units','normalized','outerposition',[0 0 1 0.4]); 
plot(t, waves.eta, '-b', 'LineWidth', 2); 
hold on;
baseX = [ t(end)+1, t(1)-1 ];
baseY = [ -4, -4 ];
fill([t(1:end), baseX], [waves.eta(1:end), baseY], 'c', 'EdgeColor', 'b');
hold off;
xlabel('Time, s', 'FontSize', 20); ylabel('Wave Height, m', 'FontSize', 20);
xlim([t(1), t(end)]); ylim([-3, 3]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Wave Height Time Series')