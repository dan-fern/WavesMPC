%%% mpcMoveRobotX.m 
%%% Daniel Fernández
%%% August 2015
%%% Same as mpcMoveRobot( ) except limited to x-axis movement.


function [ robot ] = mpcMoveRobotX( dt, robot, spectra, count, input )

input( input >=  1) =  1; 
input( input <= -1) = -1;

motorInputX = input; robot.uX = motorInputX;

rho = spectra.rho;

fA = robot.fA;                      %Forward Thruster Angle
aA = robot.aA;                      %Aft Thruster Angle
Tmax = robot.Tmax;                  %Max Thrust
mDry = robot.mDry;                  %robot dry mass
mAdx = robot.mAdx;                  %robot added mass in x
Ax = robot.width * robot.height;    %incident area in x
Az = robot.length * robot.width;    %incident area in z

vx = robot.particles.vx(count); ax = robot.particles.ax(count);
vz = robot.particles.vz(count); %az = robot.particles.az(count);

[ Cd ] = getCd( vx, vz, Ax, Az );


Bx = [ cos(fA) cos(fA) -cos(aA) -cos(aA) ];
ux = [ motorInputX motorInputX -motorInputX -motorInputX ]';

x2dot = @(tx,x1dot) ...
    ((mAdx*ax + rho*Ax*Cd/2 * abs(x1dot-vx) * (x1dot-vx)) / -(mDry+mAdx) ...
    + (Tmax/mDry) * Bx * ux)/2;

[ tx, yx ] = ode45( x2dot, [0 dt], robot.state.vx );


robot.state.ax = x2dot( tx(end), yx(end) );
robot.state.vx = yx(end); 
robot.state.px = odeDisplacement( robot.state.px, yx, tx );


return

end