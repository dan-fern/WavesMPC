function H=pr_corr(pt,h,Fs,zpt,M,Corr_lim)
% Correct a sea surface time-series for depth attenuation of pressure. 
%
%    SURFACE = PR_CORR(PT,H,Fs,Zpt,M,frequ_lim)
%
% Input: PT = sea surface elevation time series (detrended)
%        H = mean water depth (m)
%        Fs = sampling frequency (Hz)
%        Zpt = height of PT from seabed (m)
%        M = length of segment (optional, default: 512)
%        Corr_lim = [min max] frequency for attenuation correction (Hz, 
%                                                   optional, default [0.05 0.33])
%
% This function corrects a detrended sea surface time series for depth attenuation.
% Frequency correction from 0.05 to 0.33 Hz. The programme checks the length of the 
% input and zero pads as necessary.  After correction, the output vector is truncated 
% to the same length as the input.  
%
%    SURFACE = PR_CORR(PT,[],Fs,Zpt,M)
%
% Alternatively, if the second argument (H) is an empty matrix, PT should be the 
% sea-surface above bottom time-series. In this case, each segment of PT will be 
% linearly detrended, corrected for attenuation, and the linear trend added back before 
% constructing the result SURFACE.
%
%    SURFACE = PR_CORR([],H,Fs,Zpt,M)
%
% If the first argument (PT) is an empty matrix, the correction factor (theoretical and
% effectively used) for each frequency is returned.

% written by Urs Neumeier, 2003-2004
% Modified from the Pcorr3.m function written by T. Mason, SOC, January 1997
%
% PT can also be a matrix. In this case each column is processed separately. Zpt can then 
% be either a scalar, or an array with one value for each column of PT.
% NaN in PT are ignored during the processing but are returned in the output.
% version 1.09

max_attenuation_correction = 5; % normally the maximum attenuation correction should not be higher than 5
% higher value to process boat-waves for Jean Ellis
% max_attenuation_correction = 20; 

error(nargchk(4,6,nargin))
if isempty(zpt)	% if Zpt is empty, do nothing and return the unmodified data array
	H=pt;
	return
end
if nargin < 5
	M = [];
end
if nargin < 6
    min_frequency = 0.05;		% mininum frequency, below which no correction is applied (0.05)
    max_frequency = 0.33;		% maximum frequency, above which no correction is applied (0.33)
else
    if diff(Corr_lim)<=0 | any(Corr_lim<0) | length(Corr_lim)~=2
        error('Incorrect Corr_lim argument.');
    end
    min_frequency = Corr_lim(1);
    max_frequency = Corr_lim(2);
end

if min(size(pt))>1				% if pt is a matrice, process each column separately
	if length(zpt)~=1 & length(zpt)~=size(pt,2)
		error('Incorrect length of argument Zpt !')
	end
	H=zeros(size(pt));
	for i=1:size(pt,2)
		if length(zpt)==1
			H(:,i)=pr_corr(pt(:,i),h,Fs,zpt,M,Corr_lim);
		else
			H(:,i)=pr_corr(pt(:,i),h,Fs,zpt(i),M,Corr_lim);
		end
	end
	return
end

H_with_NaN = pt;			% remove NaN values
not_NaN = ~isnan(pt);
pt=pt(not_NaN);
pt_dimension=size(pt);
pt=pt(:);					% assures column array
do_detrend=isempty(h);
m = length(pt);

if nargin==4 | isempty(M)
	M=min(512,m);
end
if rem(M,2),error('M must be even'),end

Noverlap = M/2;						% length of overlap
N = ceil(m/M)*M;					% length of array zero-paded to nearest multiple of M

