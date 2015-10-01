%%% getDragForces.m 
%%% Daniel Fernández
%%% June 2015
%%% takes in particle velocities and spits out instantaneous drag forces.


function [ forces ] = getDragForces( t, particles, robot, rho )

forces.mag = zeros(1, numel(t));
forces.x = zeros(1, numel(t));
forces.z = zeros(1, numel(t));
forces.theta = atand(particles.vz./particles.vx);

particles.magnitude = sqrt(particles.vx.^2 + particles.vz.^2);

Ax = robot.width * robot.height;
Az = robot.width * robot.length;

for j = 1:numel(t)
    if particles.vx(j) < 0
        forces.theta(j) = forces.theta(j) + 180;
    elseif particles.vz(j) < 0 
        forces.theta(j) = 90 - abs(forces.theta(j)) + 270;
    else
        continue;
    end            
    Ai = Ax * abs(cosd(forces.theta(j))) + Az * abs(sind(forces.theta(j)));
    cd = 1.0 - (0.2) * abs(sind(2 * forces.theta(j)));
    forces.mag(j) = 1/2 * rho * particles.magnitude(j)^2 * cd * Ai;
    forces.x(j) = forces.mag(j) * cosd(forces.theta(j));
    forces.z(j) = forces.mag(j) * sind(forces.theta(j));
end

end