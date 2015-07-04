% waves.m
clear all
close all
home

d = 50; t = 0.5:0.5:100; x = 0; z = 20; theta = 0; rho = 1030;
length = 0.7; width = 0.4; height = 0.4;
T = [10, 8, 12, 11, 6];
H = [1.8, 1, 2.2, 2, 0.4];

[ accelerations ] = particleAcc( d, t, x, z, theta, H, T );
[ velocities, eta ] = particleVel( d, t, x, z, theta, H, T );
[ forces ] = forces( velocities, rho, length, width, height, t);

figure; plot(t, eta);
%figure; plot(t, ax);
%figure; plot(t, az);
figure; plot(t, eta); hold on; 
quiver(t, eta - z, accelerations.x, accelerations.z, 0);

%figure; plot(t, vx);
%figure; plot(t, vz);
figure; plot(t, eta); hold on; 
quiver(t, eta - z, velocities.x, velocities.z, 0);

figure; plot(t, eta); hold on; 
quiver(t, eta - z, forces.x/500, forces.z/500, 0);

figure; plot(t, forces.mag);

comparison(:,1) = velocities.x;
comparison(:,2) = velocities.z;
comparison(:,3) = forces.mag;
comparison(:,4) = forces.theta;


%max(vz)
%find(vz==max(vx))