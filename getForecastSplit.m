function [ u1, tCalc ] = getForecastSplit( t, robot, spectra, count )

tempBot = robot;
tSteps = t.tSteps;
decision = 100;
resolution = 0.005;
x = robot.state.px; z = robot.state.pz;

u0 = zeros( tSteps, 2 );
u1 = zeros( size( u0 ) );
s0 = zeros( tSteps+1, 2 ); 
s0(:,1) = x; s0(:,2) = z;
s1 = zeros( size( s0 ) );
J0 = zeros( tSteps, 2 );
J1 = zeros( size( J0 ) );
%d0 = rand( tSteps, 2 );
d0 = zeros( tSteps, 2 ) + 0.0000001;
%[ d0 ] = forecastGuess( t, spectra, count );

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
        checkX = numel( find( (abs(d(:,1)) <= resolution) == 1) );
        checkZ = numel( find( (abs(d(:,2)) <= resolution) == 1) );
        if checkX == tSteps && checkZ == tSteps
            disp( 'KICK OUT' );
            break
        elseif checkX == tSteps
            for k = j:decision
                tempBot.state = robot.state;
                d = getJacobian( J0, J1, u0, u1 );
                u0 = u1;
                s0 = s1;
                J0 = J1;
                checkZ = abs(d(:,2));
                if checkZ(:) <= resolution
                    disp( 'KICK OUTTA Z' );
                    break
                else
                    d1 = d;
                end
                u1(:,2) = u0(:,2) - d1(:,2);
                for i = 1:tSteps
                    tempCount = count + i - 1;
                    [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
                        s0(i,1), s0(i,2), spectra, tempBot.particles, tempCount );
                    [ tempBot ] = mpcMoveRobotZ( t.dt, tempBot, spectra, tempCount, u1(i,:) );
                    s1(i+1,2) = tempBot.state.pz;
                    [ J1(i,:) ] = getCost( tempBot.DC, s1(i+1,:) );
                end
                if mod( k, 25 ) == 0
                    fprintf('*');
                end
            end
            break
        elseif checkZ == tSteps
            for k = j:decision
                tempBot.state = robot.state;
                d = getJacobian( J0, J1, u0, u1 );
                u0 = u1;
                s0 = s1;
                J0 = J1;
                checkX = abs(d(:,1));
                if checkX(:) <= resolution
                    disp( 'KICK OUTTA X' );
                    break
                else
                    d1 = d;
                end
                u1(:,1) = u0(:,1) - d1(:,1);
                for i = 1:tSteps
                    tempCount = count + i - 1;
                    [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
                        s0(i,1), s0(i,2), spectra, tempBot.particles, tempCount );
                    [ tempBot ] = mpcMoveRobotX( t.dt, tempBot, spectra, tempCount, u1(i,:) );
                    s1(i+1,1) = tempBot.state.px;
                    [ J1(i,:) ] = getCost( tempBot.DC, s1(i+1,:) );
                end
                if mod( k, 25 ) == 0
                    fprintf('*');
                end
            end
            break
        else
            d1 = d;            
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
        str = ['balls... fails at ', num2str(j), ' decisions.'];
        disp(str);
        u1 = u0;
        break
    elseif mod( j, 25 ) == 0
        fprintf('*');
    end
end

disp(j);
disp(toc);
tCalc = toc;
disp(count);

return

end