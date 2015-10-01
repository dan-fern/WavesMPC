%%% mainPID.m 
%%% Daniel Fernández
%%% June 2015
%%% Launchpad for PID controller.  Here, you set your initial conditions
%%% and desired conditions.  IC and DC take the form C = [ posX posZ velX 
%%% velZ accX accZ ].  A time object is loaded, as well as the waves 
%%% object.  the U vector is used to update the initial set of plots.
%%% wavesOff is used to shut off the waves if you like.  controllerOn is
%%% likewise used if you'd like to delay the controller turning on.  In the
%%% while loop, steps iterate through and are classified based on whether
%%% the controller is on or not, or in other words calls pidMoveRobot( ) or
%%% driftMoveRobot( ).  Additionally, the wavesOff function is called here
%%% if you want to shut off waves at any point.


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
controllerOn = 1;%numel(time.t) - 149;
while counter ~= numel(time.t)
    if counter == controllerOn
        while counter ~= numel(time.t)
            %[ waves ] = killWaves( time.t, waves, counter, wavesOff );
            [ volturnus ] = pidMoveRobot( time.t, volturnus, waves, counter );
            counter = counter + 1;
        end
        pErrorX = volturnus.errors.pErrorX;
        pErrorZ = volturnus.errors.pErrorZ;
        [ volturnus ] = updateErrors( volturnus, counter, pErrorX, pErrorZ );
        break
    else
        %[ waves ] = killWaves( time.t, waves, counter, wavesOff );
        [ volturnus ] = driftMoveRobot( time.t, volturnus, waves, counter );
        counter = counter + 1;
    end
end
     
clear counter U pErrorX pErrorZ

toc
%% Simulator easy access

% for just the sim
simulator( time.t, waves.eta, waves.d, DC, volturnus.robotPlots );

% and if you want to write a video
simVid( time.t, waves.eta, waves.d, DC, volturnus.robotPlots, 'Drift' );
