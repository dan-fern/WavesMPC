%%% getJacobian.m 
%%% Daniel Fernández
%%% August 2015
%%% takes in two cost vectors and control vectors and computes the jacobian
%%% for the entire set.  Includes some basic error checking to prevent the
%%% controller from crashing at the thresholds.  Uses vector division.


function [ delta ] = getJacobian( cost0, cost1, input0, input1 )

delta = ( cost1 - cost0 ) ./ ( input1 - input0 );

delta( delta ==  Inf ) =  1;
delta( delta == -Inf ) = -1;
temp = isnan( delta );
delta( temp == 1 ) =  0;%0.000001;
%delta( delta == 0 ) = 0.000001;

return

end