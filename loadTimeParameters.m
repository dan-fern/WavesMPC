%%% loadTimeParameters.m 
%%% Daniel Fernández
%%% June 2015
%%% Returns all time parameters: vector length, discretization, and dt.
%%% Horizon parameter is steps forward MPC will look.  tSteps is the time
%%% length of the horizon.  tCalc is initialized as zero and updated as
%%% calculations are performed.  Goal for tCalc was to let it dictate the
%%% horizon length and partial implementation but that never got built.


function [ time ] = loadTimeParameters( )

time.t = 0.2:0.2:241;
time.dt = time.t(2) - time.t(1);
time.tHorizon = 4 * time.dt;
time.tSteps = time.tHorizon / time.dt;
time.tCalc = 0;

return

end