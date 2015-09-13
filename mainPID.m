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
IC = [0, -15, 0, 0, 0, 0]; %all initial conditions, pos, vel, acc (x and z)
DC = [0, -15, 0, 0, 0, 0]; %all desired conditions, pos, vel, acc (x and z)
[ time ] = loadTimeParameters( );
t = time.t;

waves = loadTempWaves( );
waves.swl = zeros(1, numel(time.t)); %still water line

[ seaParticles, waves ] = getSeaStateParticles( time.t, IC(1), IC(2), waves );

volturnus = loadSeaBotix( time.t, IC, DC, seaParticles );
%[ dragForces ] = getDragForces( t, seaParticles, volturnus, waves.rho );

counter = 1; 
U = [ IC(1), IC(2), seaParticles.vx(1), seaParticles.vz(1), seaParticles.ax(1), seaParticles.az(1) ];
[ volturnus.particlePlots ] = updatePlotHistory( U, volturnus.particlePlots, counter, 0 );
wavesOff = numel(time.t) - 180;
%wavesOff = 1;
controllerOn = numel(time.t) - 149;
while counter ~= numel(time.t)
    if counter == controllerOn
        while counter ~= numel(time.t)
            [ waves ] = killWaves( time.t, waves, counter, wavesOff );
            [ volturnus ] = pidMoveRobot( time.t, volturnus, waves, counter );
            counter = counter + 1;
        end
        pErrorX = volturnus.errors.pErrorX;
        pErrorZ = volturnus.errors.pErrorZ;
        [ volturnus ] = updateErrors( volturnus, counter, pErrorX, pErrorZ );
        break
    else
        [ waves ] = killWaves( time.t, waves, counter, wavesOff );
        [ volturnus ] = driftMoveRobot( time.t, volturnus, waves, counter );
        counter = counter + 1;
    end
end
     
clear counter U pErrorX pErrorZ

toc
%%
%simulator( time.t, waves.eta, waves.d, DC, volturnus.robotPlots );
simVid( time.t, waves.eta, waves.d, DC, volturnus.robotPlots, 'PD' );


temp1 = [ volturnus.robotPlots.vx; volturnus.particlePlots.vx; ];
temp1 = [ temp1; volturnus.robotPlots.vz; volturnus.particlePlots.vz; ];

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1)
plot(time.t, temp1(1,:),'r'); hold on; plot(time.t, temp1(2,:),'b');
legend('robot velocity', 'particle velocity')
subplot(2,1,2)
plot(time.t, temp1(3,:),'r'); hold on; plot(time.t, temp1(4,:),'b');
legend('robot velocity', 'particle velocity')
%%
temp2 = [ volturnus.errorPlots.pErrorX; volturnus.errorPlots.pErrorZ ]; 
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1)
plot( time.t(controllerOn-1:125), temp2(1,controllerOn-1:125), 'b','LineWidth', 2 ); 
line( [time.t(controllerOn-1),time.t(end)], [0,0],'LineWidth', 2, 'Color', 'r' );
xlim( [time.t(controllerOn-1),time.t(125)] );
ylabel({'Position Error, x'}, 'FontSize', 20);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Feedback (PD) Controller Tuning');
subplot(2,1,2)
plot( time.t(controllerOn-1:125), temp2(2,controllerOn-1:125), 'b','LineWidth', 2 );
line( [time.t(controllerOn-1),time.t(end)], [0,0],'LineWidth', 2, 'Color', 'r' );
xlim( [time.t(controllerOn-1),time.t(125)] );
ylabel('Position Error, z', 'FontSize', 20); xlabel('Time, s');
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);

clear temp1 temp2


