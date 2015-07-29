function [res,names,spect] = wavesp(PT,Zpt,Fs,varargin) % Corr_lim,Noseg,option)
% Spectral wave-parameters from PT data after correction of the pressure attenuation
% 
%    WAVESP(PT,Zpt,Fs,Corr_lim,Noseg,option)
%    RES = WAVESP...
%    [RES, NAMES] = WAVESP...
%    [RES, NAMES, SPECT] = WAVESP...
%
% Input: PT = array with the PT data (time column is ignored, can be cell array or matrix)
%        Zpt = height of PT from seabed (m), can be array if PT is cell array or matrix,
%              if empty([]) no pressure attenuation will be calculated
%        Fs 	= Sampling frequency (Hz)
%        Corr_lim = [min max] frequency for attenuation correction  
%                       (Hz, optional, default [0.05 0.33])
%        Noseg	= No of segments for SPECTRUM function (optional, default 4)
%        option = optional, specify which wave parameters are return. s: some spectral,
%               a: all spectral, z: all zero-crossing, n: no zero-crossing, default is "sz"
%
% Without output argument, the wave parameters are displayed on the screen and the 
% S(f) (spectral density) is plotted.
% With one, two or three output arguments, are returned respectively :
% RES, the waves parameters (in an horizontal array, several rows if PT is a cell array or matrix
% NAMES, a cell array of strings specifying the name of each parameters in RES,
%        NAMES should always be checked, because different versions of the present 
%        function can return different sets of the wave parameters
% SPECT, a 2-column matrix with the spectral density (column 1) and the 
%        corresponding frequencies (column 2)

% written by Urs Neumeier, 2003
% modified from Coast07.m written by T Mason, UPCE, 1999 (psd modified 7/99)							
% If the functions PR_CORR and ZERO_CROSSING are accessible, the zero-crossing 
% parameters are also calculated and returned.
% version 1.11

%*************************************************************
% Preliminary operations

error(nargchk(3,6,nargin))
do_zero_crossing=logical(1);
do_all_spectral=logical(0);
if length(varargin)>0 & ischar(varargin{end})
	if any(lower(varargin{end})=='s')
		do_all_spectral=logical(0);
	end
	if any(lower(varargin{end})=='a')
		do_all_spectral=logical(1);
	end
	if any(lower(varargin{end})=='n')
		do_zero_crossing=logical(0);
	end
	if any(lower(varargin{end})=='z')
		do_zero_crossing=logical(1);
	end
	varargin(end)=[];
end
option_str=char([115-18*do_all_spectral 110+12*do_zero_crossing]);
if length(varargin)<1 | isempty (varargin{1})% process Corr_lim or take default values
    min_frequency = 0.05;		% mininum frequency, below which no correction is applied (0.05)
    max_frequency = 0.33;		% maximum frequency, above which no correction is applied (0.33)
else
	Corr_lim=varargin{1};
    if diff(Corr_lim)<=0 | any(Corr_lim<0) | length(Corr_lim)~=2
        error('Incorrect Corr_lim argument.');
    end
    min_frequency = Corr_lim(1);
    max_frequency = Corr_lim(2);
end    
if length(varargin)<2		% take default value if Noseg absent
    Noseg = 4;	    			% No of segments (for spectrum)
else
	Noseg = varargin{2};
end

if iscell(PT)	% recursive calls if PT is a cell array, Zpt can be an array with 
    for i=1:length(PT)   % one value for each cell element
        [res(i,:),names]=wavesp(PT{i},Zpt(min(i,length(Zpt))),Fs,...
							[min_frequency max_frequency],Noseg,option_str);
    end
    return
end    
    
if size(PT,1)>1 & size(PT,2)>=2 & all(PT(:,1)>720000) & all(PT(:,1)<740000)
    PT(:,1)=[];			% remove first column if it contains only MATLAB time
end
if min(size(PT))>1	% recursive calls if PT is a matrix, Zpt can be an array with
    for i=1:size(PT,2)   % one value for each cell element
        [res(i,:),names]=wavesp(PT(:,i),Zpt(min(i,length(Zpt))),Fs,...
							[min_frequency max_frequency],Noseg,option_str);
    end
    return
end	

if any(isnan(PT))		% do nothing if any nan value exist in PT
    if do_all_spectral
        if do_zero_crossing
        	res=repmat(nan,1,15);
        else
            res=repmat(nan,1,9);
        end
    else
        if do_zero_crossing
        	res=repmat(nan,1,10);
        else
            res=repmat(nan,1,4);
        end
    end            
	names={};
	return
end

%*************************************************************
% Prepare data for spectral analysis

m = length(PT);				
M = fix(m/Noseg/2)*2;	% length of segment
h = mean(PT);			% mean water depth
PT = detrend(PT);

%***********************************************************%
% Calculation of spetral density 

[P,F] = spectrum(PT,M,M/2,[],Fs);   % gives spectrum from 0 to Fnyq
p = P(2:end,1)*2/Fs;				% normalisation so that psd=cov(7/99), and remove first						
F(1) = [];							% element of P and F, which contains no usefull information
                      
if ~isempty(Zpt)						% if Zpt is empty, no attenuation correction
    K = wavenumL(F,h);  % calculates wave number for each frequency using function defined below
    Kpt = cosh(K*Zpt)./cosh(K*h);		% correction factor of spectrum for pressure attenuation
    Kpt(F<min_frequency | F>max_frequency) = 1;	% only for selected range
	Kpt(Kpt<0.2)=0.2;					% correction factor never higher than 5
					% linear decrease of correction above f>max_frequency
	fb_max=max(find(F<=max_frequency));
	fKlin=[fb_max:min(fb_max+fix(length(K)/10),length(K))];
	Kpt(fKlin)=(length(fKlin):-1:1)*(Kpt(fb_max)-1)/length(fKlin)  + 1; 
    Snf = p./(Kpt.^2);					% apply the correction				  
else
    Snf = p;
end

%*************************************************************
% Calculation of wave parameters

% frequence range over which the spectrum is integrated for calculation of the moments
integmin=min(find(F >= 0));	 % this influences Hm0 and other wave parameters
integmax=max(find(F <= max_frequency*1.5 ));

df = F(1);							% bandwidth (Hz)
for i=-2:4							% calculation of moments of spectrum
	moment(i+3)=sum(F(integmin:integmax).^i.*Snf(integmin:integmax))*df;
%	fprintf('m%g  =  %g\n',i,moment(i+3));
end
         
m0 = moment(0+3);
Hm0 = 4 * sqrt(m0);                 % Hsig by spectral means
[D,E] = max(Snf);                   % Frequency at max of spectrum
fpeak = F(E);											
Tp = 1/fpeak;                       % Peak period

if do_all_spectral
	T_0_1 = moment(0+3)/moment(1+3);    % average period m0/m1
	T_0_2 = (moment(0+3)/moment(2+3))^0.5;% average period (m0/m2)^0.5
	T_pc = moment(-2+3)*moment(1+3)/(moment(0+3)^2); % calculated peak period
	EPS2 = (moment(0+3)*moment(2+3)/moment(1+3)^2-1)^0.5;      % spectral width parameter
	EPS4 = (1 - moment(2+3)^2/(moment(0+3)*moment(4+3)))^0.5; % spectral width paramenter
end

%*************************************************************
% Calculation of zero-crossing parameters

if exist('pr_corr.m','file') & exist('zero_crossing.m','file') & do_zero_crossing
	if ~isempty(Zpt)				% if Zpt is empty, no attenuation correction
 	   pt_surf = pr_corr(PT,h,Fs,Zpt,M,[min_frequency max_frequency]); %correct PT for attenuation
	else
 	   pt_surf=PT;
	end
	[resZcross,namesZcross]=zero_crossing (pt_surf,Fs); % do the zero-crossing analysis
else
	resZcross=[];
	namesZcross={};
end

%*************************************************************
% Output the results

% put results together
if ~do_all_spectral
	res = [h,Hm0,Tp,m0,resZcross];%,cov(pt)];
	names = {'h','Hm0','Tp','m0',namesZcross{:}};%,'cov(pt)'};
