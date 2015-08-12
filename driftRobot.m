function [ robot ] = driftRobot( t, robot, spectra, count )

dt = t(2) - t(1);
x = robot.px; z = robot.pz; 

pErrorX = robot.errors.pErrorX;
pErrorZ = robot.errors.pErrorZ;

rho = spectra.rho;

mDry = robot.mDry;                  %robot dry mass
mAdx = robot.mAdx;                  %robot added mass in x
mAdz = robot.mAdz;                  %robot added mass in z
Ax = robot.width * robot.height;    %incident area in x
Az = robot.length * robot.width;    %incident area in z

if count ~= 1
    [ robot.particles ] = getRobotParticles( t, x, z, spectra, robot.particles, count );
else
    [ robot.particles ] = getSeaStateParticles( t, x, z, spectra );
end

vx = robot.particles.vx(count); ax = robot.particles.ax(count);
vz = robot.particles.vz(count); az = robot.particles.az(count);

[ Cd ] = getCd( vx, vz, Ax, Az );


x2dot = @(tx,x1dot) ...
    (mAdx*ax + rho*Ax*Cd/2 * abs(x1dot-vx) * (x1dot-vx)) / -(mDry+mAdx)/3;

z2dot = @(tz,z1dot) ...
    (mAdz*az + rho*Az*Cd/2 * abs(z1dot-vz) * (z1dot-vz)) / -(mDry+mAdz)/3;

[ tx, yx ] = ode45( x2dot, [0 dt], robot.vx );
[ tz, yz ] = ode45( z2dot, [0 dt], robot.vz );


robot.ax = x2dot( tx(end), yx(end) );
robot.az = z2dot( tz(end), yz(end) );
robot.vx = yx(end); 
robot.vz = yz(end);
robot.px = odeDisplacement( robot.px, yx, tx );
robot.pz = odeDisplacement( robot.pz, yz, tz );

Y = [ robot.px, robot.pz, robot.vx, robot.vz, robot.ax, robot.az ]; 
[ robot.robotPlots ] = updatePlotHistory( Y, robot.robotPlots, count, 1 );

[ robot ] = updateErrors( robot, count, pErrorX, pErrorZ );

tempPx = robot.particlePlots.px(count) + robot.particles.vx(count) * dt;
tempPz = robot.particlePlots.pz(count) + robot.particles.vz(count) * dt;
tempVx = robot.particles.vx(count+1);
tempVz = robot.particles.vz(count+1);
tempAx = robot.particles.ax(count+1);
tempAz = robot.particles.az(count+1);

U = [ tempPx, tempPz, tempVx, tempVz, tempAx, tempAz ];
[ robot.particlePlots ] = updatePlotHistory( U, robot.particlePlots, count, 1 );



return

end