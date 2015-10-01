%%% spectral.m
%%% Daniel Fernández, Brad Ling
%%% June 2015
%%% Computes spectral information of input time domain  signal using Fast
%%% Fourier Transforms (FFT).  "S" is the spectral density and "F" is the
%%% frequency of the wave filed.  S relates to the amplitude of the signal
%%% by: S = (A/sqrt(2))^2
%%% If x is two dimensional it is assumed that each row is a signal.
%%% ts must be either a scalar or have the same number of elements as there
%%% are signals. Otherwise an error is thrown.
%%% [ S, F ] = spectralanalysis( x, ts, ... )
%%% x  - 1D or 2D signal
%%% ts - sample time (delta time)


function [ S, F, outputArg] = spectral( x, ts )
% Check input sizes
if size(x,2) == 1 && size(x,1) > 1
    x = x';
end

if size(ts,2) == 1 && size(ts,1) > 1
    ts = ts';
end

if size(ts,1) == 1 && size(x,1) > 1
    ts = linspace(ts, ts, size(x,1))';
end

% Run FFT
nCols = size(x,2);
X     = fft(x,[],2);
Xmag  = abs(X./nCols);

% Convert FFT results to spectral results
% If N is ODD
if mod(nCols,2) == 1
    mid = ceil(nCols/2);
    S = [Xmag(:,1)  2.*Xmag(:,2:mid)./sqrt(2)] .^2;
% if N is even - extra center term at the fold
else
    mid = nCols/2;
    S = [Xmag(:,1)  2.*Xmag(:,2:mid)./sqrt(2)  Xmag(:,mid+1)./sqrt(2)] .^2;
end

% calculate freq vector
F = (1./ts) * ( (0:(size(S,2))-1) ./ (nCols) );

% calculate phase angles
if nargout == 3
    outputArg{1} = angle(X(1:length(S)));
end

end