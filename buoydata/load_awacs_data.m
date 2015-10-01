%%% load_awacs_data.m 
%%% Daniel Fernández
%%% April 2015
%%% ARCHIVE: original awacs loader script, not clean at all.  This script
%%% was abandoned as I moved toward a generated wave field and not buoy
%%% data.  Still a valuable reference to translate heave data from AWACS.


function [ awacs ] = load_awacs_data(varargin)
%Loads AWACS .wad file containing time series water elevation data
%   output is a structure
%   NEEDS DOCUMENTATION


if nargin == 0
    saveFlag = true;
else
    saveFlag = varargin{1};
end

wadFile = './awacs/wpr/AWAC1302wpr.wad';


% Changes that need to be made
% Break up long time series into segments
% extract Hs, Te, and other major parameters for each
% Get anything that might be a NNet input

% Do some data checking as well

% Read text file
% Note i reformatted the raw space delimited ASCII file into a csv file in
% bash for easier parsing.
%
% I would like to update this routine so it can handle the raw file

% read wad file.
wadFileContents = read_space_delim_file(wadFile,17);

astDist1 = single(wadFileContents(:,8));
astDist2 = single(wadFileContents(:,9));

nSamplesPerSet = 2400;  % This is for all paramters except AST, which is 2x

% Built date time stamp

% awacs.dateTime = cell(size(wadFileContents,1)/nSamplesPerSet, 1);
% awacs.dateTimeNumber = uint16( nan(size(wadFileContents,1)/nSamplesPerSet, 1) );
% strFormat = '%02i-%02i-%04i %02i:%02i:%02i';
% numFormat = '%0.2i%0.2i%0.2i%0.2i%0.2i%0.2i';
% j = 1;
% for i=1:nSamplesPerSet:size(wadFileContents,1)
%     awacs.dateTime{j} = sprintf(strFormat,wadFileContents(i,1:6));
%     awacs.dateTimeNumber(j) = str2double( sprintf(numFormat,wadFileContents(i,1:6)) );
%     j = j + 1;
% end


