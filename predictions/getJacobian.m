function [ delta ] = getJacobian( cost0, cost1, input0, input1 )

delta = ( cost1 - cost0 ) ./ ( input1 - input0 );

delta( delta ==  Inf ) =  1;
delta( delta == -Inf ) = -1;
temp = isnan( delta );
delta( temp == 1 ) =  0;%0.000001;
%delta( delta == 0 ) = 0.000001;

return

end