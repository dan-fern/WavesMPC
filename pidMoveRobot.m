function [ robot ] = pidMoveRobot( t, robot, spectra, count )

dt = t(2) - t(1);
x = robot.state.px; z = robot.state.pz; 

KpX = 0.35; KpZ = 0.3; 
KiX = 0.0; KiZ = 0.0;
KdX = 2.7; KdZ = 3.2; 

pErrorX = robot.errors.pErrorX;
pErrorZ = robot.errors.pErrorZ;
dErrorX = robot.errors.dErrorX;
dErrorZ = robot.errors.dErrorZ;
iErrorX = robot.errors.iErrorX;
iErrorZ = robot.errors.iErrorZ;

gainsX = KpX * pErrorX + KdX * dErrorX + KiX * iErrorX;
gainsZ = KpZ * pErrorZ + KdZ * dErrorZ + KiZ * iErrorZ;

gainsX( gainsX >=  1) =  1;
gainsX( gainsX <= -1) = -1;
gainsZ( gainsZ >=  1) =  1;
gainsZ( gainsZ <= -1) = -1;

motorInputX = gainsX; robot.uX = motorInputX;
motorInputZ = gainsZ; robot.uZ = motorInputZ;

rho = spectra.rho;

fA = robot.fA;                      %Forward Thruster Angle
aA = robot.aA;                      %Aft Thruster Angle
vA = robot.vA;                      %Vertical Thruster Angle
Tmax = robot.Tmax;                  %Max Thrust
mDry = robot.mDry;                  %robot dry mass
mAdx = robot.mAdx;                  %robot added mass in x
mAdz = robot.mAdz;                  %robot added mass in z
Ax = robot.width * robot.height;    %incident area in x
Az = robot.length * robot.width;    %incident area in z

[ robot.particles ] = getRobotParticles( t, x, z, spectra, robot.particles, count );
vx = robot.particles.vx(count); ax = robot.particles.ax(count);
vz = robot.particles.vz(count); az = robot.particles.az(count);

[ Cd ] = getCd( vx, vz, Ax, Az );


Bx = [ cos(fA) cos(fA) -cos(aA) -cos(aA) ];
ux = [ motorInputX motorInputX -motorInputX -motorInputX ]';

Bz = [ -cos(vA) -cos(vA) ]; 
uz = [ -motorInputZ -motorInputZ ]';

x2dot = @(tx,x1dot) ...
    ((mAdx*ax + rho*Ax*Cd/2 * abs(x1dot-vx) * (x1dot-vx)) / -(mDry+mAdx) ...
    + (Tmax/mDry) * Bx * ux)/2;

z2dot = @(tz,z1dot) ...
    ((mAdz*az + rho*Az*Cd/2 * abs(z1dot-vz) * (z1dot-vz)) / -(mDry+mAdz) ...
    + (Tmax/mDry) * Bz * uz)/2;

[ tx, yx ] = ode45( x2dot, [0 dt], robot.state.vx );
[ tz, yz ] = ode45( z2dot, [0 dt], robot.state.vz );


robot.state.ax = x2dot( tx(end), yx(end) );
robot.state.az = z2dot( tz(end), yz(end) );
robot.state.vx = yx(end); 
robot.state.vz = yz(end);
robot.state.px = odeDisplacement( robot.state.px, yx, tx );
robot.state.pz = odeDisplacement( robot.state.pz, yz, tz );

Y = [ robot.state.px, robot.state.pz, robot.state.vx, robot.state.vz, ...
    robot.state.ax, robot.state.az ]; 
[ robot.robotPlots ] = updatePlotHistory( Y, robot.robotPlots, count, 1 );

[ robot ] = updateErrors( robot, count, pErrorX, pErrorZ );

tempPx = robot.particlePlots.px(count) + robot.particles.vx(count) * dt;
tempPz = robot.particlePlots.pz(count) + robot.particles.vz(count) * dt;
tempVx = robot.particles.vx(count+1);
tempVz = robot.particles.vz(count+1);
tempAx = robot.particles.ax(count+1);
tempAz = robot.particles.az(count+1);

U = [tempPx, tempPz, tempVx, tempVz, tempAx, tempAz];
[ robot.particlePlots ] = updatePlotHistory( U, robot.particlePlots, count, 1 );

return

end