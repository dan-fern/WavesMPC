%%% loadWaves.m
%%% Daniel Fernández
%%% June 2015
%%% loads AWACS .wad file containing time series water elevation data as a 
%%% structure.  Some changes to be made include: breaking up long time 
%%% series into segments, extract Hs, Te, and other major parameters for 
%%% each, and get anything that might be a NNet input.  Does some basic 
%%% data checking to throw out bad points.  Thanks to Brad Ling, MIME, for 
%%% assistance.  

function [ waves ] = loadWaves(varargin)
if nargin == 0
    saveFlag = true;
else
    saveFlag = varargin{1};
end

% Read text file
% Note I reformatted the raw space delimited ASCII file into a csv file in
% bash for easier parsing.  I would like to update this routine so it can 
% handle the raw file

% Read .wad file
wadFile = '.\Waves\buoydata\awacs\wpr\AWAC1302wpr.wad';
wadData = read_space_delim_file(wadFile,17);
astDist1 = single(wadData(:,8));
astDist2 = single(wadData(:,9));

nSamples = 2400;  %This is for all parameters except AST, which is 2x

strFormat             = '%02i-%02i-%04i %02i:%02i:%02i';
temp                  = sprintf(strFormat, wadData(:,1:6)');
waves.dateTimeStr     = reshape(temp', 19, size(wadData,1))';

% Downsample to only one time stamp per data set
waves.dateTimeStr     = waves.dateTimeStr(1:nSamples:end,:);

% separate out month, day, year, hour, min, sec to respective bins.
waves.month           = double(wadData(1:nSamples:end,1));
waves.day             = double(wadData(1:nSamples:end,2));
waves.year            = double(wadData(1:nSamples:end,3));
waves.hour            = double(wadData(1:nSamples:end,4));
waves.min             = double(wadData(1:nSamples:end,5));
waves.sec             = double(wadData(1:nSamples:end,6));

% Combine surface elevation to make 2Hz data
tempHeave = nan(2 * size(astDist1,1), 1); length(tempHeave);
tempHeave(1:2:end) = astDist1;
tempHeave(2:2:end) = astDist2;

% Clean up memory
clear wadData temp astDist1 astDist2

% Reshape heave vector so that each row is one set of 2400 seconds.
% Note the sampling rate of this is 2Hz so that will be 4800 samples.

nCols = nSamples * 2;
nRows = length(tempHeave) / nCols;
waves.sensorFreq = nSamples / nCols;

waves.heave = reshape(tempHeave,nCols,nRows)';
clear tempHeave

% Build a full time series of the data.
startSerialDate  = datenum(waves.year, waves.month, waves.day, ...
                   waves.hour, waves.min, waves.sec);

waves.serialDate = repmat(startSerialDate,1,nCols) + ...
                   repmat((0:0.5:(nCols/2-0.5))./(24*3600), ... 
                   size(waves.heave,1),1);

% Now, condition the data
% Remove mean water elevation from each series
waves.meanDepth = mean(waves.heave,2);
waves.heave = waves.heave - repmat(waves.meanDepth, 1, size(waves.heave,2));

% Use mean water depth as a way to look for bad data
keepData = find(waves.meanDepth > 40);
waves.heave          = waves.heave(keepData,:);
waves.dateTimeStr    = waves.dateTimeStr(keepData,:);
waves.serialDate     = waves.serialDate(keepData,:);
waves.meanDepth      = waves.meanDepth(keepData);
waves.year           = waves.year(keepData);
waves.month          = waves.month(keepData);
waves.day            = waves.day(keepData);
waves.hour           = waves.hour(keepData);
waves.min            = waves.min(keepData);
waves.sec            = waves.sec(keepData);

% Spectral Analysis and sea state parameters. This can be pulled off the 
% AWACS, but for now I am calculating them myself. 

% Perform spectral analysis on all time series values
% Note sample rate of waves is 0.5 sec. or 2 Hz
[waves.specCalc, waves.freqCalc] = spectral(waves.heave, waves.sensorFreq);

% Calculate moments from spectral info
% Truncating frequencies lower than 0.01 Hz. why, why not?
idx = find(waves.freqCalc(1,:) > 0.005);

sum0 = sum(  waves.specCalc(:,idx)                              , 2);
sum1 = sum( (waves.specCalc(:,idx) .* waves.freqCalc(:,idx).^-1), 2);

% OK get Te and Hs from this
waves.HsCalc = 4 .* sqrt(sum0);
waves.TeCalc = sum1 ./ sum0;

% Lets free some memory
clear sum0 sum1 idx

% Calculate highest Wave height
waves.Hmax = max(waves.heave,[],2) - min(waves.heave,[],2);

% Ok lets read in some data from other files
%
% First read spectral data from .was file

wasFile = '.\Waves\buoydata\awacs\wpb\AWAC1302wpb.was';
wasData = read_space_delim_file(wasFile,98);

% move spectral data to awacs structure
waves.freq = wasData(1,:);
waves.spec = wasData(keepData+1,:);

clear wasData

% Ok now the .wap file

wapFile = '.\Waves\buoydata\awacs\wpb\AWAC1302wpb.wap';
wapData = read_space_delim_file(wapFile, 31);

% Extact out bad points
wapData = wapData(keepData,:);

%Extract summary values
waves.Hm0       = wapData(:,8);
waves.Hmax      = wapData(:,11);
waves.Hmean     = wapData(:,12);

waves.Tm02      = wapData(:,13);
waves.Tp        = wapData(:,14);
waves.Tz        = wapData(:,15);
waves.Tmax      = wapData(:,18);

waves.astMean   = wapData(:,24);

% Error code things
waves.noDetects = wapData(:,26);
waves.badDetect = wapData(:,27);
waves.errorCode = wapData(:,31);

%clear wapFileContents dateTime numFormat
clear wapData keepData


% Save data to file
% save structure to cd if saveFlag is true
if saveFlag == true;
    save('waves_timeSeriesData.mat','waves');
end


% Plot Hs and Te vs each other
figure
plot(waves.TeCalc,waves.HsCalc,'*')
grid on
xlabel('Energy Period T_e, (sec)')
ylabel('Significant Wave Height H_s, (m)')


end
