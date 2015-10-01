%%% getSeaStateParticles.m 
%%% Daniel Fernández
%%% June 2015
%%% takes in sea state, position, and time; outputs current summed particle 
%%% velocities and accelerations.  Classifies component waves based on
%%% deep, intermediate, or shallow criteria.  Also plots wave profile, eta.

function [ particles, spectra ] = getSeaStateParticles( t, x, z, spectra )

g = 9.81; 
vx = zeros(1,numel(t)); vz = zeros(1,numel(t));
ax = zeros(1,numel(t)); az = zeros(1,numel(t));
spectra.eta = zeros(1, numel(t));

d = spectra.d;
H = spectra.H; 
T = spectra.T;
E = spectra.E;

[ spectra.w, spectra.L, spectra.k ] = dispersion( d, T, g );

w = spectra.w;
L = spectra.L;
k = spectra.k;

for i = 1:numel(T)   
    spectra.eta = spectra.eta + H(i) / 2 * cos(k(i)*x - w(i)*t + E(i));
    if d / L(i) > 0.5
        %deep
        if d < L(i) / 2
            vx = vx - H(i) * w(i) / 2 * exp(k(i)*z) ...
                * cos(k(i)*x - w(i)*t + E(i));
            vz = vz + H(i) * w(i) / 2 * exp(k(i)*z) ...
                * sin(k(i)*x - w(i)*t + E(i));
            ax = ax - 2 * H(i) * (w(i)/2)^2 * exp(k(i)*z) ...
                * sin(k(i)*x - w(i)*t + E(i));
            az = az + -2 * H(i) * (w(i)/2)^2 * exp(k(i)*z) ...
                * cos(k(i)*x - w(i)*t + E(i));
        else
            continue;
        end
    elseif d / L(i) < 0.05
        %shallow
        if d < L(i) / 2
            vx = vx - H(i) / 2 * sqrt(g/d) ...
                * cos(k(i)*x - w(i)*t + E(i));
            vz = vz + H(i) * w(i) / 2 * (1 + z/d) ...
                * sin(k(i)*x - w(i)*t + E(i));
            ax = ax + H(i) * w(i) * sqrt(g/d) / 2 ...
                * sin(k(i)*x - w(i)*t + E(i));
            az = az + -2 * H(i) * (w(i)/2)^2 * (1 + z/d) ...
                * cos(k(i)*x - w(i)*t + E(i));
        else
            continue;
        end
    else 
        %intermediate
        if d < L(i) / 2
            vx = vx - (g * pi * H(i) * cosh(2*pi*(z+d)/L(i)) ...
                * cos(k(i)*x - w(i)*t + E(i)) / (w(i) * L(i) ...
                * cosh(2*pi*d/L(i))));
            vz = vz + g * pi * H(i) * sinh(2*pi*(z+d)/L(i)) ...
                * sin(k(i)*x - w(i)*t + E(i)) / (w(i) * L(i) ...
                * cosh(2*pi*d/L(i)));
            ax = ax - (g * pi * H(i) * cosh(2*pi*(z+d)/L(i)) ...
                * sin(k(i)*x - w(i)*t + E(i)) / (L(i) ...
                * cosh(2*pi*d/L(i))));
            az = az + -g * pi * H(i) * sinh(2*pi*(z+d)/L(i)) ...
                * cos(k(i)*x - w(i)*t + E(i)) / (L(i) * cosh(2*pi*d/L(i)));
        else
            continue;
        end
    end
end

%vx = vx -0.01;
particles.vx = vx; particles.vz = vz;
particles.ax = ax; particles.az = az;

end