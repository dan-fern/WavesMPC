function simulator( t, eta, d, DC, plotData )

dt = t(2) - t(1);

tVis = -5*dt:dt:t(end);
swlVis = zeros(1,numel(tVis));
etaVis = zeros(1,numel(tVis));
start = numel(etaVis) - numel(eta) + 1;
etaVis(start:end) = eta;
if max(eta) == 0
    yLimit = 2.5;
else
    yLimit = eta(eta==max(eta)) + 0.5;
end

writerObj = VideoWriter('PD');
writerObj.FrameRate = 5;
writerObj.Quality = 100;
open(writerObj);

figure('units','normalized','outerposition',[0 0 1 1]);

for i = 1:numel(t)-9
    px = plotData.px(i);
    pz = plotData.pz(i);
    vx = plotData.vx(i);
    vz = plotData.vz(i);
    
    subplot(6,1,1)
    plot( t, eta );
    hold on;
    baseX = [ t(end)+1, t(1)-1 ];
    baseY = [ -yLimit-1, -yLimit-1 ];
    fill([t(1:end), baseX], [eta(1:end), baseY], 'c', 'EdgeColor', 'b');
    hold off;
    line( [t(i),t(i)], [-10,10], 'Color', 'r' );
    titles = strcat('Simulator at t =  ', num2str(tVis(i+5), '%.0f'), ' seconds.');
    title(titles, 'FontSize', 24);
    xlim( [t(1), t(end)] );
    set(gca,'XTick',[]); 
    ylim([ -yLimit, yLimit ]);
    set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);  
    
    subplot(6,1,2)
    plot( tVis(i:i+5),etaVis(i:i+5), '-b', 'LineWidth', 4 ); 
    hold on;  
    plot( tVis(i+5:i+10),etaVis(i+5:i+10), '--b', 'LineWidth', 4 );
    baseX = [ tVis(i+10)+1, tVis(i)-1 ];
    baseY = [ -yLimit-1, -yLimit-1 ];
    fill([tVis(i:i+10), baseX], [etaVis(i:i+10), baseY], 'c', 'EdgeColor', 'None');
    plot( tVis(i:i+10), swlVis(i:i+10), 'LineStyle', '-.' ); 
    hold off;
    line( [tVis(i+5),tVis(i+5)], [-10,10],'LineWidth', 2, 'Color', 'r' );
    %titles = strcat('Simulator at t =  ', num2str(tVis(i+5), '%.0f'), ' seconds.');
    %title(titles, 'FontSize', 24);
    xlim( [tVis(i), tVis(i+10)] );
    set(gca,'XTick',[]); 
    ylim([ -yLimit, yLimit ]);
    ylabel('                   Wave Amplitude, m', 'FontSize', 20);
    set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);  
    
    subplot(6,1,[3,4,5,6])
    plot( DC(1), DC(2), 'xg', 'LineWidth', 1, 'Markers', 20 ); 
    hold on;
    plot( px, pz, 'xg', 'LineWidth', 4, 'Markers', 20 ); 
    quiver( px, pz, vx, vz, '-m', 'AutoScaleFactor', 2, 'LineWidth', 2, ...
        'MaxHeadSize', 2 );
    hold off;
    axis([-10, 10, DC(2)-5, DC(2)+5]); 
    grid on;
    xloc = strcat(' x =  ', num2str(px, '%.2f'), 'm, ');
    zloc = strcat(' z =  ', num2str(pz, '%.2f'), 'm');
    xlabel(strcat('Vehicle Displacement: ', xloc, zloc), 'FontSize', 20); 
    ylabel('Water Depth, m', 'FontSize', 20);
    set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
    set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
    p = get(gca, 'pos');
    p(4) = p(4) + 0.02;
    set(gca, 'pos', p); set(gca,'color','c');
    set(findobj('color','g'),'Color',[0 0.6 0]);
    line( [0,0], [(-1*d),0],'LineWidth', 2, 'Color', 'r' );
    if i ~= 1
        pause(.0005);
    else
        pause(.05);
    end
    hold off;
    writeVideo(writerObj,getframe(gcf));
end
close(writerObj);
return

end