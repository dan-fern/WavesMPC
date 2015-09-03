function [x y z] = transformPoints2(x,y,z,transform)
% Inputs
%  x,y,z: in the global frame
%  transform: transformation matrix (SE3) in the global frame
% Output
%  x,y,z: in the global frame

% The transform performs the rotation, then the translation
% with respect to the origin

% For each point
for row = [1:size(x,1)]
    for col = [1:size(x,2)]
        % Create an SE3 point
        point = [x(row,col);
                 y(row,col);
                 z(row,col)
                 1];

        % Transform
        transPoint = transform*point;

        % Save the output
        x(row,col) = transPoint(1);
        y(row,col) = transPoint(2);
        z(row,col) = transPoint(3);
    end
end


end