f = [NaN; (1:M/2)'*Fs/M];          % frequencies column vector

if ~do_detrend
	K = wavenumL(f,h);                 % calculates wave number for each frequency using 
	                                   % function defined below
	Kpt=cosh(K*zpt)./cosh(K*h);					% correction factor of spectrum for pressure
	if isempty(pt), H=Kpt;end
	Kpt(f<min_frequency | f>max_frequency) = 1;	% attenuation (0.05-0.33Hz only)
	Kpt(Kpt < 1/max_attenuation_correction) = 1/max_attenuation_correction;
							% correction factor never higher than max_attenuation_correction
					% linear decrease of correction above f>max_frequency
	fb_max=max(find(f<=max_frequency));
	fKlin=[fb_max:min(fb_max+fix(length(K)/10),length(K))];
	Kpt(fKlin)=(length(fKlin):-1:1)*(Kpt(fb_max)-1)/length(fKlin)  + 1; 
	Kpt(1)=1;
	Kpt(M:-1:M/2+2)=Kpt(2:M/2);			% second half of series is symetric  
	if isempty(pt)
		H=[f(2:end) 1./H(2:length(f)) 1./Kpt(2:length(f))];
		fprintf([' The returned matrix contains in column 1 the frequencies,\n',...
			' in column 2 the theoretical correction factor, and in column 3 \n'...,
			' the effectively used correction factor, for a water depth of\n',...
			' %g m and PT position of %g m above the sea bed.\n'],h,zpt);
		return
	end
else
	x=(1:M)';
end

H = zeros(N,1);						% pre-allocate vector
overlap_window=hann(M);				% coefficient array to combine overlapping segments
overlap_window(M/2+1:end)=1-overlap_window(1:M/2);
%overlap_window=triang(M);

h_dif=[];
for q=1:Noverlap:(N-Noverlap)
    o = min(q + M-1, m);
	ptseg=pt(q:o);
	seg_len=length(ptseg);
	
	if do_detrend
        previous_warning_state=warning('off');
		trend=polyfit(x(1:seg_len),ptseg,1);	% calculates trend
        warning(previous_warning_state);
		h=polyval(trend,(seg_len+1)/2);		    % mean water depth of segment
		ptseg=ptseg-polyval(trend,x(1:seg_len));% remove trend

		K = wavenumL(f,h);              	% calculates wave number for each frequency using 
                                   		 	% function defined below
		Kpt=cosh(K*zpt)./cosh(K*h);					% correction factor of spectrum for pressure
		Kpt(f<min_frequency | f>max_frequency) = 1;	% attenuation (0.05-0.33Hz only)
		Kpt(Kpt < 1/max_attenuation_correction) = 1/max_attenuation_correction;
								% correction factor never higher than max_attenuation_correction
						% linear decrease of correction above f>max_frequency
		fb_max=max(find(f<=max_frequency));
		fKlin=[fb_max:min(fb_max+fix(length(K)/10),length(K))];
		Kpt(fKlin)=(length(fKlin):-1:1)*(Kpt(fb_max)-1)/length(fKlin)  + 1; 
		Kpt(1)=1;
		Kpt(M:-1:M/2+2)=Kpt(2:M/2);			% second half of series is symetric  
	end
	if seg_len<M
		ptseg(M,1)=0;				% zero-pads to nearest length M
	end

	P = fft(ptseg);				% calculate spectrum
	Pcor= P./Kpt;				% applies correction factor
    Hseg = real(ifft(Pcor));	% corrected PT time series
	
	Hseg=Hseg(1:seg_len);		% same length than original segment
	if do_detrend
		Hseg=Hseg + polyval(trend,x(1:seg_len));		% add linear regression values if data were detrended
	end
    H(q:o) = H(q:o) + Hseg.*overlap_window(1:seg_len);
	if q==1
		H(1:min(Noverlap,seg_len)) = Hseg(1:min(Noverlap,seg_len));
	end
	if q+M>=N & seg_len>Noverlap
		H(q+Noverlap:o) = Hseg(Noverlap+1:end);
	end
end
  
H = H(1:m);	
H = reshape(H,pt_dimension);
H_with_NaN(not_NaN) = H;		% add again NaN value that were present in pt
H = H_with_NaN;



function y=wavenumL(f,h);
% y=wavenum(f,h): FUNCTION for the calculation of the wavenumber.
%                   The dispertion relation is solved using a 
%                   polynomial approximation.
%                   f, wave frequency; f=1/T.
%                   h, water depth (in m).
%
%       George Voulgaris, SUDO, 1992
echo off
f=f(:);
w=2*pi*f;
dum1=(w.^2)*h/9.81;
dum2=dum1+(1.0+0.6522*dum1+0.4622*dum1.^2+0.0864*dum1.^4+0.0675*dum1.^5).^(-1);
dum3=sqrt(9.81*h.*dum2.^(-1))./f;
y=2*pi*dum3.^(-1);