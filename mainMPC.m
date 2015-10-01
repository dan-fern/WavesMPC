%%% tempMPC.m
%%% Daniel Fernández
%%% August 2015
%%% Launchpad for MPC controller; functions similarly to mainPID.m.  Here, 
%%% you set your initial conditions and desired conditions.  IC and DC take 
%%% the form C = [ posX posZ velX velZ accX accZ ].  A time object is 
%%% loaded, as well as the waves object.  the U vector is used to update 
%%% the initial set of plots.  oldInput is used to initialize the initial
%%% set of control actions to be the PID control actions along the horizon.
%%% The gWaves and gParticles infrastructure is added but commented out.
%%% This was used to attach Gaussian noise to the the wave observations.
%%% There was an unintended consequence here as each noisy sea state
%%% extended calculation time significantly.  This should be addressed.  In 
%%% the while loop, steps iterate through between getting an optimized path
%%% and moving the robot along that path.  The oldInput recycles any unused
%%% control inputs into the next optimization attempt to reduce calculation 
%%% time.  Only the first control action is employed along the horizon, and
%%% using more or all inputs to save calculation time should be explored.


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

%for i = 1:50
[ volturnus ] = loadSeaBotix( time.t, IC, DC, seaParticles );

counter = 1; 
U = [ IC(1), IC(2), seaParticles.vx(1), seaParticles.vz(1), seaParticles.ax(1), seaParticles.az(1) ];
[ volturnus.particlePlots ] = updatePlotHistory( U, volturnus.particlePlots, counter, 0 );

oldInput = zeros( (time.tSteps-1), 2 ) + NaN;

%[ gWaves ] = loadGaussWaves( 10, 25, 25, counter );
%[ gParticles, gWaves ] = getSeaStateParticles( time.t, IC(1), IC(2), gWaves );

while counter ~= numel(time.t)-time.tSteps %&& counter < numel(time.t)-time.tSteps
    tic
    [ input, time.tCalc ] = getForecast( time, volturnus, waves, counter, oldInput );
    %[ input, time.tCalc ] = getForecast( time, volturnus, gWaves, counter, oldInput );
    [ volturnus ] = mpcMoveRobot( time.dt, volturnus, waves, counter, input(1,:) );
    volturnus.robotPlots.uX(counter) = input(1,1);
    volturnus.robotPlots.uZ(counter) = input(1,2);
    oldInput = input(2:end,:);
    counter = counter + 1;
    %[ gWaves ] = loadGaussWaves( 10, 25, 25, counter );
end
pErrorX = volturnus.errors.pErrorX;
pErrorZ = volturnus.errors.pErrorZ;
[ volturnus ] = updateErrors( volturnus, counter, pErrorX, pErrorZ );

clear counter U pErrorX pErrorZ input oldInput

%allRobots(i) = volturnus;
%end

%% Simulator easy access
tt = t(1:numel(time.t)-time.tSteps);
etaeta = waves.eta(1:numel(time.t)-time.tSteps);

% for just the sim
simulator( tt, etaeta, waves.d, DC, volturnus.robotPlots );

% and if you want to write a video
simVid(tt, etaeta, waves.d, DC, volturnus.robotPlots, 'MPCgauss' );
