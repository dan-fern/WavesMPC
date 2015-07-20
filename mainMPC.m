% waves.m
clear all
close all
home

IC = [0, -20, 0, 0, 0, 0]; %all initial conditions, pos, vel, acc (x and z)

d = 50; t = 0.5:0.5:100; x = IC(1); z = IC(2); theta = 0; rho = 1030;
length = 0.7; width = 0.4; height = 0.4;

swl = zeros(1, numel(t));
T = [10, 8, 12, 11, 6];
H = [1.8, 1, 2.2, 2, 0.4];
E = [pi/2, pi/4, 3*pi/8, 3*pi/2, pi/16];

[ particles, eta ] = getParticles( d, t, x, z, theta, H, T, E );
[ forces ] = getForces( particles, rho, length, width, height, t );

%%

figure; plot(t, eta); xlabel('time, s'); ylabel('elevation, m');

figure; plot(t, eta); hold on; plot(t, swl, 'linestyle', '--'); hold on;
quiver(t, eta + z, particles.ax, particles.az, 0); hold on;
xlabel('time, s'); ylabel('elevation, m'); title('Acceleration Vectors');

figure; plot(t, eta); hold on; plot(t, swl, 'linestyle', '--'); hold on;
quiver(t, eta + z, particles.vx, particles.vz, 0); xlim([0, t(end)]);
xlabel('time, s'); ylabel('elevation, m'); title('Velocity Vectors');

figure; plot(t, eta); hold on; plot(t, swl, 'linestyle', '--'); hold on;
quiver(t, eta + z, forces.x/50, forces.z/50, 0); xlim([0, t(end)]);
xlabel('time, s'); ylabel('elevation, m'); title('Force Vectors');

figure; plot(t, forces.mag);
xlabel('time, s'); ylabel('force, N'); title('Force Magnitude vs Time');

figure; quiver(t, eta + z, particles.ax, particles.az, 0, 'red'); hold on;
quiver(t, eta + z, particles.vx, particles.vz, 0, 'blue'); xlim([0, t(end)]);
legend('Accelerations', 'Velocities'); xlabel('time, s'); ylabel('elevation, m');

%comparison(:,1) = particles.vx;
%comparison(:,2) = particles.vz;
%comparison(:,3) = forces.mag;
%comparison(:,4) = forces.theta;

%max(particles.vz)
%find(particles.vz==max(particles.vx))

%% simulator
close all
figure('units','normalized','outerposition',[0 0 1 1]);
x = IC(1); z = IC(2); vx = IC(3); vz = IC(4); dt = t(2) - t(1);
for i = 6:numel(t)-5
    x = x + particles.vx(i) * dt;
    z = z + particles.vz(i) * dt;
    subplot(4,1,1)
    plot(t(i-5:i),eta(i-5:i), '-b', 'LineWidth', 4); hold on;
    plot(t(i:i+5),eta(i:i+5), '--b', 'LineWidth', 4);
    set(gca,'XTick',[]); ylabel('Wave Amplitude, m')
    ylim([(-1 * eta(eta==max(eta))) - 0.5, eta(eta==max(eta)) + 0.5]);
    hold on; plot(t(i-5:i+5), swl(i-5:i+5), 'LineStyle', '-.'); hold off;
    line([t(i),t(i)], [-10,10],'LineWidth', 2, 'Color', 'r');
    titles = strcat('Simulator at t =  ', num2str(t(i), '%.0f'), ' seconds.');
    title(titles, 'FontSize', 24);
    set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
    subplot(4,1,[2,3,4])
    plot(IC(1), IC(2), 'xb', 'LineWidth', 1, 'Markers', 20); hold on;
    plot(x,z,'xb', 'LineWidth', 4, 'Markers', 20); hold on;
    quiver(x, z, particles.vx(i), particles.vz(i), '-g', ...
        'AutoScaleFactor', 2, 'LineWidth', 2, 'MaxHeadSize', 2);
    axis([-10, 10, IC(2)-10, IC(2)+10]); grid on;
    xloc = strcat(' x =  ', num2str(x, '%.2f'), 'm, ');
    zloc = strcat(' z =  ', num2str(z, '%.2f'), 'm');
    xlabel(strcat('Vehicle Displacement: ', xloc, zloc), 'FontSize', 20); 
    ylabel('Water Depth, m', 'FontSize', 20);
    set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
    set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
    p = get(gca, 'pos');
    p(4) = p(4) + 0.04;
    set(gca, 'pos', p);
    line([0,0], [(-1*d),0],'LineWidth', 2, 'Color', 'r');
    pause(.01); hold off;
    [ particles ] = getParticles( d, t, x, z, theta, H, T, E );
end