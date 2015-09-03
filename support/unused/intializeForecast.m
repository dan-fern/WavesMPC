function [ u0, s0, J0 ] = intializeForecast( t, robot, spectra, count, oldInput ) 

tempBot = robot;
tSteps = t.tSteps;
x = robot.state.px; z = robot.state.pz;

u0 = zeros( tSteps, 2 );
s0 = zeros( tSteps+1, 2 ); 
s0(:,1) = x; s0(:,2) = z;
J0 = zeros( tSteps, 2 );

if numel( find( isnan(oldInput) == 1 ) ) == 2*(tSteps-1)
    tempBot.state = robot.state;
    for i = 1:tSteps
        tempCount = count + i - 1;
        x = tempBot.state.px; z = tempBot.state.pz;
        [ tempBot.particles ] = getRobotParticles( t.t(tempCount), x, z, ...
            spectra, tempBot.particles, tempCount );
        [ tempBot ] = pidMoveRobot( t.t, tempBot, spectra, tempCount );
        u0(i,1) = tempBot.uX; 
        u0(i,2) = tempBot.uZ;
        s0(i+1,1) = tempBot.state.px; 
        s0(i+1,2) = tempBot.state.pz;
        [ J0(i,1) ] = getCost( tempBot.DC.px, s0(i+1,1) );
        [ J0(i,2) ] = getCost( tempBot.DC.pz, s0(i+1,2) );
    end
else
    tempBot.state = robot.state;
    u0(1:(end-1),:) = oldInput;
    for i = 1:tSteps-1
        tempCount = count + i - 1;
        [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
            s0(i,1), s0(i,2), spectra, tempBot.particles, tempCount );
        [ tempBot ] = mpcMoveRobot( t.dt, tempBot, spectra, tempCount, u0(i,:) );
        s0(i+1,1) = tempBot.state.px; 
        s0(i+1,2) = tempBot.state.pz;
        [ J0(i,1) ] = getCost( tempBot.DC.px, s0(i+1,1) );
        [ J0(i,2) ] = getCost( tempBot.DC.pz, s0(i+1,2) );
    end
    tempCount = tempCount + 1;
    [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
        s0(tSteps,1), s0(tSteps,2), spectra, tempBot.particles, tempCount );
    [ tempBot ] = pidMoveRobot( t.t, tempBot, spectra, tempCount );
    u0(end,1) = tempBot.uX;
    u0(end,2) = tempBot.uZ;
    s0(end,1) = tempBot.state.px;
    s0(end,2) = tempBot.state.pz;
    [ J0(end,1) ] = getCost( tempBot.DC.px, s0(end,1) );
    [ J0(end,2) ] = getCost( tempBot.DC.pz, s0(end,2) );
end
u0( u0 >  1) =  1;
u0( u0 < -1) = -1;

return

end