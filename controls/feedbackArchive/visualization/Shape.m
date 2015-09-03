% This is a superclass for moving a frame in 3D. Classes
% that subclass this will be have a frame that can be
% manipulated in the following ways:
%   obj.globalMove(SE3Transform): move the frame with respect
%       to the origin
%   obj.localMove(SE3Transform): move the frame with respect
%       to the body
%   obj.resetFrame: sets the frame to all zeros
%
% Author: Andrew Peekema

classdef (Abstract=true) Shape < handle
    properties
        frame
    end

    methods
        % Constructor
        function obj = Shape
            % For SE3
            addpath('groupTheory')
            % Body frame with respect to global frame
            obj.frame = SE3;
        end

        function globalMove(obj,transform)
            % Left multiplication will rotate by Rx, Ry, Rz, and then
            % translate by x, y, z with respect to the origin.
            obj.frame = SE3(transform)*obj.frame;
        end

        function localMove(obj,transform)
            % Right multiplication will translate by x, y, z, and then
            % rotate by Rz, Ry, Rx with respect to the body.
            obj.frame = obj.frame*SE3(transform);
        end

        function resetFrame(obj)
            obj.frame = SE3;
        end


    end % methods

end % classdef
