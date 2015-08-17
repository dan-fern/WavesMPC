function [ robot ] = loadSeaBotix( t, IC, DC, seaParticles )

[ robot.state.px, robot.IC.px ] = deal( IC(1) );
[ robot.state.pz, robot.IC.pz ] = deal( IC(2) );
[ robot.state.vx, robot.IC.vx ] = deal( IC(3) );
[ robot.state.vz, robot.IC.vz ] = deal( IC(4) );
[ robot.state.ax, robot.IC.ax ] = deal( IC(5) );
[ robot.state.az, robot.IC.az ] = deal( IC(6) );
robot.DC.px = DC(1);
robot.DC.pz = DC(2);
robot.DC.vx = DC(3);
robot.DC.vz = DC(4);
robot.DC.ax = DC(5);
robot.DC.az = DC(6);
robot.particles = seaParticles;
robot.length = 0.7; 
robot.width = 0.4; 
robot.height = 0.4;
robot.fA = degtorad(35);        %Forward Thruster Angle
robot.aA = degtorad(45);        %Aft Thruster Angle
robot.vA = degtorad(20);        %vertical Thruster Angle
robot.Tmax = 30;                %max thrust per motor
robot.mDry = 22;                %dry mass in kg in air
[ robot.mAdx, robot.mAdz ] = loadAddedMass( IC(2) ); %added mass for x/z

robot.errors.pErrorX = robot.DC.px - robot.state.px;
robot.errors.pErrorZ = robot.DC.pz - robot.state.pz;
robot.errors.dErrorX = robot.errors.pErrorX;
robot.errors.dErrorZ = robot.errors.pErrorZ;
robot.errors.iErrorX = robot.errors.pErrorX;
robot.errors.iErrorZ = robot.errors.pErrorZ;

robot.robotPlots.px = zeros(1,numel(t)) + robot.state.px;
robot.robotPlots.pz = zeros(1,numel(t)) + robot.state.pz;
robot.robotPlots.vx = zeros(1,numel(t)) + robot.state.vx;
robot.robotPlots.vz = zeros(1,numel(t)) + robot.state.vz;
robot.robotPlots.ax = zeros(1,numel(t)) + robot.state.ax;
robot.robotPlots.az = zeros(1,numel(t)) + robot.state.az;

robot.particlePlots.px = zeros(1,numel(t)) + robot.state.px;
robot.particlePlots.pz = zeros(1,numel(t)) + robot.state.pz;
robot.particlePlots.vx = zeros(1,numel(t)) + robot.state.vx;
robot.particlePlots.vz = zeros(1,numel(t)) + robot.state.vz;
robot.particlePlots.ax = zeros(1,numel(t)) + robot.state.ax;
robot.particlePlots.az = zeros(1,numel(t)) + robot.state.az;

robot.errorPlots.pErrorX = zeros(1,numel(t)) + robot.errors.pErrorX;
robot.errorPlots.pErrorZ = zeros(1,numel(t)) + robot.errors.pErrorZ;
robot.errorPlots.iErrorX = zeros(1,numel(t)) + robot.errors.iErrorX;
robot.errorPlots.iErrorZ = zeros(1,numel(t)) + robot.errors.iErrorZ;

return 

end