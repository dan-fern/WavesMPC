function [ robot ] = driftRobot( t, robot, spectra, count )

dt = t(2) - t(1);
x = robot.px; z = robot.pz; 

rho = spectra.rho;

%fA = robot.fA;         %Forward Thruster Angle
%aA = robot.aA;         %Aft Thruster Angle
%vA = robot.vA;         %Vertical Thruster Angle
%Tmax = robot.Tmax;     %Max Thrust
mDry = robot.mDry;
mAdx = robot.mAdx;
mAdz = robot.mAdz;
Ax = robot.width * robot.height;
Az = robot.length * robot.width;

if count ~= 1
    [ robot.particles ] = getRobotParticles( t, x, z, spectra, robot.particles, count );
else
    [ robot.particles ] = getSeaStateParticles( t, x, z, spectra );
end

vx = robot.particles.vx(count); ax = robot.particles.ax(count);
vz = robot.particles.vz(count); az = robot.particles.az(count);

[ Cd ] = getCd( vx, vz, Ax, Az );


x2dot = @(tx,x1dot) ...
    -1/(mDry+mAdx) * (mAdx*ax + rho*Ax*Cd/2 * abs(x1dot-vx) * (x1dot-vx));
[ tx,yx ] = ode45( x2dot, [0 dt], robot.vx );

z2dot = @(tz,z1dot) ...
    -1/(mDry+mAdz) * (mAdz*az + rho*Az*Cd/2 * abs(z1dot-vz) * (z1dot-vz));
[ tz,yz ] = ode45( z2dot, [0 dt], robot.vz );


robot.ax = x2dot( tx(end), yx(end) );
robot.az = z2dot( tz(end), yz(end) );
robot.vx = yx(end); 
robot.vz = yz(end);
robot.px = robot.px + robot.vx * (tx(end) - tx(1)); 
robot.pz = robot.pz + robot.vz * (tz(end) - tz(1));

robot.robotPlots.px(count+1) = robot.px;
robot.robotPlots.pz(count+1) = robot.pz;
robot.robotPlots.vx(count+1) = robot.vx;
robot.robotPlots.vz(count+1) = robot.vz;
robot.robotPlots.ax(count+1) = robot.ax;
robot.robotPlots.az(count+1) = robot.az;

return

end