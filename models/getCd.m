%%% getCd.m 
%%% Daniel Fernández
%%% June 2015
%%% This returns a value for drag coefficient on the vehicle based on its
%%% orientation in the fluid flow.  This should be updated with either
%%% better data on vehicle drag parameters, or swapped for AQWA data.


function [ Cd, Ai, theta ] = getCd( vx, vz, Ax, Az ) 

theta = atand(vz/vx);

if vx < 0
    theta = theta + 180;
elseif vz < 0 
    theta = 90 - abs(theta) + 270;
else
end 

Ai = Ax * abs(cosd(theta)) + Az * abs(sind(theta));
Cd = 1.06 - (0.22) * abs(sind(2 * theta));

return

end