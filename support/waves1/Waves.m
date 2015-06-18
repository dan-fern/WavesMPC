%%% Waves.m
%%% Daniel Fernández
%%% 27 November 2013
%%% Waves.m is broken into two blocks.  Block 1 serves to test the error
%%% from the created dispersion solver function 'wavenumber.m'.  It creates
%%% a given array for kh and performs an error check against the calculated
%%% values over the same domain.  The error is found to be < 0.0000003%. 
%%% Block 2 is the creates a wave model and went through several
%%% iterations.  At first, several blocks were presented with standalone
%%% calculations.  In the end, I decided to only report the bare minimum to
%%% make the desired 1-D wave transformation model.  It asks for a
%%% user-inputted value for g, and then maps the depth profile.  After
%%% that, using 4 separate scenarios, 4 sets of wavenumbers, wave angles,
%%% and wave heights are calculated and plotted.  Below that, breaking
%%% criteria is incorporated to the 2nd scenario to show the surf zone.
%%% also included: wavenumber.m, waveheight.m, waveangle.m

%%  Block 1 - Error Calculation using Dispersion Solver
clear all
close all
home

kh = (.01:.01:4); 
h = zeros(1,length(kh)); kcal = zeros(1,length(kh)); E = zeros(1,length(kh));
g = 9.81; T = 8;  % all necessary initialization
sig = 2 * pi / T;
L0 = g * T .^2 / 2 / pi;
k0 = 2 * pi / L0;
for i = 1:length(kh)
    h(i) = kh(i) * tanh(kh(i)) * g / sig.^2;
    kcal(i) = wavenumber(h(i),k0);
    E(i) = (1 - (kcal(i) * h(i)) / kh(i)) * 100; % populates error array
end
figure (1)
plot(kh,E,'-r');
xlabel('kh_t_r_u_e'); ylabel('Percent Error, %'); axis tight;
title('Error Calculation for Wavenumber Solver');

%%  Block 2 - Wave Dispersion Model
clear all
close all
home

prompt = 'Input Gravitational Constant: ';
g = input(prompt);

xAxis = (1:1:210);  % all necessary initializations
h = zeros(1,length(xAxis));
kh = zeros(4,length(xAxis));
kays = zeros(4,length(xAxis)); 
angles = zeros(4,length(xAxis)); 
heights = zeros(4,length(xAxis));
conditions = [4,0;4,45;12,0;12,45];  % 4 total initial conditions

i = 1;  % below creates depth profile
while i <= length(xAxis)
    if i < 61
        h(i) = 1/30 * xAxis(i);
    else 
        h(i) = 1/15 * xAxis(i);
    end
    i = i + 1;
end

H0 = 1; 
for j = 1:4
    T = conditions(j,1); theta0 = conditions(j,2);  % setup
    C0 = g * T / 2 / pi; 
    L0 = g * T .^2 / 2 / pi; 
    k0 = 2 * pi / L0;
    for i = 1:length(xAxis)  %  populates k, theta, H, and kh
        kays(j,i) = wavenumber(h(i),k0);
        angles(j,i) = waveangle(kays(j,i),T,theta0,C0);
        heights(j,i) = waveheight(theta0,angles(j,i),H0,C0,h(i),kays(j,i),T);
        kh(j,i) = kays(j,i) * h(i);
    end
end

figureHandle = figure('Position',[125,155,800,600]);
figure(1)
subplot(3,1,1)
plot(xAxis,heights)
axis tight; xlabel('Distance from Shoreline'); ylabel('Wave Height'); 
legend('IC: T = 4; \theta = 0', 'IC: T = 4; \theta = 45', ...
    'IC: T = 12; \theta = 0', 'IC: T = 12; \theta = 45');
subplot(3,1,2)
plot(kh(1,:),heights);
axis tight; xlabel('kh'); ylabel('Wave Height'); 
subplot(3,1,3)
plot(xAxis,angles)
axis tight; xlabel('Distance from Shoreline'); ylabel('Wave Angle'); 

Htrue = heights(2,:);  % uses a new variable to maintain height variable
val = 0.78;
Hb = val .* h;  % breaking criterion
index = find(Hb < Htrue);
Htrue(index) = Hb(index); 
figure(2)
plot(xAxis,Htrue)
title('Wave Height Model with Breaking Criterion, IC: T = 4, \theta = 45');
axis([0 210 0 1]); xlabel('Distance from Shoreline'); ylabel('Wave Height');