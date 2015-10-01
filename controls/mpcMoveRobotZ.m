%%% mpcMoveRobotZ.m 
%%% Daniel Fernández
%%% August 2015
%%% Same as mpcMoveRobot( ) except limited to z-axis movement.


function [ robot ] = mpcMoveRobotZ( dt, robot, spectra, count, input )

input( input >=  1) =  1; 
input( input <= -1) = -1;

motorInputZ = input; robot.uZ = motorInputZ;

rho = spectra.rho;

vA = robot.vA;                      %Vertical Thruster Angle
Tmax = robot.Tmax;                  %Max Thrust
mDry = robot.mDry;                  %robot dry mass
mAdz = robot.mAdz;                  %robot added mass in z
Ax = robot.width * robot.height;    %incident area in x
Az = robot.length * robot.width;    %incident area in z

vx = robot.particles.vx(count); %ax = robot.particles.ax(count);
vz = robot.particles.vz(count); az = robot.particles.az(count);

[ Cd ] = getCd( vx, vz, Ax, Az );


Bz = [ -cos(vA) -cos(vA) ]; 
uz = [ -motorInputZ -motorInputZ ]';

z2dot = @(tz,z1dot) ...
    ((mAdz*az + rho*Az*Cd/2 * abs(z1dot-vz) * (z1dot-vz)) / -(mDry+mAdz) ...
    + (Tmax/mDry) * Bz * uz)/2;

[ tz, yz ] = ode45( z2dot, [0 dt], robot.state.vz );


robot.state.az = z2dot( tz(end), yz(end) );
robot.state.vz = yz(end);
robot.state.pz = odeDisplacement( robot.state.pz, yz, tz );

return

end