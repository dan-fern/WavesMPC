function [ robot, u1 ] = getForecast( t, robot, spectra, count )

tempBot = robot;
tSteps = t.tSteps;
%tComp = t.tComp; 
decision = 200;
x = robot.state.px; z = robot.state.pz;
start = count;
stop = count + tSteps;

if count ~= 1
    [ tempBot.particles ] = getRobotParticles( t.t(start:stop), x, z, ...
        spectra, tempBot.particles, count );
else
    [ tempBot.particles ] = getSeaStateParticles( t.t(start:stop), x, z, ...
        spectra );
end

u0 = zeros( tSteps, 2 );
u1 = zeros( size( u0 ) );
s0 = zeros( tSteps+1, 2 ); 
s0(:,1) = x; s0(:,2) = z;
s1 = zeros( size( s0 ) );
d0 = rand( tSteps, 2 );
J0 = zeros( tSteps, 2 );
J1 = zeros( size( J0 ) );

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
    [ J0(i,:) ] = getCost( tempBot.DC, s0(i+1,:) ); 
end

for j = 1:decision %or decision criteria
    tempBot.state = robot.state;
    if j ~= 1
        d = getJacobian( J0, J1, u0, u1 );
        u0 = u1;
        s0 = s1;
        J0 = J1;
        if mean(abs(d(:,1))) >= 0.005 && mean(abs(d(:,2))) >= 0.005
            d1 = d;
        else 
            disp( 'KICK OUT' );
            break
        end
    else
        d1 = d0;
        s1(1,1) = s0(1,1); 
        s1(1,2) = s0(1,2);
    end
    u1 = u0 - d1; 
    for i = 1:tSteps
        tempCount = count + i - 1;
        [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
            s0(i,1), s0(i,2), spectra, tempBot.particles, tempCount );
        [ tempBot ] = mpcMoveRobot( t.dt, tempBot, spectra, tempCount, u1(i,:) );
        s1(i+1,1) = tempBot.state.px; 
        s1(i+1,2) = tempBot.state.pz;
        [ J1(i,:) ] = getCost( tempBot.DC, s1(i+1,:) );
    end
    if find(isnan(s1)==1) > 0
    disp(j);
    u1 = u0;
    break
    end
end

robot = tempBot;

disp(count);

return

end