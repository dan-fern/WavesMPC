% dummyPlots

temp = [ volturnus.robotPlots.vx; volturnus.particlePlots.vx; ];
temp = [ temp; volturnus.robotPlots.vz; volturnus.particlePlots.vz; ];

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,1,1)
plot(t, temp(1,:),'r'); hold on; plot(t, temp(2,:),'b');
legend('robot velocity', 'particle velocity')
subplot(2,1,2)
plot(t, temp(3,:),'r'); hold on; plot(t, temp(4,:),'b');
legend('robot velocity', 'particle velocity')

figure; plot(t, waves.eta); xlabel('time, s'); ylabel('elevation, m');

figure; plot(t, waves.eta); hold on; plot(t, waves.swl, 'linestyle', '--'); 
hold on; quiver(t, waves.eta + z0, seaParticles.ax, seaParticles.az, 0); 
hold on; xlabel('time, s'); ylabel('elevation, m'); 
title('Acceleration Vectors');

figure; plot(t, waves.eta); hold on; plot(t, waves.swl, 'linestyle', '--'); 
hold on; quiver(t, waves.eta + z0, seaParticles.vx, seaParticles.vz, 0); 
xlim([0, t(end)]); xlabel('time, s'); ylabel('elevation, m'); 
title('Velocity Vectors');

figure; plot(t, waves.eta); hold on; plot(t, waves.swl, 'linestyle', '--'); 
hold on; quiver(t, waves.eta + z0, dragForces.x/50, dragForces.z/50, 0); 
xlim([0, t(end)]); xlabel('time, s'); ylabel('elevation, m'); 
title('Force Vectors');

figure; plot(t, dragForces.mag);
xlabel('time, s'); ylabel('force, N'); title('Force Magnitude vs Time');

figure; 
quiver(t, waves.eta + z0, seaParticles.ax, seaParticles.az, 0, 'red'); 
hold on; 
quiver(t, waves.eta + z0, seaParticles.vx, seaParticles.vz, 0, 'blue'); 
xlim([0, t(end)]); xlabel('time, s'); ylabel('elevation, m');
legend('Accelerations', 'Velocities'); 

%comparison(:,1) = particles.vx;
%comparison(:,2) = particles.vz;
%comparison(:,3) = forces.mag;
%comparison(:,4) = forces.theta;

%max(particles.vz)
%find(particles.vz==max(particles.vx))