strFormat             = '%02i-%02i-%04i %02i:%02i:%02i';
temp1                 = sprintf(strFormat, wadFileContents(:,1:6)');
awacs.dateTimeStr     = reshape(temp1', 19, size(wadFileContents,1))';



% Downsample to only one time stamp per data set
awacs.dateTimeStr     = awacs.dateTimeStr(1:nSamplesPerSet:end,:);

% seperate out month, day , year, hour, min, sec to their own thing.
awacs.month           = double(wadFileContents(1:nSamplesPerSet:end,1));
awacs.day             = double(wadFileContents(1:nSamplesPerSet:end,2));
awacs.year            = double(wadFileContents(1:nSamplesPerSet:end,3));
awacs.hour            = double(wadFileContents(1:nSamplesPerSet:end,4));
awacs.min             = double(wadFileContents(1:nSamplesPerSet:end,5));
awacs.sec             = double(wadFileContents(1:nSamplesPerSet:end,6));





% clear out file contents
clear wadFileContents temp temp1 temp2;

% Combine surface elevation to make 2Hz data
heave = nan(2 * size(astDist1,1), 1);
heave(1:2:end) = astDist1;
heave(2:2:end) = astDist2;

% Lets clean up some memory
clear astDist1 astDist2;

% reshape heave vector so that each row is one set of 2400 seconds.
% Note the sampling rate of this is 2Hz so that will be 4800 samples.

nCols = 4800;
nRows = length(heave) / nCols;

awacs.heave = reshape(heave,nCols,nRows)';
clear heave;

% Lets build a full time series of the data.
startSerialDate = datenum(awacs.year,...
                          awacs.month,...
                          awacs.day,...
                          awacs.hour,...
                          awacs.min,...
                          awacs.sec);

awacs.serialDate = repmat(startSerialDate,1,nCols) + ...
                   repmat((0:0.5:(nCols/2-0.5))./(24*3600),size(awacs.heave,1),1);

% Ok lets condition the data

% Remove mean water elevation from each series
awacs.meanWaterDepth = mean(awacs.heave,2);
awacs.heave = awacs.heave - ...
    repmat(awacs.meanWaterDepth, 1, size(awacs.heave,2));


% Use mean water depth as a way to look for bad data
idxKeep = find(awacs.meanWaterDepth > 40);

awacs.heave          = awacs.heave(idxKeep,:);
awacs.dateTimeStr    = awacs.dateTimeStr(idxKeep,:);
awacs.serialDate     = awacs.serialDate(idxKeep,:);
awacs.meanWaterDepth = awacs.meanWaterDepth(idxKeep);
awacs.year           = awacs.year(idxKeep);
awacs.month          = awacs.month(idxKeep);
awacs.day            = awacs.day(idxKeep);
awacs.hour           = awacs.hour(idxKeep);
awacs.min            = awacs.min(idxKeep);
awacs.sec            = awacs.sec(idxKeep);
% Look at mean water depth for
%
% Need to pull error codes to check for other bad data.
%



% Spectral Analysis, get sea state parameters too
% I know this could be pulled off the recorder but for now I am calculating
% them myself
%

% Perform spectral analysis on all time series values
%  Note sample rate of waves is 0.5 sec. or 2 Hz
[awacs.specCalc, awacs.freqCalc] = spectralanalysis(awacs.heave,0.5);


% Calculate moments from spectral info
%  Truncating frequencies lower than 0.01 Hz. why, why not?
idx = find(awacs.freqCalc(1,:) > 0.005);

M0  = sum(  awacs.specCalc(:,idx)                              , 2);
Mm1 = sum( (awacs.specCalc(:,idx) .* awacs.freqCalc(:,idx).^-1), 2);

% OK get Te and Hs from this
awacs.HsCalc = 4 .* sqrt(M0);
awacs.TeCalc = Mm1 ./ M0;

% Lets free some memory
clear M0 Mm1 idx


% Calculate highest Wave height
awacs.Hmax = max(awacs.heave,[],2) - min(awacs.heave,[],2);

% Ok lets read in some data from other files
%
% First read spectral data from .was file

wasFile = './awacs/wpb/AWAC1302wpb.was';
wasFileContents = read_space_delim_file(wasFile,98);

% move spectral data to awacs structure
awacs.freq = wasFileContents(1,:);
awacs.spec = wasFileContents(idxKeep+1,:);

clear wasFileContents

% Ok now the .wap file

wapFile = './awacs/wpb/AWAC1302wpb.wap';
wapFileContents = read_space_delim_file(wapFile, 31);

% Extact out bad points
wapFileContents = wapFileContents(idxKeep,:);

% Pull out date time stamps for each
%   Use to make sure that all points correspond
% numFormat             = '%02i%02i%04i%02i%02i%02i';
% wapDateTime           = sprintf(numFormat, wapFileContents(:,1:6)');
% awacs.wapDateTime     = reshape(wapDateTime', 14, length(idxKeep))';
% awacs.wapDateTimeNum  = uint16( str2double(wapDateTime) );

%Extract summary values
awacs.Hm0       = wapFileContents(:,8);
awacs.Hmax      = wapFileContents(:,11);
awacs.Hmean     = wapFileContents(:,12);

awacs.Tm02      = wapFileContents(:,13);
awacs.Tp        = wapFileContents(:,14);
awacs.Tz        = wapFileContents(:,15);
awacs.Tmax      = wapFileContents(:,18);

awacs.astMean   = wapFileContents(:,24);

% Error code things
awacs.noDetects = wapFileContents(:,26);
awacs.badDetect = wapFileContents(:,27);
awacs.errorCode = wapFileContents(:,31);

%clear wapFileContents dateTime numFormat
clear wapFileContents


% Save data to file
% save structure to cd if saveFlag is true
if saveFlag == true;
    save('awac_timeSeriesData.mat','awacs');
end


% Plot Hs and Te vs each other
figure
plot(awacs.TeCalc,awacs.HsCalc,'*')
grid on
xlabel('Enery Period T_e, (sec)')
ylabel('Significant Wave Height H_s, (m)')


end

function [fileContents] = read_space_delim_file(filename,nLines)
% This function reads in a space delimited file if the number of lines
% isknown. Also assumed that it isall numeric data.


fid  = fopen(filename, 'r');
format  = repmat('%f32', 1, nLines);
fileContents = textscan(fid, format, ...
    'delimiter', ' ', 'MultipleDelimsAsOne', true);
[~] = fclose(fid);

fileContents = cell2mat(fileContents);

end


function [ S, F, varargout] = spectralanalysis( x, ts )
%Computes Spectral information of input time domain signal using FFT
%   S is the spectral density and F is the frequencies. S relates to the
%   amplitude (A) of the signal component by
%     S = ( A/sqrt(2) )^2
%
%   If x is two dimensional it is assumed that each row is a signal.
%   ts must be either a scalar or have the same number of elements as there
%   are signals. Otherwise an error is thrown.
%
%   [ S, F ] = spectralanalysis( x, ts, ... )
%       x  - 1D or 2D signal
%       ts - sample time (delta time)

% Created on 11/29

% Check input sizes
if size(x,2) == 1 && size(x,1) > 1
    x = x';
end

if size(ts,2) == 1 && size(ts,1) > 1
    ts = ts';
end

if size(ts,1) == 1 && size(x,1) > 1
    ts = linspace(ts,ts,size(x,1))';
end

% Run FFT
N    = size(x,2);
X    = fft(x,[],2);
Xmag = abs(X./N);


% Convert FFT results to spectral results

% If N is ODD
if mod(N,2) == 1
    mid = ceil(N/2);
    S = [Xmag(:,1)  2.*Xmag(:,2:mid)./sqrt(2)] .^2;
% if N is even - extra center term at the fold
else
    mid = N/2;
    S = [Xmag(:,1)  2.*Xmag(:,2:mid)./sqrt(2)  Xmag(:,mid+1)./sqrt(2)] .^2;
end

% calculate freq vector
F = (1./ts) * ( (0:(size(S,2))-1) ./ (N) );


% calculate phase angles
if nargout == 3
    varargout{1} = angle(X(1:length(S)));
end