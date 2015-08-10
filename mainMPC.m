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
IC = [5, -12, 0, 0, 0, 0]; %all initial conditions, pos, vel, acc (x and z)
DC = [0, -20, 0, 0, 0, 0]; %all desired conditions, pos, vel, acc (x and z)
t = 0.5:0.5:55; 
x0 = IC(1); z0 = IC(2);

waves = loadTempWaves( );
waves.swl = zeros(1, numel(t)); %still water line

[ seaParticles, waves ] = getSeaStateParticles( t, x0, z0, waves );

volturnus = loadSeaBotix( t, IC, DC );
%[ dragForces ] = getDragForces( t, seaParticles, volturnus, waves.rho );

counter = 1; 
U = [ IC(1), IC(2), seaParticles.vx(1), seaParticles.vz(1), seaParticles.ax(1), seaParticles.az(1) ];
[ volturnus.particlePlots ] = updatePlotHistory( U, volturnus.particlePlots, counter, 0 );
wavesOff = numel(t) - 90;
%wavesOff = 1;
controllerOn = numel(t) - 79;
while counter ~= numel(t)
    waves = killWaves( t, waves, counter, wavesOff );
    [ volturnus ] = driftRobot( t, volturnus, waves, counter );
    if counter == controllerOn
        while counter ~= numel(t)
            [ volturnus ] = pidRobot( t, volturnus, waves, counter );
            counter = counter + 1;
        end
        pErrorX = volturnus.errors.pErrorX;
        pErrorZ = volturnus.errors.pErrorZ;
        [ volturnus ] = updateErrors( volturnus, counter, pErrorX, pErrorZ );
        break
    end
    counter = counter + 1;
end
clear counter U

toc

%simulator( t, waves.eta, waves.d, IC, DC, volturnus.robotPlots );


temp1 = [ volturnus.robotPlots.vx; volturnus.particlePlots.vx; ];
temp1 = [ temp1; volturnus.robotPlots.vz; volturnus.particlePlots.vz; ];

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1)
plot(t, temp1(1,:),'r'); hold on; plot(t, temp1(2,:),'b');
legend('robot velocity', 'particle velocity')
subplot(2,1,2)
plot(t, temp1(3,:),'r'); hold on; plot(t, temp1(4,:),'b');
legend('robot velocity', 'particle velocity')

temp2 = [ volturnus.errorPlots.pErrorX; volturnus.errorPlots.pErrorZ ]; 
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1)
plot( t(controllerOn-1:end), temp2(1,controllerOn-1:end), 'b' ); 
line( [t(controllerOn-1),t(end)], [0,0],'LineWidth', 1, 'Color', 'r' );
title('Position Error, x');
subplot(2,1,2)
plot( t(controllerOn-1:end), temp2(2,controllerOn-1:end), 'b' );
line( [t(controllerOn-1),t(end)], [0,0],'LineWidth', 1, 'Color', 'r' );
title('Position Error, z');

clear temp1 temp2


