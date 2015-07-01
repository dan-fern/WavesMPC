function r = Ry(beta)
% Rotation matrix about y (pitch)
% Input
%  pitch angle
% Output
%  Rotation matrix

r = [cos(beta) 0 sin(beta);
     0         1 0;
    -sin(beta) 0 cos(beta)];

end % Ry
