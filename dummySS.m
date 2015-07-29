clear all
close all
home

IC = [0, -20, 0, 0, 0, 0]; %all initial conditions, pos, vel, acc (x and z)

t = 0.5:0.5:250; x = IC(1); z = IC(2); dt = t(2) - t(1);

volturnus = loadSeaBotix(t,IC);
waves = loadTempWaves(); rho = waves.rho;
swl = zeros(1, numel(t)); %still water line

[ particles, eta ] = getParticles( t, x, z, waves );
%[ forces ] = getForces( particles, rho, length, width, height, t );

fA = volturnus.fA; %Forward Thruster Angle
aA = volturnus.aA; %Aft Thruster Angle
vA = volturnus.vA; 
Tmax = volturnus.Tmax;
mDry = volturnus.mDry;
mAdx = volturnus.mAdx;
mAdz = volturnus.mAdz;
Ax = volturnus.width * volturnus.height;
Az = volturnus.length * volturnus.width;

vx = particles.vx(2); ax = particles.ax(2);
vz = particles.vz(2); az = particles.az(2);

[ Cd ] = getCd( vx, vz, Ax, Az );

%syms x1dot x2dot %m1 m2 m3 m4

%A = [ 0 1;0 0 ];
%B = [ 0 0 0 0; cos(fA) cos(fA) -cos(aA) -cos(aA) ];
%u = [ m1 m2 m3 m4 ]';

%D = [ 0; 1/(mDry+mAdd) * (mAdd*ax + rho*Ax*Cd/2 * abs(x1dot-vx) * (x1dot-vx)) ];

x2dot = @(tx,x1dot) ...
    -1/(mDry+mAdx) * (mAdx*ax + rho*Ax*Cd/2 * abs(x1dot-vx) * (x1dot-vx));
[ tx,yx ] = ode45( x2dot, [0 dt], volturnus.vx );

z2dot = @(tz,z1dot) ...
    -1/(mDry+mAdz) * (mAdz*az + rho*Az*Cd/2 * abs(z1dot-vz) * (z1dot-vz));
[ tz,yz ] = ode45( z2dot, [0 dt], volturnus.vz );

%x2dot = @(time,x1dot) A*x1dot + D;
%[ time,y ] = ode45( x2dot, [0 1], [0 0]' );