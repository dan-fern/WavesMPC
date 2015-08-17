function [ d0 ] = forecastGuess( t, spectra, count )

eta = spectra.eta;
if eta(count) > 0
    x = 1;
else
    x = -1;
end
if abs(eta(count+1)) - abs(eta(count)) > 0
    z = 1;
else
    z = -1;
end

d0 = zeros( t.tSteps, 2 );
d0(:,1) = deal(x);
d0(:,2) = deal(z);

return

end

