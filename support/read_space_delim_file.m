%%% read_space_delim_file.m
%%% Bradley Ling, edited by Daniel Fernández
%%% June 2015
%%% This function reads in a space delimited file of all numeric data if 
%%% the number of lines is known.  


function [ fileContents ] = read_space_delim_file( filename,nLines )

fid  = fopen(filename, 'r');
format  = repmat('%f32', 1, nLines);
fileContents = textscan(fid, format, ...
    'delimiter', ' ', 'MultipleDelimsAsOne', true);
[~] = fclose(fid);

fileContents = cell2mat(fileContents);

end