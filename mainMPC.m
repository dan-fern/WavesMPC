%%% mainMPC.m 
%%% Daniel Fernández
%%% June 2015
%%% launchpad

clc
close all
clear global
clear variables
warning('off', 'MATLAB:odearguments:InconsistentDataType')

tic
IC = [0, -20, 0, 0, 0, 0]; %all initial conditions, pos, vel, acc (x and z)
t = 0.5:0.5:105; 
x0 = IC(1); z0 = IC(2);

waves = loadTempWaves( );
waves.swl = zeros(1, numel(t)); %still water line

[ seaParticles, waves ] = getSeaStateParticles( t, x0, z0, waves );

volturnus = loadSeaBotix( t, IC );
%[ dragForces ] = getDragForces( t, seaParticles, volturnus, waves.rho );

counter = 1; 
U = [ IC(1), IC(2), seaParticles.vx(1), seaParticles.vz(1), seaParticles.ax(1), seaParticles.az(1) ];
[ volturnus.particlePlots ] = updatePlotHistory( U, volturnus.particlePlots, counter, 0 );
while counter ~= numel(t)
    [ volturnus ] = driftRobot( t, volturnus, waves, counter );
    counter = counter + 1;
    %waves = killWaves( t, waves, counter, numel(t) - 100 );
end
clear counter U

toc

%simulator( t, waves.eta, waves.d, IC, volturnus.robotPlots );
%%
temp = [ volturnus.robotPlots.vx; volturnus.particlePlots.vx; ];
temp = [ temp; volturnus.robotPlots.vz; volturnus.particlePlots.vz; ];

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1)
plot(t, temp(1,:),'r'); hold on; plot(t, temp(2,:),'b');
legend('robot velocity', 'particle velocity')
subplot(2,1,2)
plot(t, temp(3,:),'r'); hold on; plot(t, temp(4,:),'b');
legend('robot velocity', 'particle velocity')