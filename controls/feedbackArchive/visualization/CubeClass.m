% This is a class to visualize a cube.  The cube is
% created centered around the origin.
%
% Constructor argument options:
%   CubeClass: 1x1x1 cube
%   CubeClass(a): axaxa cube
%   CubeClass([a b]): axbxb rectangle
%   CubeClass([a b c]): axbxc rectangular cuboid
%
% The cube can be manipulated in the following ways:
%   obj.plot: creates the plot
%   obj.updatePlotData: updates the plot with the
%       current object data
%   Read the Shape class for movement commands
%
% Author: Andrew Peekema

classdef CubeClass < Shape
    properties
        vertices
        faces
        colors
        plotHandle
    end

    methods
        % Constructor
        function obj = CubeClass(width)
            % Ways to create a cube
            % No arguments
            if nargin == 0
                xWidth = 1;
                yWidth = 1;
                zWidth = 1;
            % Make a cube
            elseif length(width) == 1
                xWidth = width;
                yWidth = width;
                zWidth = width;
            % Make a rectangle
            elseif length(width) == 2
                xWidth = width(1);
                yWidth = width(2);
                zWidth = width(2);
            % Make a rectangular cuboid
            elseif length(width) == 3
                xWidth = width(1);
                yWidth = width(2);
                zWidth = width(3);
            else
                class(argument)
                size(argument)
                error('Unknown argument to CubeClass constructor of type and size listed above')
            end

            % Call the Shape superclass constructor
            obj = obj@Shape;

            % Create vertices
            vertices = [0 0 0;
                        xWidth 0 0;
                        xWidth yWidth 0;
                        0 yWidth 0;
                        0 0 zWidth;
                        xWidth 0 zWidth;
                        xWidth yWidth zWidth;
                        0 yWidth zWidth];
            % Center about the origin
            centerTransform = SE3([-xWidth/2,-yWidth/2,-zWidth/2,0,0,0]);
            obj.vertices = transformPoints(vertices,centerTransform);

            % Create faces from points
            obj.faces = [1 2 6 5;
                         2 3 7 6;
                         3 4 8 7;
                         4 1 5 8;
                         1 2 3 4;
                         5 6 7 8];

            % Face colors
            obj.colors = [1 0 0;
                          1 0.6 0;
                          1 0.6 0;
                          1 0.6 0;
                          1 0.6 0;
                          1 0.6 0;
                          1 0 0;
                          1 0.6 0];
        end % CubeClass

        function plot(obj)
            % Move the vertices into the object frame
            plotVertices = transformPoints(obj.vertices,obj.frame);

            % Plot
            obj.plotHandle = patch('Vertices',plotVertices,...
                                   'Faces',obj.faces,...
                                   'FaceVertexCData',obj.colors,...
                                   'FaceColor','interp');
            hold on
        end

        function updatePlotData(obj)
            % Is there a plot?
            if ~ishandle(obj.plotHandle)
                error('No cube plot')
            end

            % Move the vertices into the object frame
            plotVertices = transformPoints(obj.vertices,obj.frame);

            % Update the plot
            set(obj.plotHandle, 'Vertices',plotVertices);
        end

    end % methods

end % classdef
