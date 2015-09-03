function r = Rz(alpha)
% Rotation matrix about z (yaw)
% Input
%  yaw angle
% Output
%  Rotation matrix

r = [cos(alpha) -sin(alpha) 0;
     sin(alpha)  cos(alpha) 0;
     0           0          1];

end % Rz
