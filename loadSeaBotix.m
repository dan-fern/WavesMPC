function [ robot ] = loadSeaBotix( t, IC )

robot.IC = IC;
robot.px = robot.IC(1);
robot.pz = robot.IC(2);
robot.vx = robot.IC(3);
robot.vz = robot.IC(4);
robot.ax = robot.IC(5);
robot.az = robot.IC(6);
robot.length = 0.7; 
robot.width = 0.4; 
robot.height = 0.4;
robot.fA = degtorad(35); %Forward Thruster Angle
robot.aA = degtorad(45); %Aft Thruster Angle
robot.vA = degtorad(20); %vertical Thruster Angle
robot.Tmax = 30; %max thrust per motor
robot.mDry = 22; %dry mass in kg in air
%[ robot.mAdx, robot.mAdz ] = loadAddedMass( 20 ); %added mass terms for x/z
robot.mAdx = 9;
robot.mAdz = 70;


robot.robotPlots.px = zeros(1,numel(t)) + robot.px;
robot.robotPlots.pz = zeros(1,numel(t)) + robot.pz;
robot.robotPlots.vx = zeros(1,numel(t)) + robot.vx;
robot.robotPlots.vz = zeros(1,numel(t)) + robot.vz;
robot.robotPlots.ax = zeros(1,numel(t)) + robot.ax;
robot.robotPlots.az = zeros(1,numel(t)) + robot.az;

robot.particlePlots.px = zeros(1,numel(t)) + robot.px;
robot.particlePlots.pz = zeros(1,numel(t)) + robot.pz;
robot.particlePlots.vx = zeros(1,numel(t)) + robot.vx;
robot.particlePlots.vz = zeros(1,numel(t)) + robot.vz;
robot.particlePlots.ax = zeros(1,numel(t)) + robot.ax;
robot.particlePlots.az = zeros(1,numel(t)) + robot.az;

return 

end