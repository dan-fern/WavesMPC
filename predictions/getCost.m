%%% getCost.m 
%%% Daniel Fernández
%%% August 2015
%%% Compares target state and current state and returns cost.


function [ cost ] = getCost( target, state )

cost = ( state - target ) ^ 2;

return

end