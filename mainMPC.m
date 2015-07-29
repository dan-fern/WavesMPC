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

waves = loadTempWaves();
waves.swl = zeros(1, numel(t)); %still water line

[ seaParticles, waves ] = getSeaStateParticles( t, x0, z0, waves );

volturnus = loadSeaBotix( t, IC );

[ dragForces ] = getDragForces( t, seaParticles, volturnus, waves.rho );

counter = 1;
while counter ~= numel(t)
    [ volturnus ] = driftRobot ( t, volturnus, waves, counter );
    counter = counter + 1;
end
clear counter

toc

simulator( t, waves.eta, waves.d, IC, volturnus.robotPlots );
