function [ cost ] = getCost( target, state )

cost = ( state - target ) ^ 2;

return

end