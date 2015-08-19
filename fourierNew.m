%% Problem 3 C
% with pre-whitening and post-coloring with the first-difference filter
clc 
clearvars
close all

window_switch = 0;

% Load the data
%load('tempWaveData.mat');


%y = awacs.heave(4,:);
%time1 = 0.5:0.5:numel(y)/2; time1(1) = 0.5;
%time2 = 0.5:0.5:numel(y)/2; time2(1) = 0.5;
time1 = 1:0.1:10;
y = 1.2 * cos( 20 * time1 + pi/2 );
figure
plot(time1, y)
N = length(y);
%%
if window_switch == 1;
    y_2 = y;
else
    y_2 = y;
end

% window the data with a bartlett data window
if window_switch == 1;
    y = bartlett(N).*y';
    y_3 = y;
end


% Remove the sample mean.
y = y-mean(y);

% Plot the original timeseries
figure(1)
plot(time1,y,'k');hold on
xlabel('Days since 11/15/1958'); ylabel('Diff CO2 conc. (ppm)')
title('CO2 concentration - First Difference','FontWeight','bold')

% Problem variables
N = length(y);
dt = 0.5;               % sec

% Nyquist Frequency
f_nyq = 1/(2*dt);

% Fourier Frequencies
fj = ftt_freq(N,dt);
df = fj(2)-fj(1);

% Use a FFT routine to compute the discrete Fourier Transform
Yj = fft(y,N)/N;

% Shift the frequencies
Yj = fftshift(Yj);
fj = fftshift(fj);

% "Boost" the estimates to account for reduction of variance from triangle
% tapering
if window_switch == 1;
    pre_var = var(y_2);
    post_var = var(y_3);

    Yj = Yj*(pre_var/post_var)^(.5);
end

index = fj >= 0;
fj = fj(index);
Yj = Yj(index);

amp = 2*abs(Yj);

Phase = atan((imag(Yj)./real(Yj)));

%Recreate the timeseries
eta = zeros(size(time1));
for i = 1:numel(Yj)   
    eta = eta + amp(i) * cos(2*pi*fj(i)*time1 +phase(i));
end

figure(2)
plot(time1,y,'k');hold on
plot(time1,eta,'r')

asd

% Calculate the 2-sided sample estimates of the power spectral density by
% the Cooley-Turkey Method
Sj = real(N*dt*conj(Yj).*Yj);

% Turn this into a 1 sided estimate
Sj = Sj(fj >= 0)*2;
fj = fj(fj>= 0);

% Band Average the PSD estimates
M = 50;
[Sj_filt,fj_filt] = PSD_BandAve(Sj,fj,M);
df_filt = fj_filt(2) - fj_filt(1);

% Get the confidence intervals
CI = 95;
S = 10^4;
bnds = fft_CI(S,M,CI);

% Post color the estimates
Sj_PC = Sj_filt./(4*sin(pi*fj_filt*dt).^2);


% Plot the results
fig2 = figure(2);
plot(fj_filt,Sj_PC,'k'); hold on

% plot a straight line with a slope of -2, which corresponds to an f^92
% curve in these log-log plots
plot([10^-5 10^0] ,[10^2 10^-6],'k:')

% Plot the error bars
errorbar(10^-3,S,bnds(1),bnds(2),'ko','markerfacecolor','k');
axis([10^-5 10^0 10^-5 10^7])
ylabel('PSD (ppm^2/cpd)');xlabel('Frequency (cycles/day)')
ax = get(fig2,'CurrentAxes');
set(ax,'XScale','log','YScale','log')
title('Power Spectral Density - CO2 Concentration','FontWeight','bold')
grid on
legend('Rectangle Window','Bartlet Window','Pre-Whitening','f^-^2 roll off','location','SouthWest')


%% Calculate the amplitudes
fj_filt = awacs.freqCalc(4, :);
fj_filt = fj_filt(4:end);
Sj_PC = awacs.specCalc(4, :);
Sj_PC = Sj_PC(4:end);

%idx = find(awacs.freqCalc(4,:) > 0.005);

%fj_filt = fj_filt(4:end);
%Sj_PC = Sj_PC(4:end);

var = df_filt.*Sj_PC;
eta = zeros(1, numel(time1));
H = 2 .* sqrt(2*var);
T = 1 ./ fj_filt;
g = 9.81; x = 0; d = awacs.meanWaterDepth(4);
% for i = 
%     w = 2 .* pi ./ T;
%     L = 9.81 .* T.^2 .* (tanh(w.^2 * awacs.meanWaterDepth(4) / 9.81).^(3/4)).^(2/3) ./ (2 * pi);
%     k = 2 .* pi ./ L;
%     eta = eta + H ./ 2 .* cos(k - w .* time);
%     
for i = 1:numel(T)
    w = 2 * pi / T(i);
    L = g * T(i)^2 * (tanh(w^2 * d / g)^(3/4))^(2/3) / (2 * pi);
    k = 2 * pi / L;
    eta = eta + H(i) / 2 * cos(k*x - w*time1);
end

figure;
plot(time1(1:500), y_2(1:500), '-b'); hold on; plot(time1(1:500), eta(1:500), '-r');
legend('Buoy Heave Data', 'Fourier Reconstruction'); 