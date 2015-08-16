function [ cost ] = getCost( target, state )

costX = ( state(1) - target.px ) ^ 2;
costZ = ( state(2) - target.pz ) ^ 2;

cost = [ costX, costZ ];

return

end