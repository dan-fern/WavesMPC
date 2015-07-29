function simulator2( t, eta, d, IC, plotData )

figure('units','normalized','outerposition',[0 0 1 1]);
%x = IC(1); z = IC(2); vx = IC(3); vz = IC(4); 
%dt = t(2) - t(1);
tVis = -2.5:0.5:t(end);
etaVis = zeros(1,numel(tVis));
start = numel(etaVis) - numel(eta) + 1;
etaVis(start:end) = eta;
swlVis = zeros(1,numel(tVis));

for i = 1:numel(t)-9
    %x = x + particles.vx(i) * dt;
    %z = z + particles.vz(i) * dt;
    px = plotData.px(i);
    pz = plotData.pz(i);
    vx = plotData.vx(i);
    vz = plotData.vz(i);
    
    subplot(4,1,1)
    plot(tVis(i:i+5),etaVis(i:i+5), '-b', 'LineWidth', 4); 
    hold on;
    plot(tVis(i+5:i+10),etaVis(i+5:i+10), '--b', 'LineWidth', 4);
    set(gca,'XTick',[]); 
    ylabel('Wave Amplitude, m');
    ylim([(-1 * eta(eta==max(eta))) - 0.5, eta(eta==max(eta)) + 0.5]);
    hold on; 
    plot(tVis(i:i+10), swlVis(i:i+10), 'LineStyle', '-.'); 
    hold off;
    line([tVis(i+5),tVis(i+5)], [-10,10],'LineWidth', 2, 'Color', 'r');
    titles = strcat('Simulator at t =  ', num2str(tVis(i+5), '%.0f'), ' seconds.');
    title(titles, 'FontSize', 24);
    set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);  
    
    subplot(4,1,[2,3,4])
    plot(IC(1), IC(2), 'xb', 'LineWidth', 1, 'Markers', 20); 
    hold on;
    plot(px,pz,'xb', 'LineWidth', 4, 'Markers', 20); 
    hold on;
    quiver(px, pz, vx, vz, '-g', 'AutoScaleFactor', 2, 'LineWidth', 2, ...
        'MaxHeadSize', 2);
    axis([-10, 10, IC(2)-10, IC(2)+10]); 
    grid on;
    xloc = strcat(' x =  ', num2str(px, '%.2f'), 'm, ');
    zloc = strcat(' z =  ', num2str(pz, '%.2f'), 'm');
    xlabel(strcat('Vehicle Displacement: ', xloc, zloc), 'FontSize', 20); 
    ylabel('Water Depth, m', 'FontSize', 20);
    set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
    set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
    p = get(gca, 'pos');
    p(4) = p(4) + 0.04;
    set(gca, 'pos', p);
    line([0,0], [(-1*d),0],'LineWidth', 2, 'Color', 'r');
    if i == 1
        pause(5);
    else
        pause(.05); 
    end
    hold off;
    %[ particles ] = getParticles( d, t, x, z, theta, H, T, E );
end

return

end