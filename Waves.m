%%% waves.m -DF
%% 1
nx = 101; xmin = 0; xmax = 100; x = linspace(xmin,xmax,nx); 
ny =  51; ymin = 0; ymax =  50; y = linspace(ymin,ymax,ny);
wind_data.U = 10; wind_data.thetaU = 0; wind_data.X = 1e6;   
[s,Tp,fm,B,Sk,kx,ky] = sea_surface(x,y,wind_data,'PM','none');
figure(1)
subplot(211),mesh(x,y,s),ylabel('y(m)'),xlabel('x(m)') 
subplot(212),mesh(kx,ky,Sk),ylabel('ky (1/m)'),xlabel('kx (1/m)') 
[s,Tp,fm,B,Sk,kx,ky] = sea_surface(x,y,wind_data,'PM','cos2');
figure(2)
subplot(211),mesh(x,y,s),ylabel('y(m)'),xlabel('x(m)') 
subplot(212),mesh(kx,ky,Sk),ylabel('ky (1/m)'),xlabel('kx (1/m)') 
[s,Tp,fm,B,Sk,kx,ky] = sea_surface(x,y,wind_data,'PM','mits');
figure(3)
subplot(211),mesh(x,y,s),ylabel('y(m)'),xlabel('x(m)') 
subplot(212),mesh(kx,ky,Sk),ylabel('ky (1/m)'),xlabel('kx (1/m)') 
[s,Tp,fm,B,Sk,kx,ky] = sea_surface(x,y,wind_data,'PM','hass');
figure(4)
subplot(211),mesh(x,y,s),ylabel('y(m)'),xlabel('x(m)') 
subplot(212),mesh(kx,ky,Sk),ylabel('ky (1/m)'),xlabel('kx (1/m)') 

%% 2
close all
clear all

d = 50; g = 9.81; x = 0; y = 0; z = 20; t = 1:100; theta = 0;
T = [10, 8, 12, 11, 6];
H = [2.3, 1.1, 3, 2, 0.4];
ax = zeros(1,numel(t)); ay = zeros(1,numel(t)); az = zeros(1,numel(t));

for i = 1:numel(T)
    w = 2 * pi / T(i);
    L = g * T(i)^2 * (tanh(w^2 * d / g)^(3/4))^(2/3) / (2 * pi);
    k = 2 * pi / L;
    eta = H(i) / 2 * cos(k*x - w*t);
    if d / L > 0.5
        if d < L / 2
            ax = ax + cosd(theta) * -2 * H(i) * (w/2)^2 * exp(k*z) * sin(k*x - w*t);
            ay = ay + sind(theta) * -2 * H(i) * (w/2)^2 * exp(k*z) * sin(k*x - w*t);
            az = az + -2 * H(i) * (w/2)^2 * exp(k*z) * cos(k*x - w*t);
        else
            continue;
        end
    elseif d / L > 0.05
        if d < L / 2
            ax = ax + cosd(theta) * (g * pi * H(i) * cosh(2*pi*(z+d)/L) * sin(k*x - w*t) / (L * cosh(2*pi*d/L)));
            ay = ay + sind(theta) * (g * pi * H(i) * cosh(2*pi*(z+d)/L) * sin(k*x - w*t) / (L * cosh(2*pi*d/L)));
            az = az + -g * pi * H(i) * sinh(2*pi*(z+d)/L) * cos(k*x - w*t) / (L * cosh(2*pi*d/L));
        else
            continue;
        end
    else
        ax = ax + cosd(theta) * H(i) * w * sqrt(g/d) / 2 * sin(k*x - w*t);
        ay = ay + sind(theta) * H(i) * w * sqrt(g/d) / 2 * sin(k*x - w*t);
        az = az + -2 * H(i) * (w/2)^2 * (1 + z/d) * cos(k*x - w*t);
    end
end
%%
figure; plot(t, eta);
figure; plot(t, ax);
figure; plot(t, az);
figure; plot(t, eta); hold on; quiver(t, eta - 20, ax, az);

%% 3
close all
clear all

