%%% updateErrors.m 
%%% Daniel Fernández
%%% July 2015
%%% Updates all errors in the robot object. pError is positional, dError is
%%% derivative, iError is integral, tError is total, and RMS is RMS for the
%%% entire set.


function [ robot ] = updateErrors( robot, count, pErrX, pErrZ )

robot.errors.pErrorX = robot.DC.px - robot.state.px;
robot.errors.pErrorZ = robot.DC.pz - robot.state.pz;
robot.errorPlots.pErrorX(count) = robot.errors.pErrorX;
robot.errorPlots.pErrorZ(count) = robot.errors.pErrorZ;

robot.errors.dErrorX = robot.errors.pErrorX - pErrX;
robot.errors.dErrorZ = robot.errors.pErrorZ - pErrZ;

robot.errors.iErrorX = sum( robot.errorPlots.pErrorX(1:count) ); 
robot.errors.iErrorZ = sum( robot.errorPlots.pErrorZ(1:count) ); 
robot.errorPlots.iErrorX(count) = robot.errors.iErrorX;
robot.errorPlots.iErrorZ(count) = robot.errors.iErrorZ;

if count < length( robot.errorPlots.pErrorX ) - 1
    return
else
    robot.errors.tErrorX = sum( abs( robot.errorPlots.pErrorX(1:count-1) ) );
    robot.errors.tErrorZ = sum( abs( robot.errorPlots.pErrorZ(1:count-1) ) );
    robot.RMS = sqrt( 1/length( robot.errorPlots.pErrorX ) ...
        * (sqrt( robot.errors.tErrorX^2 + robot.errors.tErrorZ^2 ))^2 );
end

end