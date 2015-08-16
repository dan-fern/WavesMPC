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

return

end