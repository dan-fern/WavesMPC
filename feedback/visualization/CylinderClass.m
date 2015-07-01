% This is a class to visualize a cylinder.  The cylinder
% is created centered around the origin.
%
% Constructor argument options:
%   CylinderClass: radius=1 height=1
%   CylinderClass(radius, height)
%
% The cylinder can be manipulated in the following ways:
%   obj.plot: creates the plot
%   obj.updatePlotData: updates the plot with the
%       current object data
%   Read the Shape class for movement commands
%
% Author: Andrew Peekema

classdef CylinderClass < Shape
    properties
        x
        y
        z
        plotHandle1
        plotHandle2
        plotHandle3
    end

    methods
        % Constructor
        function obj = CylinderClass(radius, height)
            % Defaults if no arguments
            if nargin == 0
                radius = 1;
                height = 1;
            end

            % Call the Shape superclass constructor
            obj = obj@Shape;

            % Make a cylinder
            [obj.x obj.y z] = cylinder(radius,20);
            obj.z = height*(z - 1/2); % Center about the origin and scale from unit height
        end % CylinderClass

        function plot(obj)
            % Move the vertices into the object frame
            [plotX plotY plotZ] = transformPoints2(obj.x,obj.y,obj.z,obj.frame);

            % Plot the cylindrical surface
            obj.plotHandle1 = surf(plotX, plotY, plotZ);
            set(obj.plotHandle1, 'FaceColor',[1 0.6 0], 'FaceAlpha',1, 'EdgeAlpha', 0);
            % Plot the end caps
            obj.plotHandle2 = fill3(plotX(1,:),  plotY(1,:),  plotZ(1,:),[1 0.6 0]);
            obj.plotHandle3 = fill3(plotX(end,:),plotY(end,:),plotZ(end,:),[1 0.6 0]);
            hold on
        end

        function updatePlotData(obj)
            % Is there a plot?
            if ~ishandle(obj.plotHandle1)
                error('No cylinder plot')
            end

            % Move the vertices into the object frame
            [plotX plotY plotZ] = transformPoints2(obj.x,obj.y,obj.z,obj.frame);

            % Update the plot
            set(obj.plotHandle1,...
                'XData',plotX,...
                'YData',plotY,...
                'ZData',plotZ);
            set(obj.plotHandle2,...
                'XData',plotX(1,:),...
                'YData',plotY(1,:),...
                'ZData',plotZ(1,:));
            set(obj.plotHandle3,...
                'XData',plotX(end,:),...
                'YData',plotY(end,:),...
                'ZData',plotZ(end,:));
        end

    end % methods

end % classdef
