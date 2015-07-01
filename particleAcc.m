%%% particleAcc.m 
%%% Daniel Fernández
%%% June 2015
%%% takes in sea state and spits out summed particle accelerations.

function [ ax, ay, az, eta ] = particleAcc( d, t, x, z, theta, H, T )

g = 9.81; 
ax = zeros(1,numel(t)); ay = zeros(1,numel(t)); az = zeros(1,numel(t));
eta = zeros(1, numel(t));

for i = 1:numel(T)
    w = 2 * pi / T(i);
    L = g * T(i)^2 * (tanh(w^2 * d / g)^(3/4))^(2/3) / (2 * pi);
    k = 2 * pi / L;
    eta = eta + H(i) / 2 * cos(k*x - w*t);
    if d / L > 0.5
        if d < L / 2
            ax = ax + cosd(theta) * 2 * H(i) * (w/2)^2 * exp(k*z) ...
                * sin(k*x - w*t);
            ay = ay + sind(theta) * 2 * H(i) * (w/2)^2 * exp(k*z) ...
                * sin(k*x - w*t);
            az = az + -2 * H(i) * (w/2)^2 * exp(k*z) * cos(k*x - w*t);
        else
            continue;
        end
    elseif d / L > 0.05
        if d < L / 2
            ax = ax + cosd(theta) * (g * pi * H(i) * cosh(2*pi*(z+d)/L) ...
                * sin(k*x - w*t) / (L * cosh(2*pi*d/L)));
            ay = ay + sind(theta) * (g * pi * H(i) * cosh(2*pi*(z+d)/L) ...
                * sin(k*x - w*t) / (L * cosh(2*pi*d/L)));
            az = az + -g * pi * H(i) * sinh(2*pi*(z+d)/L) * ...
                cos(k*x - w*t) / (L * cosh(2*pi*d/L));
        else
            continue;
        end
    else
        ax = ax + cosd(theta) * H(i) * w * sqrt(g/d) / 2 * sin(k*x - w*t);
        ay = ay + sind(theta) * H(i) * w * sqrt(g/d) / 2 * sin(k*x - w*t);
        az = az + -2 * H(i) * (w/2)^2 * (1 + z/d) * cos(k*x - w*t);
    end
end
