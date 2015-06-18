%%% waveheight.m
%%% Daniel Fernández
%%% 27 November 2013
%%% Waveheight.m uses LWT to compute instantaneous wave height.  See D&D 
%%% for formulaic derivations

function H = waveheight(theta0,theta,H0,C0,h,k,T)
L = 2 * pi / k;
C = L / T;
n = 0.5 * (1 + (2 * k * h) / sinh(2 * k * h));
Cg = n * C;
H = H0 * sqrt(C0 / 2 / Cg) * sqrt(cosd(theta0) / cosd(theta));
end