%%% getForecastBAD.m 
%%% Daniel Fernández
%%% August 2015
%%% Generates optimized set of control actions along a specified horizon.
%%% Similar to getForecast( ) except that the structure was going to be
%%% linewise downward.  That is as an optimized control is calculated for
%%% the next immediate time step, it is no longer recalculated and
%%% optimization takes place on the following time step until a vector for
%%% the entire horizon is generated.  This was conceived to save on
%%% calculation time.  It was never functional though, as there was a
%%% thresholding bug that I couldn't figure out. 


function [ u1, tCalc ] = getForecastBAD( t, robot, spectra, count, oldInput )

k = 0;
nRow = 1;
nTry = 1;
tempBot = robot;
tSteps = t.tSteps;
decision = 10000;
resolution = 0.005;

[ u0, s0, J0 ] = intializeForecast( t, robot, spectra, count, oldInput ); 
% u0
% s0
% J0

u1 = zeros( nRow, 2 );
s1 = zeros( size( s0 ) );
J1 = zeros( nRow, 2 );
delta = zeros( tSteps, 2 ) + resolution/1000;
tempBot.state = robot.state;
while nTry ~= decision && nRow ~= 3%tSteps + 1 %or decision criteria
    s1(1,1) = s0(1,1); 
    s1(1,2) = s0(1,2);
    u1(nRow,:) = u0(nRow,:) - delta(nRow,:);
    u1( u1 >  1) =  1; 
    u1( u1 < -1) = -1;
    if sum( all( u0(nRow,:) == u1(nRow,:), 2 ) ) > 0
        fprintf('NO!! ');
        fprintf(num2str(nTry));
        [ u1 ] = thresholdInput( u0(nRow,:), u1(nRow,:) );
    end
    tempCount = count + nRow - 1;
    [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
        s0(nRow,1), s0(nRow,2), spectra, tempBot.particles, tempCount );
    [ tempBot ] = mpcMoveRobot( t.dt, tempBot, spectra, tempCount, u1(nRow,:) );
    s1(nRow+1,1) = tempBot.state.px; 
    s1(nRow+1,2) = tempBot.state.pz;
    [ J1(nRow,1) ] = getCost( tempBot.DC.px, s1(nRow+1,1) );
    [ J1(nRow,2) ] = getCost( tempBot.DC.pz, s1(nRow+1,2) );
    if find(isnan(s1)==1) > 0
        str = ['balls... fails at ', num2str(nTry), ' decisions.'];
        disp(str);
        u1 = u0;
        break
    elseif mod( nTry, 25 ) == 0
        fprintf('%%');
    end
    [ deltaX ] = getJacobian( J0(nRow,1), J1(nRow,1), u0(nRow,1), u1(nRow,1) );
    [ deltaZ ] = getJacobian( J0(nRow,2), J1(nRow,2), u0(nRow,2), u1(nRow,2) );  
    u0(nRow,:) = u1(nRow,:);
    s0(nRow+1,:) = s1(nRow+1,:);
    J0(nRow,:) = J1(nRow,:);
    checkX = all(abs(deltaX(:)) <= resolution);
    checkZ = all(abs(deltaZ(:)) <= resolution);
    if checkX && checkZ
        str = [ 'KICK OUT of ', num2str(nRow), 'th step.' ];
        disp( str );
    elseif checkX  % THIS IS FOR Z
        delta(nRow,2) = deltaZ;
        u0z = u0(nRow,2); 
        for k = nTry:decision
            u1z = u0z - delta(nRow,2);
            u1z( u1z >=  1) =  1; 
            u1z( u1z <= -1) = -1;
            k
            delta(nRow,2)
            if sum( all( u0z == u1z, 2 ) ) > 0
                [ u1z ] = thresholdInput( u0z, u1z );
            end
            u0z
            u1z
            tempCount = count + nRow - 1;
            [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
                s0(nRow,1), s0(nRow,2), spectra, tempBot.particles, tempCount );
            [ tempBot ] = mpcMoveRobotZ( t.dt, tempBot, spectra, tempCount, u1z );
            s1(nRow+1,2) = tempBot.state.pz;
            [ J1(nRow,2) ] = getCost( tempBot.DC.pz, s1(nRow+1,2) );
            [ deltaZ ] = getJacobian( J0(nRow,2), J1(nRow,2), u0z, u1z );
            u0z = u1z;
            s0(nRow,2) = s1(nRow,2);
            J0(nRow,2) = J1(nRow,2);
            checkZ = abs(deltaZ(:));
            if checkZ(:) <= resolution
                disp( ' KICK OUTTA Z' );
                u1(nRow,2) = u1z;
                break
            else
                delta(nRow,2) = deltaZ;
                if mod( k, 25 ) == 0
                    fprintf('z');
                end
            end
        end
    elseif checkZ % THIS IS FOR X
        delta(nRow,1) = deltaX;
        u0x = u0(nRow,1);
        for k = nTry:decision
            u1x = u0x - delta(nRow,1);
            u1x( u1x >=  1) =  1; 
            u1x( u1x <= -1) = -1;
            if sum( all( u0x == u1x, 2 ) ) > 0
                [ u1x ] = thresholdInput( u0x, u1x );
            end
            tempCount = count + nRow - 1;
            [ tempBot.particles ] = getRobotParticles( t.t(tempCount), ...
                s0(nRow,1), s0(nRow,2), spectra, tempBot.particles, tempCount );
            [ tempBot ] = mpcMoveRobotX( t.dt, tempBot, spectra, tempCount, u1x );
            s1(nRow+1,1) = tempBot.state.px;
            [ J1(nRow,1) ] = getCost( tempBot.DC.px, s1(nRow+1,1) );
            [ deltaX ] = getJacobian( J0(nRow,1), J1(nRow,1), u0x, u1x );
            u0x = u1x;
            s0(nRow,1) = s1(nRow,1);
            J0(nRow,1) = J1(nRow,1);
            checkX = abs(deltaX(:));
            if checkX(:) <= resolution
                disp( ' KICK OUTTA X' );
                u1(nRow,1) = u1x;
                break
            else
                delta(nRow,1) = deltaX;
                if mod( k, 25 ) == 0
                    fprintf('x');
                end
            end
        end
    else
        delta(nRow,1) = deltaX;  
        delta(nRow,2) = deltaZ;
        nTry = nTry + 1;
        continue
    end
    nTry = nTry + 1;
    if checkX && checkZ && nRow ~= tSteps
        nRow = nRow + 1;
        J1 = vertcat( J1, [0,0] );
        u1 = vertcat( u1, [0,0] );
        %u0
        %u1
        %delta
    elseif checkX && checkZ && nRow == tSteps
        break
    else
        disp('out of place')
        continue
    end
end

fprintf(num2str(nTry));
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