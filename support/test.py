import numpy as np
import pylab as pl
import gsignal


t = np.arange(0,1000,0.1)
per = [12.0,10.0]
phase = [0.0,np.pi/6]
amp = [1.0,1.0]
eta = np.zeros_like(t)

eta = (amp[0]*np.cos(2*np.pi/per[0]*t+phase[0]) +
       amp[1]*np.cos(2*np.pi/per[1]*t+phase[1]))

# Fourier analysis
freq = np.fft.fftfreq(eta.shape[0],t[2]-t[1])
fspec = np.fft.fft(eta)

hf1 = pl.figure()
ax = pl.subplot(1,1,1)
ax.plot(np.fft.fftshift(freq),np.fft.fftshift(fspec))

# Extract phase
i_phase = np.arctan(fspec.imag/fspec.real)

# Get spectrum
[spec_freq,spec_spec] = gsignal.psdraw(eta,t[1]-t[0])


# Filtering in frequency domain
ind = np.abs(freq)<1.0/11.0
fspec[ind] = 0.0
eta_flt = np.fft.ifft(fspec)
