% This is a class for the Special Euclidean Group in three dimensions (SE3).
% SE3 is a mathematical construct used for keeping track of position
% and orientation in 3D, and performing operations (translations,
% rotations, etc.) in this space.
%
% An SE3 object can be created by passing the constructor the following:
%   SE3: Defaults to all zeros
%   SE3(An SE3 object)
%   SE3(A 4x4 matrix): Assumed to be SE3
%   SE3(A 3x3 matrix): Assumed to be SO3 (Special Orthogonal Group in 3D)
%   SE3([x y z]): Translations along x, y, and z axes with respect to the origin
%   SE3([x y z gamma beta alpha]): The frame is rotated about x, y and z (gamma,
%       beta, alpha) in that order with respect to the origin, and then
%       translated along x, y, and z with respect to the origin.
%
% The SE3 object can be manipulated in the following ways:
%   Left multiplication will rotate by Rx, Ry, Rz, and then
%     translate by x, y, z with respect to the origin.
%   Right multiplication will translate by x, y, z, and then
%     rotate by Rz, Ry, Rx with respect to the body.
%   obj.x: Returns x
%   obj.y: Returns y
%   obj.z: Returns z
%   obj.xyz: Returns [x y z]
%   obj.XYZ: Returns x, y, and z as a skew-symmetric matrix
%   obj.r: Returns the rotation as a vector
%   obj.R: Returns the rotation as a matrix
%   obj.g: Returns the 4x4 SE3 matrix
%   obj.invAdj: Returns the inverse adjoint (for use with twists)
%   obj.transAdj: Returns the transpose adjoint (for use with wrenches)
%   obj.distance: Returns the distance to the origin
%
% Author: Andrew Peekema

classdef SE3 < handle
    properties
        g   % SE3 element
    end

    methods
        % Constructor
        function obj = SE3(argument)
            % Defaults if no argument
            if nargin == 0
                x = 0;
                y = 0;
                z = 0;
                gamma = 0;
                beta  = 0;
                alpha = 0;
                % Rotation matrix (SO3)
                R = Rz(alpha)*Ry(beta)*Rx(gamma);

                obj.g = [[R; 0 0 0] [x; y; z; 1]];
                return
            end

            if isa(argument,'SE3') % Is of type SE3
                obj.g = argument.g;
            elseif all([4 4] == size(argument)) % If a 4x4 matrix, assumed to be SE3
                obj.g = argument;
            elseif all([3 3] == size(argument)) % If a 3x3 matrix, assumed to be SO3
                obj.g = [argument zeros(3,1);
                         0 0 0 1];
            elseif length(argument) == 3
                % Vector of:
                % x, y, z: translations along x, y, and z with respect to the origin

                % Unpack
                x = argument(1);
                y = argument(2);
                z = argument(3);
                gamma = 0;
                beta  = 0;
                alpha = 0;

                % Rotation matrix (SO3)
                R = Rz(alpha)*Ry(beta)*Rx(gamma);

                obj.g = [[R; 0 0 0] [x; y; z; 1]];
            elseif length(argument) == 6
                % Vector of:
                % x, y, z: translations along x, y, and z with respect to the origin
                % gamma, beta, alpha: rotations about x, y, and z with respect to the origin

                % Unpack
                x = argument(1);
                y = argument(2);
                z = argument(3);
                gamma = argument(4);
                beta  = argument(5);
                alpha = argument(6);

                % Rotation matrix (SO3)
                R = Rz(alpha)*Ry(beta)*Rx(gamma);

                obj.g = [[R; 0 0 0] [x; y; z; 1]];
            else
                class(argument)
                size(argument)
                error('Unknown argument to SE3 constructor of type and size listed above')
            end
        end % SE3

        function product = mtimes(a,b) % Matrix multiplication
            % Left multiplication will rotate by Rx, Ry, Rz, and then
            %   translate by x, y, z with respect to the origin.
            % Right multiplication will translate by x, y, z, and then
            %   rotate by Rz, Ry, Rx with respect to the body.

            % If both are SE3 classes
            if (isa(a,'SE3') && isa(b,'SE3'))
                product = SE3(a.g*b.g);
            % Else if a is SE3 and the other is a matrix
            elseif (isa(a,'SE3') && isa(b,'double'))
                product = a.g*b;
            % Else if b is SE3 and the other is a matrix
            elseif (isa(a,'double') && isa(b,'SE3'))
                product = a*b.g;
            else
                class(a)
                class(b)
                error('Undefined operation * for SE3 with types listed above')
            end
        end % mtimes

        function resultant = mrdivide(a,b) % Right matrix division
            % If both are SE3 classes
            if (isa(a,'SE3') && isa(b,'SE3'))
                resultant = SE3(a.g/b.g);
            % Else if a is SE3 and the other is a matrix
            elseif (isa(a,'SE3') && isa(b,'double'))
                resultant = a.g/b;
            % Else if b is SE3 and the other is a matrix
            elseif (isa(a,'double') && isa(b,'SE3'))
                resultant = a/b.g;
            else
                class(a)
                class(b)
                error('Undefined operation / for SE3 with types listed above')
            end
        end % mrdivide

        function resultant = mldivide(a,b) % Left matrix division
            % If both are SE3 classes
            if (isa(a,'SE3') && isa(b,'SE3'))
                resultant = SE3(a.g\b.g);
            % Else if a is SE3 and the other is a matrix
            elseif (isa(a,'SE3') && isa(b,'double'))
                resultant = a.g\b;
            % Else if b is SE3 and the other is a matrix
            elseif (isa(a,'double') && isa(b,'SE3'))
                resultant = a\b.g;
            else
                class(a)
                class(b)
                error('Undefined operation \ for SE3 with types listed above')
            end
        end % mldividie

        function xOut = x(obj)  % Extract x Position
            xOut = obj.g(1,4);
        end

        function yOut = y(obj)  % Extract y Position
            yOut = obj.g(2,4);
        end

        function zOut = z(obj)  % Extract z Position
            zOut = obj.g(3,4);
        end

        function xyzOut = xyz(obj)  % Extract Position Vector
            xyzOut = obj.g(1:3,4);
        end

        function XYZOut = XYZ(obj)  % Extract Position Matrix (Skew-Symmetric)
            x = obj.g(1,4);
            y = obj.g(2,4);
            z = obj.g(3,4);
            XYZOut = [0 -z  y;
                      z  0 -x;
                     -y  x  0];
        end

        function rOut = r(obj) % Extract Rotation Vector
            % gamma, beta, alpha: rotations about x, y, and z with respect to the origin
            % R(3,1) = -sin(beta)
            beta = asin(-obj.g(3,1));
            % R(1,1) = cos(alpha)*cos(beta)
            alpha = acos(obj.g(1,1)/cos(beta));
            % R(3,3) = cos(beta)*cos(gamma)
            gamma = acos(obj.g(3,3)/cos(beta));
            rOut = [gamma; beta; alpha];
        end

        function ROut = R(obj) % Extract Rotation Matrix
            ROut = obj.g(1:3,1:3);
        end

        function InvAdj = invAdj(obj) % Generate Inverse Adjoint
            InvAdj = [obj.R'   -obj.R'*obj.XYZ;
                      zeros(3)  obj.R'];
        end

        function TransAdj = transAdj(obj) % Generate Transpose Adjoint
            TransAdj = [obj.R'         zeros(3);
                       -obj.R'*obj.XYZ obj.R'];
        end

        function l = distance(obj) % Distance to the origin
            l = (obj.g(1,4)^2+obj.g(2,4)^2+obj.g(3,4)^2)^0.5;
        end

    end % methods

end % classdef
