%%% particleVel.m 
%%% Daniel Fernández
%%% June 2015
%%% takes in sea state and spits out summed particle velocities.

function [ velocities, eta ] = particleVel( d, t, x, z, theta, H, T )

g = 9.81; 
vx = zeros(1,numel(t)); vy = zeros(1,numel(t)); vz = zeros(1,numel(t));
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
        else
            continue;
        end
    else
        %shallow
        vx = vx + cosd(theta) * H(i) / 2 * sqrt(g/d) * cos(k*x - w*t);
        vy = vy + sind(theta) * H(i) / 2 * sqrt(g/d) * cos(k*x - w*t);
        vz = vz + H(i) * w / 2 * (1 + z/d) * sin(k*x - w*t);
    end
end

velocities.x = vx; velocities.y = vy; velocities.z = vz;

end