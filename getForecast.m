function [ u1, tCalc ] = getForecastSplit( t, robot, spectra, count )

k = 0;
tempBot = robot;
tSteps = t.tSteps;
decision = 1000;
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
delta = zeros( tSteps, 2 ) + 0.0000001;
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
    [ J0(i,1) ] = getCost( tempBot.DC.px, s0(i+1,1) );
    [ J0(i,2) ] = getCost( tempBot.DC.pz, s0(i+1,2) );
end

for j = 1:decision %or decision criteria
    tempBot.state = robot.state;
    s1(1,1) = s0(1,1); 
    s1(1,2) = s0(1,2);
    u1 = u0 - delta; 
    for i = 1:tSteps
        tempCount = count + i - 1;
        [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
            s0(i,1), s0(i,2), spectra, tempBot.particles, tempCount );
        [ tempBot ] = mpcMoveRobot( t.dt, tempBot, spectra, tempCount, u1(i,:) );
        s1(i+1,1) = tempBot.state.px; 
        s1(i+1,2) = tempBot.state.pz;
        [ J1(i,1) ] = getCost( tempBot.DC.px, s1(i+1,1) );
        [ J1(i,2) ] = getCost( tempBot.DC.pz, s1(i+1,2) );
    end
    if find(isnan(s1)==1) > 0
        str = ['balls... fails at ', num2str(j), ' decisions.'];
        disp(str);
        u1 = u0;
        break
    elseif mod( j, 25 ) == 0
        fprintf('*');
    end
    [ deltaX ] = getJacobian( J0(:,1), J1(:,1), u0(:,1), u1(:,1) );
    [ deltaZ ] = getJacobian( J0(:,2), J1(:,2), u0(:,2), u1(:,2) );
    u0 = u1;
    s0 = s1;
    J0 = J1;
    checkX = numel( find( (abs(deltaX(:)) <= resolution) == 1) );
    checkZ = numel( find( (abs(deltaZ(:)) <= resolution) == 1) );
    if checkX == tSteps && checkZ == tSteps
        disp( 'KICK OUT' );
        break
    elseif checkX == tSteps % THIS IS FOR Z
        delta = deltaZ;
        u0z = u0(:,2); 
        for k = j:decision
            tempBot.state = robot.state;
            u1z = u0z - delta;
            for i = 1:tSteps
                tempCount = count + i - 1;
                [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
                    s0(i,1), s0(i,2), spectra, tempBot.particles, tempCount );
                [ tempBot ] = mpcMoveRobotZ( t.dt, tempBot, spectra, tempCount, u1z(i) );
                s1(i+1,2) = tempBot.state.pz;
                [ J1(i,2) ] = getCost( tempBot.DC.pz, s1(i+1,2) );
            end
            [ deltaZ ] = getJacobian( J0(:,2), J1(:,2), u0z, u1z );
            u0z = u1z;
            s0(:,2) = s1(:,2);
            J0(:,2) = J1(:,2);
            checkZ = abs(deltaZ(:));
            if checkZ(:) <= resolution
                disp( ' KICK OUTTA Z' );
                u1(:,2) = u1z;
                break
            else
                delta = deltaZ;
                if mod( k, 25 ) == 0
                    fprintf('z');
                end
            end
        end
        break
    elseif checkZ == tSteps % THIS IS FOR X
        delta = deltaX;
        u0x = u0(:,1);
        for k = j:decision
            tempBot.state = robot.state;
            u1x = u0x - delta;
            for i = 1:tSteps
                tempCount = count + i - 1;
                [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
                    s0(i,1), s0(i,2), spectra, tempBot.particles, tempCount );
                [ tempBot ] = mpcMoveRobotX( t.dt, tempBot, spectra, tempCount, u1x(i) );
                s1(i+1,1) = tempBot.state.px;
                [ J1(i,1) ] = getCost( tempBot.DC.px, s1(i+1,1) );
            end
            [ deltaX ] = getJacobian( J0(:,1), J1(:,1), u0x, u1x );
            u0x = u1x;
            s0(:,1) = s1(:,1);
            J0(:,1) = J1(:,1);
            checkX = abs(deltaX(:));
            if checkX(:) <= resolution
                disp( ' KICK OUTTA X' );
                u1(:,1) = u1x;
                break
            else
                delta = deltaX;
                if mod( k, 25 ) == 0
                    fprintf('x');
                end
            end
        end
        break
    else
        delta(:,1) = deltaX;  
        delta(:,2) = deltaZ;  
    end
end
fprintf(num2str(j));
fprintf('     & ');
disp(k);
disp(toc);
tCalc = toc;
disp(count);

return

end