function [ pos2 ] = odeDisplacement( pos1, v, t ) 

nCalcs = numel(v) - 1;
displacement = 0;
for i = 1:nCalcs
    dt = t(i+1) - t(i);
    displacement = displacement + v(i+1) * dt; 
end

pos2 = pos1 + displacement;

return

end