function [ solw, solL, solk ] = dispersion( d, T, g )

syms w L k

[ sol ] = vpasolve(...
     w == sqrt(g * k * tanh(k * d)), ...
     L == g * T^2 * (tanh(w^2 * d / g)^(3/4))^(2/3) / (2 * pi), ...
     k == 2 * pi / L, ...
     w, L, k);

solw = single(sol.w);
solL = single(sol.L);
solk = single(sol.k);
 
return

end