function r = Rx(gamma)
% Rotation matrix about x (roll)
% Input
%  roll angle
% Output
%  Rotation matrix

r = [1 0           0;
     0 cos(gamma) -sin(gamma);
     0 sin(gamma)  cos(gamma)];

end % Rx