else
	res = [h,Hm0,Tp,m0,T_0_1,T_0_2,T_pc,EPS2,EPS4,resZcross];%,cov(pt)];
	names = {'h','Hm0','Tp','m0','T_0_1','T_0_2','T_pc','EPS2','EPS4',namesZcross{:}};%,'cov(pt)'};
end

if nargout==0
    for i=1:length(res)
		fprintf('%14s   %g\n',names{i},res(i));
    end
    figure
	if exist('mov_average.m','file')
	    loglog(F,mov_average(Snf,0))
	else
	    loglog(F(2:end),Snf(2:end))
	end
    xlabel 'Frequency Hz'
    ylabel 'S(f) m^2/Hz'
    clear res names
elseif nargout==1	% if one output argument, return only res,
    clear names		% if two output arguments, return res and names
elseif nargout >2	% if three output arguments, return the spectral density in addition
	spect=[Snf,F];
end




function y=wavenumL(f,h);
% y=wavenum(f,h): FUNCTION for the calculation of the wavenumber.
%                   The dispertion relation is solved using a 
%                   polynomial approximation.
%                   f, wave frequency; f=1/T.
%                   h, water depth (in m).
%
%       George Voulgaris, SUDO, 1992
f=f(:);
w=2*pi*f;
dum1=(w.^2)*h/9.81;
dum2=dum1+(1.0+0.6522*dum1+0.4622*dum1.^2+0.0864*dum1.^4+0.0675*dum1.^5).^(-1);
dum3=sqrt(9.81*h.*dum2.^(-1))./f;
y=2*pi*dum3.^(-1);