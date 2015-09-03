function [ Cd, Ai, theta ] = getCd( vx, vz, Ax, Az ) 

theta = atand(vz/vx);

if vx < 0
    theta = theta + 180;
elseif vz < 0 
    theta = 90 - abs(theta) + 270;
else
end 

Ai = Ax * abs(cosd(theta)) + Az * abs(sind(theta));
Cd = 1.05 - (0.25) * abs(sind(2 * theta));

return

end