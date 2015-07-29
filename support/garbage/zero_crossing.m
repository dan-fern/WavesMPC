function [res,names,waves]=zero_crossing(data,frequency,threshold)
% Zero crossing analysis of wave data
%
%    ZERO_CROSSING (DATA, FREQUENCY)
%    ZERO_CROSSING (DATA, FREQUENCY, THRESHOLD)
%    RESULT = ZERO_CROSSING (...)
%    [RESULT, NAMES] = ZERO_CROSSING (...)
%
% DATA is the input array of water elevation (a time column will be
% ignored). It can also be an cell array data. Any linear trend or 
% mean will be removed. If PT data are used, the pressure attenuation
% must be corrected with PR_CORR before calling the present function.
% The optional third argument is the THRESHOLD for a crest or trough 
% to be considered; if not given, a value of 1% of Hmax is assumed.
%
% Without output argument, the wave paramenter are display on the 
% screen and the histrograms of wave height and wave period are
% plotted.
%
% With ONE output argument, RESULT is a structure with different fields: 
% Significant wave height, Mean wave height, 1/10th wave height, Maximum wave
% height, Mean wave period, Significant period and a table "wave" with 
% following columns 1: wave heights, 2: periods.
% With TWO output argument, RESULT is an horizontal array (same results but
% without the table) and NAMES is an cell array with the name of the wave parameters.

% written by Urs Neumeier
% version 1.06
error(nargchk(2,3,nargin))          % check argument
if frequency <= 0
    error('Frequency must be greather than zero')
end
if iscell(data)
    for i=1:length(data)
        if nargin==2
            [res(i,:),names]=zero_crossing(data{i},frequency);
        else
            [res(i,:),names]=zero_crossing(data{i},frequency,threshold);
        end
    end
    return
end

if size(data,2)==2 & all(data(:,1)>720000) & all(data(:,2)<740000)
    data(:,1)=[];
end 
% the function was written for zero upward-crossing. 
% To have zero downward-crossing (recommended) leave the next line uncommented
data=-data;

names={'H_significant','H_mean','H_10','H_max','T_mean','T_s'}; % initialise output arguments
res=[NaN NaN NaN NaN NaN NaN];

data=detrend(data);                 % find zero crossing avoiding zero values 
d0=data(data~=0);
back0=1:length(data);
back0=back0(data~=0);
f=find(d0(1:end-1).*d0(2:end)<0);
crossing=back0(f);
if data(1)>0                        % reject first crossing if it is downward
    crossing(1)=[];
end
crossing=crossing(1:2:end);         % this are the zero up-ward crossing
wave=zeros(length(crossing)-1,4);   % calculate crest, trough and period of each wave
% wave is a 4 columns matrix with wave height, wave crest, wave trough and wave period
for i=1:length(crossing)-1
    wave(i,2)= max(data(crossing(i):crossing(i+1)));
    wave(i,3)= -min(data(crossing(i):crossing(i+1)));
end
if size(wave,1) >= 1   % if no wave was found, do nothing
    wave(:,4)=diff(crossing')/frequency;
    if nargin<3                         % define threshold for wave
        threshold=0.01*max(wave(:,2)+wave(:,3));
    else
        if threshold < 0
            error ('Wave threshold must not be negative')
        end
    end
    i=0;                                % remove waves that are too small
    while i < size(wave,1)              % by joining then to adjacent wave
        i=i+1;
        if wave(i,2)<threshold
            if i~=1
                wave(i-1,2:4)=[max(wave(i-1:i,2:3)) sum(wave(i-1:i,4))];
            end
            wave(i,:)=[];
        elseif wave(i,3)<threshold
            if i~=size(wave,1)
                wave(i,2:4)=[max(wave(i:i+1,2:3)) sum(wave(i:i+1,4))];
                wave(i+1,:)=[];
            else
                wave(i,:)=[];
            end
        end
    end

    % wave has 1: wave height, 2: wave crest (Hcm), 3: wave trough (Htm), 4: period.
    wave(:,1)= sum(wave(:,2:3)')';      % now we have all waves to be considered, calculation of height
    nb=size(wave,1);                    % calculation of the wave statistics
	wave_unsorted=wave;
    wave=sortrows(wave);		% in ascending order	
    wave=flipud(wave);			% in descending order
    old_warning_state=warning('off');
    res(1)=mean(wave(1:round(nb*1/3),1));   % h_significant
    res(2)=mean(wave(:,1));                 % h_mean
    res(3)=mean(wave(1:round(nb*0.1),1));   % h_10
    res(4)=max(wave(:,1));                  % h_max
    res(5)=mean(wave(:,4));                 % mean_period
    res(6)=mean(wave(1:round(nb*1/3),4));   % T_significant
    warning(old_warning_state);
end

if nargout==0                       % if no output argument, display results
    fprintf(['Significant wave height %g\n'...
         'Mean wave height        %g\n'...
         '1/10th wave height      %g\n'...
         'Maximum wave height     %g\n'...
         'Mean wave period        %g\n'...
         'Significant period      %g\n'],res);
    figure
	if nb<100
		nb_bin=10;
	elseif nb<150
		nb_bin=15;
	else
		nb_bin=20;
	end
    subplot(2,1,1);
    hist(wave(:,1),nb_bin)
    set(gca,'ytick',nb*(0:0.05:1),'yticklabel',sprintf('%d%%|',0:5:100))
    title 'wave height'
    subplot(2,1,2);
    hist(wave(:,4),nb_bin)
    set(gca,'ytick',nb*(0:0.05:1),'yticklabel',sprintf('%d%%|',0:5:100))
    title 'wave period'
    clear res names
else
    if nargout==1
        s=setfield([],names{1},res(1));
        for i=2:length(res)
            s=setfield(s,names{i},res(i));
        end
        s.wave=wave_unsorted(:,[1 4]);
        res=s;
        clear names
    end
end


