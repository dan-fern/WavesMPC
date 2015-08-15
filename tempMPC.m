%%% tempMPC.m
%%% Daniel Fernández
%%% August 2015
%%% new MPC

clc 
close all
clear global
clear variables
warning('off', 'MATLAB:odearguments:InconsistentDataType')

tic

t = 0.2:0.2:12;
IC = [0, -20, 0, 0, 0, 0]; %all initial conditions, pos, vel, acc (x and z)
DC = [0, -20, 0, 0, 0, 0]; %all desired conditions, pos, vel, acc (x and z)
x0 = IC(1); z0 = IC(2);

waves = loadTempWaves( );
waves.swl = zeros(1, numel(t)); %still water line
[ seaParticles, waves ] = getSeaStateParticles( t, x0, z0, waves );

volturnus = loadSeaBotix( t, IC, DC );

counter = 1; 
U = [ IC(1), IC(2), seaParticles.vx(1), seaParticles.vz(1), seaParticles.ax(1), seaParticles.az(1) ];
[ volturnus.particlePlots ] = updatePlotHistory( U, volturnus.particlePlots, counter, 0 );
clear U

while counter ~= numel(t)- 25
    [ volturnus ] = mpcRobot( t, volturnus, waves, counter );
    counter = counter + 1;
end
pErrorX = volturnus.errors.pErrorX;
pErrorZ = volturnus.errors.pErrorZ;
[ volturnus ] = updateErrors( volturnus, counter, pErrorX, pErrorZ );
clear counter U x0 z0

toc

%simulator( t(1:numel(t)-20), waves.eta, waves.d, DC, volturnus.robotPlots );

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