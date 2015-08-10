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