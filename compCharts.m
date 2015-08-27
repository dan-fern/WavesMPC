clear variables
close all

load('PD')
pdErrors = volturnus.errors;
pdErrorPlots = volturnus.errorPlots;
load('drift')
driftErrors = volturnus.errors;
driftErrorPlots = volturnus.errorPlots;
load('MPC')
mpcErrors = volturnus.errors;
mpcErrorPlots = volturnus.errorPlots;

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
ylabel({'Position';'Error, m'}, 'FontSize', 20);
xlim([t(1), t(stop)]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Feedback Controller, global x');

subplot(5,1,3)
plot( t(1:stop), tempPD(2,1:stop), 'b', 'LineWidth', 1 );
line( [t(1),t(stop)], [0,0],'LineWidth', 1, 'Color', 'r' );
ylabel({'Position';'Error, m'}, 'FontSize', 20);
xlim([t(1), t(stop)]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Feedback Controller, global z');

subplot(5,1,4)
plot( t(1:stop), tempMPC(1,1:stop), 'b', 'LineWidth', 1 );
line( [t(1),t(stop)], [0,0],'LineWidth', 1, 'Color', 'r' );
ylabel({'Position';'Error, m'}, 'FontSize', 20);
xlim([t(1), t(stop)]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Model Predictive Controller, global x');

subplot(5,1,5)
plot( t(1:stop), tempMPC(2,1:stop), 'b', 'LineWidth', 1 );
line( [t(1),t(stop)], [0,0],'LineWidth', 1, 'Color', 'r' );
ylabel({'Position';'Error, m'}, 'FontSize', 20); xlabel('Time, s')
xlim([t(1), t(stop)]);
set(gca,'XTickLabel',get(gca,'XTickLabel'),'fontsize',16);
set(gca,'YTickLabel',get(gca,'YTickLabel'),'fontsize',16);
title('Model Predictive Controller, global z');

ERRORS = [driftErrors.tErrorX, driftErrors.tErrorZ;
    pdErrors.tErrorX, pdErrors.tErrorZ;
    mpcErrors.tErrorX, mpcErrors.tErrorZ];
