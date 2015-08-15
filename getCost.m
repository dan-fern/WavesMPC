function [ cost ] = getCost( target, state )

costX = ( state(1) - target(1) ) ^ 2;
costZ = ( state(2) - target(2) ) ^ 2;

cost = [ costX, costZ ];

return

end