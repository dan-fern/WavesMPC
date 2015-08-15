function [ robot ] = mpcRobot( t, robot, spectra, count )

tempBot = robot;
dt = t(2) - t(1);
tHorizon = 25 * dt;
tSteps = tHorizon / dt;
%tComp = 5 * dt; 
decision = 10;
x = robot.px; z = robot.pz;
start = count;
stop = count + tSteps;

if count ~= 1
    [ tempBot.particles ] = getRobotParticles( t(start:stop), x, z, ...
        spectra, tempBot.particles, count );
else
    [ tempBot.particles ] = getSeaStateParticles( t(start:stop), x, z, ...
        spectra );
end

u0 = zeros( tSteps, 2 );
u1 = zeros( size( u0 ) );
s0 = zeros( tSteps, 2 ); 
s0(:,1) = x; s0(:,2) = z;
s1 = zeros( size( s0 ) );
d0 = rand( tSteps, 2 );
J0 = zeros( tSteps, 2 );
J1 = zeros( size( J0 ) );

for i = 1:tSteps
    tempCount = count + i - 1;
    x = tempBot.px; z = tempBot.pz;
    [ tempBot.particles ] = getRobotParticles( t(tempCount), x, z, ...
        spectra, tempBot.particles, tempCount );
    [ tempBot ] = pidRobot( t, tempBot, spectra, tempCount );
    u0(i,1) = tempBot.uX; u0(i,2) = tempBot.uZ;
    s0(i,1) = tempBot.px; s0(i,2) = tempBot.pz;
    [ J0(i,:) ] = getCost( tempBot.DC, s0(i,:) ); 
end

for j = 1:decision %or decision criteria
    if j ~= 1
        d = getJacobian( J0, J1, u0, u1 );
        u0 = u1;
        s0 = s1;
        J0 = J1;
        if mean(abs(d(:,1))) >= 0.01 && mean(abs(d(:,2))) >= 0.01
            d1 = d;
        else 
            disp( 'KICK OUT' );
            d1 = d;
            %break
        end
    else
        d1 = d0;
    end
    u1 = u0 + d1;
    u1( u1 >=  1) =  1; 
    u1( u1 <= -1) = -1;
    for i = 1:tSteps
        tempCount = count + i - 1;
        [ tempBot.particles ] = getRobotParticles( t(tempCount), ...
            s0(i,1), s0(i,2), spectra, tempBot.particles, tempCount );
        [ tempBot ] = getForecast( dt, tempBot, spectra, tempCount, u1(i,:) );
        s1(i,1) = tempBot.px; s1(i,2) = tempBot.pz;
        [ J1(i,:) ] = getCost( tempBot.DC, s1(i,:) );
    end

end

robot = tempBot;

disp(count);

return

end