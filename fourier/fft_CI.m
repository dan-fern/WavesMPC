% This function determines the confidence intervals for Spectral estimates.
%
% Inputs:  [S] = Power Spectral density
%          [M] = Degrees of freedom (2 for no band-averaging, 2*number of
%                frequencies averaged otherwise)
%           CI = Confidence for your estimate (e.g. 95 means 95 percent
%                confidence)
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

function [CI_bnds] = fft_CI(S,M,CI)

% See if M and CI are vectors or not
% If they are single values, then turn into vectors the size of S
if length(M) == 1;
    M = M*ones(size(S));
end

if length(CI) == 1;
    CI = CI*ones(size(S));
end

% Run through each S, M, CI pair.
alpha = zeros(size(S));
q = zeros(2,length(S));
alpha_bnds = zeros(2,length(S));
CI_bnds = zeros(2,length(S));
for i = 1:length(S)
    % Calculate the confidence intervals
    alpha(i) = (100-CI(i))/100;

    % Upper and lower bonds of our Confidence Interval
    alpha_bnds(1,i) = alpha(i)/2;
    alpha_bnds(2,i) = 1-(alpha(i)/2);


    % Find out the quantiles at these bounds
    q(:,i) = chi2inv(alpha_bnds(:,i),(M(i)*ones(size(alpha_bnds(:,i)))));

    CI_bnds(1,i) = S(i)-((M(i)/q(2,i)) * S(i));
    CI_bnds(2,i) = ((M(i)/q(1,i)) * S(i))-S(i);
end
