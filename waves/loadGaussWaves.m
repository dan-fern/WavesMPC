%%% loadGaussWaves.m 
%%% Daniel Fernández
%%% May 2015
%%% functions similarly to loadTempWaves( ) except attaches Gaussian noise
%%% to wave height, H, period, T, and phase, E values based on SNR values.


function [ waves ] = loadGaussWaves( noiseH, noiseT, noiseE, count )

waves = loadTempWaves( );
waves.H = awgn( waves.H, noiseH );
waves.T = awgn( waves.T, noiseT );
waves.E = awgn( waves.E, noiseE );

if count ~= 1
    [ waves.w, waves.L, waves.k ] = dispersion( waves.d, waves.T, 9.81 );
else
    return
end

end