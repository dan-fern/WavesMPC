% This is a class to visualize a spring.  The spring
% points along the g frame x-axis
%
% Constructor argument options:
%   SpringClass: Frame at the origin, length=1
%   SpringClass(frame,length)
%
% The spring can be manipulated in the following ways:
%   obj.updateState(frame,length): Changes the spring to have
%       the given frame and length
%   obj.plot: creates the plot
%   obj.updatePlotData: updates the plot with the
%       current object data
%
% Author: Andrew Peekema


classdef SpringClass < Shape
    properties
        plotHandle
        x
        y
        z
    end

    methods
        % Constructor
        function obj = SpringClass(f, l)
            % Defaults if no arguments
            if nargin == 0
                f = SE3; % Frame
                l = 1;   % Length
            end

            % Call the Shape superclass constructor
            obj = obj@Shape;

            % Make a coil
            radius = l/15;
            coilTurns   = 3.5;
            coilPoints  = 0:pi/50:coilTurns*2*pi;
            yCoilPoints = sin(coilPoints)*radius;
            zCoilPoints = cos(coilPoints)*radius;
            % Add endpoints (centered)
            obj.y = [0 yCoilPoints 0];
            obj.z = [0 zCoilPoints 0];
            % Set the x positions
            obj.updateState(f,l);
        end % SpringClass

        function updateState(obj,f,l)
            % Save the frame
            obj.frame = f;
            % Coil length is 70% spring length
            xCoil = linspace(l*0.15,l*0.85,length(obj.y)-2);
            % Endpoints
            obj.x = [0 xCoil l];
        end

        function plot(obj)
            % Move the vertices into the object frame
            [plotX plotY plotZ] = transformPoints2(obj.x,obj.y,obj.z,obj.frame);

            % Plot the spring
            obj.plotHandle = plot3(plotX,plotY,plotZ);
            set(obj.plotHandle, 'Color',[1 0.4 0], 'LineWidth',5);
            hold on
        end

        function updatePlotData(obj)
            % Is there a plot?
            if ~ishandle(obj.plotHandle)
                error('No spring plot')
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
