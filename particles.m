%%% particles.m 
%%% Daniel Fernández
%%% June 2015
%%% takes in sea state and spits out summed particle velocities,
%%% accelerations and sea state.

function [ particles, eta ] = particles( d, t, x, z, theta, H, T )

g = 9.81; 
vx = zeros(1,numel(t)); vy = zeros(1,numel(t)); vz = zeros(1,numel(t));
ax = zeros(1,numel(t)); ay = zeros(1,numel(t)); az = zeros(1,numel(t));
eta = zeros(1, numel(t));

for i = 1:numel(T)
    w = 2 * pi / T(i);
    L = g * T(i)^2 * (tanh(w^2 * d / g)^(3/4))^(2/3) / (2 * pi);
    k = 2 * pi / L;
    eta = eta + H(i) / 2 * cos(k*x - w*t);
    if d / L > 0.5
        %deep
        if d < L / 2
            vx = vx + cosd(theta) * H(i) * w / 2 * exp(k*z) ...
                * cos(k*x - w*t);
            vy = vy + sind(theta) * H(i) * w / 2 * exp(k*z) ...
                * cos(k*x - w*t);
            vz = vz + H(i) * w / 2 * exp(k*z) * sin(k*x - w*t);
            ax = ax + cosd(theta) * 2 * H(i) * (w/2)^2 * exp(k*z) ...
                * sin(k*x - w*t);
            ay = ay + sind(theta) * 2 * H(i) * (w/2)^2 * exp(k*z) ...
                * sin(k*x - w*t);
            az = az + -2 * H(i) * (w/2)^2 * exp(k*z) * cos(k*x - w*t);
        else
            continue;
        end
    elseif d / L > 0.05
        %intermediate
        if d < L / 2
            vx = vx + cosd(theta) * (g * pi * H(i) * cosh(2*pi*(z+d)/L) ...
                * cos(k*x - w*t) / (w * L * cosh(2*pi*d/L)));
            vy = vy + sind(theta) * (g * pi * H(i) * cosh(2*pi*(z+d)/L) ...
                * cos(k*x - w*t) / (w * L * cosh(2*pi*d/L)));
            vz = vz + g * pi * H(i) * sinh(2*pi*(z+d)/L) * ...
                sin(k*x - w*t) / (w * L * cosh(2*pi*d/L));
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
        %shallow
        vx = vx + cosd(theta) * H(i) / 2 * sqrt(g/d) * cos(k*x - w*t);
        vy = vy + sind(theta) * H(i) / 2 * sqrt(g/d) * cos(k*x - w*t);
        vz = vz + H(i) * w / 2 * (1 + z/d) * sin(k*x - w*t);
        ax = ax + cosd(theta) * H(i) * w * sqrt(g/d) / 2 * sin(k*x - w*t);
        ay = ay + sind(theta) * H(i) * w * sqrt(g/d) / 2 * sin(k*x - w*t);
        az = az + -2 * H(i) * (w/2)^2 * (1 + z/d) * cos(k*x - w*t);
    end
end

particles.vx = vx; particles.vy = vy; particles.vz = vz;
particles.ax = ax; particles.ay = ay; particles.az = az;

end