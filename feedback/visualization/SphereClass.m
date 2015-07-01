% This is a class to visualize a sphere.  The sphere is
% created centered around the origin.
%
% Constructor argument options:
%   SphereClass: radius=1
%   SphereClass(radius)
%
% The sphere can be manipulated in the following ways:
%   obj.plot: creates the plot
%   obj.updatePlotData: updates the plot with the
%       current object data
%   Read the Shape class for movement commands
%
% Author: Andrew Peekema

classdef SphereClass < Shape
    properties
        x
        y
        z
        plotHandle
    end

    methods
        % Constructor
        function obj = SphereClass(radius)
            % Defaults if no arguments
            if nargin == 0
                radius = 1;
            end

            % Call the Shape superclass constructor
            obj = obj@Shape;

            % Make a sphere
            [x y z] = sphere(20);
            obj.x = radius*x;
            obj.y = radius*y;
            obj.z = radius*z;
        end % SphereClass

        function plot(obj)
            % Move the vertices into the object frame
            [plotX plotY plotZ] = transformPoints2(obj.x,obj.y,obj.z,obj.frame);

            % Plot
            obj.plotHandle = surf(plotX, plotY, plotZ);
            set(obj.plotHandle, 'FaceColor',[0 0 1], 'FaceAlpha',1, 'EdgeAlpha', 0);
            hold on
        end

        function updatePlotData(obj)
            % Is there a plot?
            if ~ishandle(obj.plotHandle)
                error('No sphere plot')
            end

            % Move the vertices into the object frame
            [plotX plotY plotZ] = transformPoints2(obj.x,obj.y,obj.z,obj.frame);

            % Update the plot
            set(obj.plotHandle,...
                'XData',plotX,...
                'YData',plotY,...
                'ZData',plotZ);
        end

    end % methods

end % classdef
