%%% loadAddedMass.m 
%%% Daniel Fernández
%%% July 2015
%%% Reads in AQWA data and searches text for specific values, in this case
%%% the added mass parameters for x and z.  This script is not as necessary
%%% since added mass values did not change throughout the water column,
%%% however, MATLAB is really bad at scouring for specific phrases, so this
%%% script may have some added benefits in other applications, or as the
%%% controller is further developed.  Ansys spits out one .LIS file per
%%% simulation and it contains all the data, so this script could be
%%% expanded to take in new values.  z parameter is the current depth of
%%% the robot. 


function [ Mx, Mz ] = loadAddedMass( z )

z = abs(z);

if z >= 5 && z < 45
    fileZ = round(z, -1);
elseif z < 5
    fileZ = 10;
else
    fileZ = 40;
end

fileName = horzcat(num2str(fileZ), 'z.lis');
fid = fopen(fileName,'r');
allText = textscan(fid, '%s','Delimiter','');
fclose(fid);
allText = allText{:};

strID = ~cellfun(@isempty, strfind(allText,'ADDED MASS'));

A = find(strID==1);

[ data ] = cell2mat(textscan( allText{A(2)+5}, '%*f %*f %f %*f %f', 1));

Mx = data(1) / 1;
Mz = data(2) / 2;

clear C

return

end