function std = stdmad(x)
% STDMAD  Estimate the noise standard deviation
%
%   STD = STDMAD(X) estimates the standard deviation STD of the noise in the 2d
%     grayscale image X, using the Median Absolute Deviation of the diagonal
%     most detailed Haar wavelet coefficients.
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


    y = x(1:2:(end-1), 1:2:(end-1)) - x(2:2:end, 2:2:end);
    y = y(:) / sqrt(2);
    std = 1.4826 * median(abs(y - median(y)));

end
