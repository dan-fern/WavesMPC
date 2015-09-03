function [points] = transformPoints(points,transform)
% Inputs
%  points: rows of points (x,y,z) in the global frame
%  transform: transformation matrix (SE3) in the global frame
% Output
%  points: rows of transformed points (x,y,z) in the global frame

% The transform performs the rotation, then the translation
% with respect to the origin

% Transform points
for index = [1:size(points,1)]
    % Transform
    transPoint = transform*SE3(points(index,:));

    % Save the output
    points(index,:) = transPoint.xyz';
end


end
