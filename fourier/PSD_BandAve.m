% This function band averages Spectral values. The averageing is done with
% non-overlapping band averages. The band averaging also does not include
% the 0 frequency. 
%
% Inputs:  [Sj] = Power Spectral density
%          [fj] = Fourier frequencies that your PSD is calculated at.
%          [M]  = The number of degrees of freedom you would like your band
%                 band averaged estimate to have. The size of your bins
%                 will be M/2.  
%
% Outputs: [CI_bnds] = Confidence interval, each column corresponds to a S
%                      value and is the upper and lower value. Of note
%                      these values are in the format for using the
%                      "errorbar" command in matlab.
%
%%%%%%%%%%%%%%%%%%
% Kai Parker
% May 15th, 2015
%%%%%%%%%%%%%%%%%%%

function [Sj_filt,fj_filt] = PSD_BandAve(Sj,fj,M)

% Some problem variables
% Number of spectral estimates you have (this can either be one sided or
% two sided estimates)
N = length(Sj);   

% The Size of your bins
ave = M/2;

% Band Average
vec_end = ave+1:ave:N;
vec_beg = 2:ave:N;

Sj_filt = zeros(1, min([length(vec_end) length(vec_beg)]));
Sj_filt = zeros(1, min([length(vec_end) length(vec_beg)]));
for ii = 1:min([length(vec_end) length(vec_beg)])
    Sj_filt(ii) = mean(Sj(vec_beg(ii):vec_end(ii)));
    fj_filt(ii) = mean(fj(vec_beg(ii):vec_end(ii)));
end

