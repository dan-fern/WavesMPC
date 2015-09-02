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

%% inputChecks
figure('units','normalized','outerposition',[0 0 1 1]);
set(findobj('color','g'),'Color',[0 0.6 0]);
subplot(5,1,1)
plot( t, waves.eta, '-b', 'LineWidth', 1 )
hold on;
baseX = [ t(end)+1, t(1)-1 ];
baseY = [ -4, -4 ];
fill([t(1:end), baseX], [waves.eta(1:end), baseY], 'c', 'EdgeColor', 'b');
%xlabel('Time, s', 'FontSize', 20); 
ylabel({'Wave';'Amplitude, m'}, 'FontSize', 20);
xlim([t(1), t(end)]); ylim([-3, 3]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
hold off;
title('Thruster Inputs over Time')

subplot(5,1,[2,3])
plot(t, volturnus.robotPlots.uX, '-r', 'LineWidth', 2);
xlim([t(1), t(end)]); ylim([-1, 1]);
ylabel('Percent Thrust, X-Axis');
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
%title('X-Axis Motor Inputs');

subplot(5,1,[4,5])
plot(t, volturnus.robotPlots.uZ, '-k', 'LineWidth', 2);
xlim([t(1), t(end)]); ylim([-1, 1]);
xlabel('Time, s'); ylabel('Percent Thrust, Z-Axis');
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
%title('Z-Axis Motor Inputs');


%% compCharts

clc
clear variables
close all

load('PDX')
pdErrors = volturnus.errors;
pdErrorPlots = volturnus.errorPlots;
n2 = numel(t);
load('drift')
driftErrors = volturnus.errors;
driftErrorPlots = volturnus.errorPlots;
n1 = numel(t);
load('MPC')
mpcErrors = volturnus.errors;
mpcErrorPlots = volturnus.errorPlots;
n3 = numel(t);

tempPD = [ pdErrorPlots.pErrorX; pdErrorPlots.pErrorZ ]; 
tempDrift = [ driftErrorPlots.pErrorX; driftErrorPlots.pErrorZ ]; 
tempMPC = [ mpcErrorPlots.pErrorX; mpcErrorPlots.pErrorZ ]; 
stop = numel(time.t) - time.tSteps;
figure('units','normalized','outerposition',[0 0 1 1]);
set(findobj('color','g'),'Color',[0 0.6 0]);

subplot(5,1,1)
plot( t(1:stop), waves.eta(1:stop), '-b', 'LineWidth', 1 )
hold on;
baseX = [ t(stop)+1, t(1)-1 ];
baseY = [ -4, -4 ];
fill([t(1:end), baseX], [waves.eta(1:end), baseY], 'c', 'EdgeColor', 'b');
hold off;
%xlabel('Time, s', 'FontSize', 20); 
ylabel({'Wave';'Amplitude, m'}, 'FontSize', 20);
xlim([t(1), t(stop)]); ylim([-3, 3]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Wave Height Time Series')

subplot(5,1,2)
plot( t(1:stop), tempPD(1,1:stop), 'b', 'LineWidth', 1 ); 
line( [t(1),t(stop)], [0,0],'LineWidth', 1, 'Color', 'r' );
ylabel('Error, m', 'FontSize', 20);
xlim([t(1), t(stop)]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Feedback Controller, global x');

subplot(5,1,3)
plot( t(1:stop), tempPD(2,1:stop), 'b', 'LineWidth', 1 );
line( [t(1),t(stop)], [0,0],'LineWidth', 1, 'Color', 'r' );
ylabel('Error, m', 'FontSize', 20);
xlim([t(1), t(stop)]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Feedback Controller, global z');

subplot(5,1,4)
plot( t(1:stop), tempMPC(1,1:stop), 'b', 'LineWidth', 1 );
line( [t(1),t(stop)], [0,0],'LineWidth', 1, 'Color', 'r' );
ylabel('Error, m', 'FontSize', 20);
xlim([t(1), t(stop)]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Model Predictive Controller, global x');

subplot(5,1,5)
plot( t(1:stop), tempMPC(2,1:stop), 'b', 'LineWidth', 1 );
line( [t(1),t(stop)], [0,0],'LineWidth', 1, 'Color', 'r' );
ylabel('Error, m', 'FontSize', 20); xlabel('Time, s')
xlim([t(1), t(stop)]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Model Predictive Controller, global z');

ERRORS = [driftErrors.tErrorX, driftErrors.tErrorZ;
    pdErrors.tErrorX, pdErrors.tErrorZ;
    mpcErrors.tErrorX, mpcErrors.tErrorZ];

sqrt( ERRORS(1)^2 + ERRORS(2)^2 )
sqrt( ERRORS(3)^2 + ERRORS(4)^2 )
sqrt( ERRORS(5)^2 + ERRORS(6)^2 )

RMS1 = sqrt( 1/n1 * (sqrt( ERRORS(1)^2 + ERRORS(4)^2 ))^2 );
RMS2 = sqrt( 1/n2 * (sqrt( ERRORS(2)^2 + ERRORS(5)^2 ))^2 );
RMS3 = sqrt( 1/n3 * (sqrt( ERRORS(3)^2 + ERRORS(6)^2 ))^2 );

figure('units','normalized','outerposition',[0 0 1 0.8]);
bar([RMS1, RMS2, RMS3]);
ylabel('RMS Error')
set(gca, 'YScale', 'log');
str1 = ['Drifting, Error = ', num2str(RMS1, '%.3f'), ' m'];
str2 = ['Feedback, Error = ', num2str(RMS2, '%.3f'), ' m'];
str3 = ['MPC, Error = ', num2str(RMS3, '%.3f'), ' m'];
set(gca,'XTickLabel',{str1, str2, str3},'fontsize',20);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',20);
title('RMS Error Compared')


%% fig1

clear variables
close all
clc

waves.d = 50;
waves.T = 8.0107;
waves.H = 2;
waves.E = -pi/2;
waves.theta = 0;
waves.rho = 1030;
t = linspace(0,waves.T,21);
x = 0;
z2 = -2;
z4 = -4;
z6 = -6;
z8 = -8;
z10 = -10;
Set = [2,4,6,8,10,12,14,16,18,20];
xAxis = linspace(0,100, 21);

waves.swl = zeros(1, numel(t)); %still water line

[ z2Particles, waves ] = getSeaStateParticles( t, x, z2, waves );
[ z4Particles, waves ] = getSeaStateParticles( t, x, z4, waves );
[ z6Particles, waves ] = getSeaStateParticles( t, x, z6, waves );
[ z8Particles, waves ] = getSeaStateParticles( t, x, z8, waves );
[ z10Particles, waves ] = getSeaStateParticles( t, x, z10, waves );



figure('units','normalized','outerposition',[0 0 1 0.6]);
hold on;
plot(xAxis, waves.eta);  
plot(xAxis, waves.swl, 'linestyle', '--');
baseX = [ xAxis(end)+1, xAxis(1)-1 ];
baseY = [ -15, -15 ];
fill([xAxis(1:end), baseX], [waves.eta(1:end), baseY], 'c', 'EdgeColor', 'None');  
plot(xAxis, waves.swl, 'linestyle', '--');
for i=1:numel(Set)
    quiver(xAxis(Set(i)), z2, 5*z2Particles.vx(Set(i)), 2*z2Particles.vz(Set(i)), ...
        0, '-r', 'AutoScaleFactor', 10, 'LineWidth', 2, 'MaxHeadSize', 3); 
    quiver(xAxis(Set(i)), z4, 5*z4Particles.vx(Set(i)), 2*z4Particles.vz(Set(i)), ...
        0, '-r', 'AutoScaleFactor', 10, 'LineWidth', 2, 'MaxHeadSize', 3); 
    quiver(xAxis(Set(i)), z6, 5*z6Particles.vx(Set(i)), 2*z6Particles.vz(Set(i)), ...
        0, '-r', 'AutoScaleFactor', 10, 'LineWidth', 2, 'MaxHeadSize', 3); 
    quiver(xAxis(Set(i)), z8, 5*z8Particles.vx(Set(i)), 2*z8Particles.vz(Set(i)), ...
        0, '-r', 'AutoScaleFactor', 10, 'LineWidth', 2, 'MaxHeadSize', 3); 
    quiver(xAxis(Set(i)), z10, 5*z10Particles.vx(Set(i)), 2*z10Particles.vz(Set(i)), ...
        0, '-r', 'AutoScaleFactor', 10, 'LineWidth', 2, 'MaxHeadSize', 3); 
end
hold off;
xlim([0, xAxis(end)]); xlabel('<--------- Direction of Wave Propagation <---------', 'fontsize', 20); 
set(gca,'XTick',[]);
ylim([-12,2]); ylabel('Water Depth, m');
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',20); 
title('Flow Velocity Vectors beneath a Monochromatic Wave, L = 100m', 'FontSize', 24);

%% RMS error for best horizon

clc
clear variables
close all

load('horizon_1s')
tErrorX(1) = volturnus.errors.tErrorX;
tErrorZ(1) = volturnus.errors.tErrorX;
tCalc(1) = time.tCalc;
n(1) = numel(time.t);

load('horizon_2s')
tErrorX(2) = volturnus.errors.tErrorX;
tErrorZ(2) = volturnus.errors.tErrorX;
tCalc(2) = time.tCalc;
n(2) = numel(time.t);

load('horizon_4s')
tErrorX(3) = volturnus.errors.tErrorX;
tErrorZ(3) = volturnus.errors.tErrorX;
tCalc(3) = time.tCalc;
n(3) = numel(time.t);

load('horizon_5s')
tErrorX(4) = volturnus.errors.tErrorX;
tErrorZ(4) = volturnus.errors.tErrorX;
tCalc(4) = time.tCalc;
n(4) = numel(time.t);

load('horizon_8s')
tErrorX(5) = volturnus.errors.tErrorX;
tErrorZ(5) = volturnus.errors.tErrorX;
tCalc(5) = time.tCalc;
n(5) = numel(time.t);

load('horizon_10s')
tErrorX(6) = volturnus.errors.tErrorX;
tErrorZ(6) = volturnus.errors.tErrorX;
tCalc(6) = time.tCalc;
n(6) = numel(time.t);

load('horizon_15s')
tErrorX(7) = volturnus.errors.tErrorX;
tErrorZ(7) = volturnus.errors.tErrorX;
tCalc(7) = time.tCalc;
n(7) = numel(time.t);

clearvars -except tErrorX tErrorZ tCalc n

for i = 1:numel(tCalc)
    RMS1(i) = sqrt( sqrt( 1/n(i) * tErrorX(i)^2 ) + sqrt( 1/n(i) * tErrorZ(i)^2 ) );
    RMS2(i) = sqrt( 1/n(i) * sqrt( tErrorX(i)^2 + tErrorZ(i)^2 )^2 );
end


