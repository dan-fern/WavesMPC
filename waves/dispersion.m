%%% dispersion.m 
%%% Daniel Fernández
%%% May 2015
%%% Solves the dispersion relation for a given wave.  Uses symbolic toolbox
%%% which has notable overhead.  Outputs wave frequency, w, wave length, L,
%%% and wave number, k.


function [ solw, solL, solk ] = dispersion( d, T, g )

solw = zeros(1, numel(T)); 
solL = zeros(1, numel(T)); 
solk = zeros(1, numel(T));

for j = 1:numel(T)
    wGuess = 2 * pi / T(j);
    LGuess = g * T(j)^2 * (tanh(wGuess^2 * d / g)^(3/4))^(2/3) / (2 * pi);
    kGuess = 2 * pi / LGuess;

    syms w L k

    [ sol ] = vpasolve(...
         w == sqrt(g * k * tanh(k * d)), ...
         L == g * T(j)^2 * (tanh(w^2 * d / g)^(3/4))^(2/3) / (2 * pi), ...
         k == 2 * pi / L, ...
         w, L, k, [wGuess, LGuess, kGuess]);

    solw(j) = single(sol.w);
    solL(j) = single(sol.L);
    solk(j) = single(sol.k);

end

return

end