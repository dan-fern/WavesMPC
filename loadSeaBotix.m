function [ robot ] = loadSeaBotix( t, IC, DC )

robot.IC = IC;
robot.DC = DC;
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
[ robot.mAdx, robot.mAdz ] = loadAddedMass( IC(2) ); %added mass for x/z
%robot.mAdx = 9;
%robot.mAdz = 70;

robot.errors.pErrorX = robot.DC(1) - robot.px;
robot.errors.pErrorZ = robot.DC(2) - robot.pz;
robot.errors.dErrorX = robot.errors.pErrorX;
robot.errors.dErrorZ = robot.errors.pErrorZ;
robot.errors.iErrorX = robot.errors.pErrorX;
robot.errors.iErrorZ = robot.errors.pErrorZ;

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

robot.errorPlots.pErrorX = zeros(1,numel(t)) + robot.errors.pErrorX;
robot.errorPlots.pErrorZ = zeros(1,numel(t)) + robot.errors.pErrorZ;
robot.errorPlots.iErrorX = zeros(1,numel(t)) + robot.errors.iErrorX;
robot.errorPlots.iErrorZ = zeros(1,numel(t)) + robot.errors.iErrorZ;

return 

end