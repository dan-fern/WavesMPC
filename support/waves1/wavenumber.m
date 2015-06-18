%%% wavenumber.m
%%% Daniel Fernández
%%% 27 November 2013
%%% Wavenumber.m uses LWT to compute instantaneous wave number.  See D&D 
%%% for formulaic derivations

function k = wavenumber(h,k0)
mu0 = k0 * h;
muS = (mu0 + (mu0.^1.986) * exp(-1.863 - 1.198 * mu0.^1.366)) / sqrt(tanh(mu0));
mu = (muS.^2 + mu0 * cosh(muS).^2) / (muS + 0.5 * sinh(2 * muS));
k = mu / h;
end

