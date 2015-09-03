function [ input1 ] = thresholdInput( input0, input1 )

sharedVal = all(input0 == input1,2);

while sharedVal ~= 0
    input1( input0 ==  1 ) =  1 - 0.0000001;
    input1( input0 == -1 ) = -1 + 0.0000001;
    input1( input1 >=  1) =  1; 
    input1( input1 <= -1) = -1;
    sharedVal = all(input0 == input1,2);
end

return

end