function animation(t,sol,exportVideo)
% 3D Visualization Template
% Input
%   c: Simulation constants
%   sol: Simulation solution
%   exportVideo: Should the video be exported? (True/False)
% Output
%   An animation
% By Andrew Peekema

% For SE3
addpath('groupTheory')
% For 
addpath('visualization')

LoadColors = [0 .5 0;
              .3 1 0;
              .3 1 0;
              .3 1 0;
              .3 1 0;
              .3 1 0;
              0 .5 0;
              .3 1 0];

ActColors = [0 0 1;
              0 .4 1;
              0 .4 1;
              0 .4 1;
              0 .4 1;
              0 .4 1;
              0 0 1;
              0 .4 1];

% Create objects
massSide = 1; % m
loadObj = CubeClass(massSide);
%actObj = CubeClass(.8*massSide);
%springObj = SpringClass(SE3, 1);

loadObj.colors = LoadColors;
%actObj.colors = LoadColors;

% Create a figure handle
h.figure = figure;

% Put the shapes into a plot
loadObj.plot
%actObj.plot
%springObj.plot


% Figure properties
view(3)
title('Simulation')
xlabel('x Position (m)')
ylabel('y Position (m)')
zlabel('z Position (m)')

% Speed up if watching in realtime
if exportVideo
    frameStep = 3;
else
    frameStep = 3;
end

% Iterate over state data
for it = 1:frameStep:length(t)
    %actY = sol.X(it,1);
    robX = sol(it,1);
    robY = sol(it,3);
    robZ = sol(it,5);
    robW = sol(it,7);
    robR = sol(it,9);

    % Set axis limits
    axis([-2 10 ... % x
          0 10 ... % y
          0 10]);  % z

    % Load Mass position
    loadObj.resetFrame
    loadObj.globalMove(SE3([robX+massSide/2 robY+massSide/2 robY+massSide/2 robR 0 robW]));
    
    %Actuator Mass
    %actObj.resetFrame
    %actObj.globalMove(SE3([0 actY+.6*massSide/2 0]));

    % Spring position
    
    %springObj.updateState(SE3([0 actY+massSide/4 0 0 0 3.1415/2]),min(abs(loadY-actY),.5));

    % Update data
    loadObj.updatePlotData
   % actObj.updatePlotData
   % springObj.updatePlotData

    % Draw figure
    drawnow

    % Save the frames
    if exportVideo
        frame = getframe(h.figure);
        filename = sprintf('./video/%04d.png',it);
        imwrite(frame.cdata, filename);
    end
end % for it = ...

end % RobotAnimation
