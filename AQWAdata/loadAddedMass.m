function [ Mx, Mz ] = loadAddedMass( z )

fileName = horzcat(num2str(z), 'z.lis');
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