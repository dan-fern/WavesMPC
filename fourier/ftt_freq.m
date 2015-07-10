% This function calculates the fourier frequencies that will be output by
% the fft function in matlab
%
% Inputs:  [N] = Number of samples in the record
%          [dt] = Sampling Interval
%
% Outputs: [CI_bnds] = Fourier Frequencies for which fft will output data.
%
%%%%%%%%%%%%%%%%%%
% Kai Parker
% May 2nd, 2015
%%%%%%%%%%%%%%%%%%%


function [f] = ftt_freq(N,dt)

if mod(N,2) == 0 
    f = [0:1:N/2-1,(-N/2):1:-1]./(dt.*N);
else
    f = [0:1:(N-1)/2,-(N-1)/2:1:-1]./(dt.*N);
end
