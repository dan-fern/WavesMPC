%%% forces.m 
%%% Daniel Fernández
%%% June 2015
%%% takes in particle velocities and spits out instantaneous forces.

function [ forces ] = forces( velocities, rho, length, width, height, t )

forces.mag = zeros(1, numel(t));
forces.x = zeros(1, numel(t));
forces.z = zeros(1, numel(t));
forces.theta = atand(velocities.z./velocities.x);

velocities.magnitude = sqrt(velocities.x.^2 + velocities.z.^2);

Ax = width * height;
Az = width * length;

for j = 1:numel(t)
    if velocities.x(j) < 0
        forces.theta(j) = forces.theta(j) + 180;
    elseif velocities.z(j) < 0 
        forces.theta(j) = 90 - abs(forces.theta(j)) + 270;
    end            
    Ai = Ax * abs(cosd(forces.theta(j))) + Az * abs(sind(forces.theta(j)));
    cd = 1.0 - (0.2) * abs(sind(2 * forces.theta(j)));
    forces.mag(j) = 1/2 * rho * velocities.magnitude(j)^2 * cd * Ai;
    forces.x(j) = forces.mag(j) * cosd(forces.theta(j));
    forces.z(j) = forces.mag(j) * sind(forces.theta(j));
end

end