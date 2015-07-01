% waves.m
clear all
close all
home

d = 50; t = 0.5:0.5:100; x = 0; z = 20; theta = 0;
T = [10, 8, 12, 11, 6];
H = [1.8, 1, 2.2, 2, 0.4];

[ ax, ay, az, eta ] = particleAcc( d, t, x, z, theta, H, T );
[ vx, vy, vz, eta ] = particleVel( d, t, x, z, theta, H, T );

figure; plot(t, eta);
%figure; plot(t, ax);
%figure; plot(t, az);
figure; plot(t, eta); hold on; quiver(t, eta - 20, ax, az);

figure; plot(t, eta);
%figure; plot(t, ax);
%figure; plot(t, az);
figure; plot(t, eta); hold on; quiver(t, eta - 20, vx, vz);