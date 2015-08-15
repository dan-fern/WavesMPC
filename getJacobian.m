function [ delta ] = getJacobian( cost0, cost1, input0, input1 )

delta = ( cost1 - cost0 ) ./ ( input1 - input0 );

return

end