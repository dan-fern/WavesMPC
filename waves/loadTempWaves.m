%%% loadTempWaves.m 
%%% Daniel Fernández
%%% May 2015
%%% Creates a wave field given a set of wave height, H, period, T, and
%%% phase, E values.  Error checks on number of elements in each set.  d is
%%% the depth, theta is the wave angle, is 0 in 2D, and rho is the density
%%% of seawater at 1030 kg/m^3.

function [ spectra ] = loadTempWaves( )

spectra.d = 50;
spectra.T = [ 10, 8, 12, 11, 6, 7, 9, 25 ];
spectra.H = [ 1.8, 0.9, 1.6, 1.3, 0.4, 0.5, 1.1, 0.7 ];
spectra.E = [ -pi/2, -pi/4, -5*pi/8, 4*pi/13, -pi/15, pi/3, -pi/18, -7*pi/4 ];
spectra.theta = 0;
spectra.rho = 1030;

if numel(spectra.T) == numel(spectra.H) && numel(spectra.T) == numel(spectra.E)
    return
else
    disp('BAD WAVES!!');
end

end