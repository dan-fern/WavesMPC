%Runnify
%By Thane Somers the Great(ly tired).

%Our States: x, xdot, y, ydot, z, zdot,  w, wdot (yaw), r, rdot (roll)
%lets say each thruster produces up to 29.4 N of force, linearly over it's
%control range.  

%Our States: x, xdot, y, ydot, z, zdot,  w, wdot (yaw), r, rdot (roll)
%Our input matrix: m1 = Front Port, m2 = Front Starboard, m3 = Rear
%Starboard, m4 = Rear Port, m5 = Upper Port, m6 = Upper Starboard.
%These motor inputs are treated as being from 0 to 1.  
% X coord forward, Y coord to Starboard, Z coord down from surface.  
d = .05; %Damping in Newton-Meters/s. who knows.  
m = 22.6; %Mass in kilos.  About 50 lbs.  
In = .71; %Estimated Intertia, in kg*m^2
mT = 29.4; %Motor Thrust, in Newtons

tD = .2; %Thruster distance from CoM, estimated.
fA = degtorad(35); %Forward Thruster Angle
aA = degtorad(45); %Aft Thruster Angle
zA = degtorad(20); %Z Thruster Angle, guessed at this one.
tA = degtorad(10); % Angle of forward thrusters from optimal

x_init = [5, 0, 9, 0, 0, 0, 2, 0, 1, 0]';
x_in = [0, 0, 2, 0, 0, 0, 0, 0, 0, 0]';

A = [0 1 0 0 0 0 0 0 0 0; ...
    0 -d/m 0 0 0 0 0 0 0 0; ...
    0 0 0 1 0 0 0 0 0 0; ...
    0 0 0 -d/m 0 0 0 0 0 0; ...
    0 0 0 0 0 1 0 0 0 0; ...
    0 0 0 0 0 -d/m 0 0 0 0; ...
    0 0 0 0 0 0 0 1 0 0; ...
    0 0 0 0 0 0 0 -d/m 0 0; ...
    0 0 0 0 0 0 0 0 0 1; ...
    0 0 0 0 0 0 0 0 0 -d/m ];

B = [ 0 0 0 0 0;...
    mT*cos(fA)/m mT*cos(fA)/m -mT*cos(aA)/m 0 0;...
    0 0 0 0 0;...
    mT*sin(fA)/m -mT*sin(fA)/m -mT*sin(aA)/m mT*sin(zA)/m -mT*sin(zA)/m;...
    0 0 0 0 0;...
    0 0 0  -mT*cos(zA)/m -mT*cos(zA)/m;...
    0 0 0  0 0;...
    mT*tD*cos(tA)/In -mT*tD*cos(tA)/In mT*tD/In 0 0;...
    0 0 0 0 0;...
    0 0 0 -mT*tD/In mT*tD/In];

D = [1;0;1;0;0;0;1;0;0;0];

kGains = CCF(A,B)


Xdot = @(t,X) A*X+B*kGains*(X-x_in)+1*sin(3*t)*D;
[t,y] = ode45(Xdot, [0 5], x_init);


set(gca,'DefaultTextFontSize',21)
set(gca,'DefaultTextFontname', 'Times New Roman')
set(0,'DefaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize',21)
plot(t,y(:,1));
 hold on;
plot(t,y(:,3), 'g');
hold on;
plot(t,y(:,7), 'r');
legend('X Position', 'Y Position', 'Yaw Position')
xlabel('Time (s)')
ylabel('Position')

%hold on;
%plot(t,y(:,9), 'k');
% val = (A+B*gains)^-1*B*gains*x_in;
% legend('x_1', 'x_2');


%Animate
% c = 0
% exportVideo = true;
% animation(t,y,exportVideo);
