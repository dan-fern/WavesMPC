function [ time ] = loadTimeParameters( )

time.t = 0.2:0.2:41;
time.dt = time.t(2) - time.t(1);
time.tHorizon = 4 * time.dt;
time.tSteps = time.tHorizon / time.dt;
time.tCalc = 0;

return

end