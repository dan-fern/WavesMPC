%%% ghostSim.m 
%%% Daniel Fernández
%%% September 2015
%%% Simulator support function; it takes in all the plot data, DC, time, 
%%% and wave info and plots a visualization of the data.  This is similar
%%% to simulator() except it is standalone, and takes in multiple plots and
%%% superimposes them to track different robots simultaneously.  Originally
%%% intended for it to output three tracks, but simplified to two since the
%%% chart grew cluttered.  There's a decent amount of hardcoding done here 
%%% and could be cleaner. 


clearvars
close all
clc

load('/Users/dee/Documents/MATLAB/WavesMPC/support/workspaces/PD.mat');
robotPD = volturnus;
load('/Users/dee/Documents/MATLAB/WavesMPC/support/workspaces/MPC.mat');
robotMPC = volturnus;
load('/Users/dee/Documents/MATLAB/WavesMPC/support/workspaces/gauss.mat');
robotMPCn = allRobots(:,9);
clear volturnus allRobots controllerOn counter gParticles gWaves i oldInput U wavesOff

dt = t(2) - t(1);
eta = waves.eta;
d = waves.d;

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

writerObj = VideoWriter('ghostFaceKilla');
writerObj.FrameRate = 5;
writerObj.Quality = 100;
open(writerObj);

figure('units','normalized','outerposition',[0 0 1 1]);

for i = 1:numel(t)-9
    pxMPCn = robotMPCn.robotPlots.px(i);
    pzMPCn = robotMPCn.robotPlots.pz(i);
    vxMPCn = robotMPCn.robotPlots.vx(i);
    vzMPCn = robotMPCn.robotPlots.vz(i);
    
    pxMPC = robotMPC.robotPlots.px(i);
    pzMPC = robotMPC.robotPlots.pz(i);
    vxMPC = robotMPC.robotPlots.vx(i);
    vzMPC = robotMPC.robotPlots.vz(i);
    
    pxPD = robotPD.robotPlots.px(i);
    pzPD = robotPD.robotPlots.pz(i);
    vxPD = robotPD.robotPlots.vx(i);
    vzPD = robotPD.robotPlots.vz(i);
    
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
    plot( pxPD, pzPD, 'xr', 'LineWidth', 4, 'Markers', 20 ); 
    quiver( pxPD, pzPD, vxPD, vzPD, '-b', 'AutoScaleFactor', 2, ...
        'LineWidth', 2, 'MaxHeadSize', 2 );
    %plot( pxMPC, pzMPC, 'xg', 'LineWidth', 1, 'Markers', 20 ); 
    %quiver( pxMPC, pzMPC, vxMPC, vzMPC, '--g', 'AutoScaleFactor', 1, ...
     %   'LineWidth', 1, 'MaxHeadSize', 1 );
    plot( pxMPCn, pzMPCn, 'xg', 'LineWidth', 4, 'Markers', 20 ); 
    quiver( pxMPCn, pzMPCn, vxMPCn, vzMPCn, '-m', 'AutoScaleFactor', 2, ...
        'LineWidth', 2, 'MaxHeadSize', 2 );
    hold off;
    axis([-10, 10, DC(2)-5, DC(2)+5]); 
    grid on;
    xloc = strcat(' x =  ', num2str(pxMPCn, '%.2f'), 'm, ');
    zloc = strcat(' z =  ', num2str(pzMPCn, '%.2f'), 'm');
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