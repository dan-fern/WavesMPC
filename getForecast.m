function [ u1, tCalc ] = getForecast( t, robot, spectra, count, oldInput )

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
delta = zeros( tSteps, 2 ) + resolution/1000;
%[ d0 ] = forecastGuess( t, spectra, count );

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

for j = 1:decision %or decision criteria
    tempBot.state = robot.state;
    s1(1,1) = s0(1,1); 
    s1(1,2) = s0(1,2);
    u1 = u0 - delta;
    u1( u1 >  1) =  1; 
    u1( u1 < -1) = -1;
    if sum( all( u0 == u1, 2 ) ) > 0
        fprintf('NO!!');
        [ u1 ] = thresholdInput( u0, u1 );
    end
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
        fprintf('%%');
    end
    [ deltaX ] = getJacobian( J0(:,1), J1(:,1), u0(:,1), u1(:,1) );
    [ deltaZ ] = getJacobian( J0(:,2), J1(:,2), u0(:,2), u1(:,2) );  
    u0 = u1;
    s0 = s1;
    J0 = J1;
    checkX = all(abs(deltaX(:)) <= resolution);
    checkZ = all(abs(deltaZ(:)) <= resolution);
    if checkX && checkZ
        disp( 'KICK OUT' );
        break
    elseif checkX  % THIS IS FOR Z
        delta = deltaZ;
        u0z = u0(:,2); 
        for k = j:decision
            tempBot.state = robot.state;
            %u0z
            %delta
            u1z = u0z - delta;
            u1z( u1z >=  1) =  1; 
            u1z( u1z <= -1) = -1;
            %u1z
            if sum( all( u0z == u1z, 2 ) ) > 0
                %u1z
                %u0z
                %delta
                [ u1z ] = thresholdInput( u0z, u1z );
            end
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
    elseif checkZ % THIS IS FOR X
        delta = deltaX;
        u0x = u0(:,1);
        for k = j:decision
            tempBot.state = robot.state;
            u1x = u0x - delta;
            u1x( u1x >=  1) =  1; 
            u1x( u1x <= -1) = -1;
            if sum( all( u0x == u1x, 2 ) ) > 0
                [ u1x ] = thresholdInput( u0x, u1x );
            end
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
%disp(deltaX);
%disp(deltaZ);
disp(u1);
disp(count);
disp('************************************************');

return

end