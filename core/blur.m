function y = blur(x, kernel)
% BLUR  Blur an image given a convolution kernel
%
%   y = BLUR(x, kernel)
%     `x` a 2d image (in the spatial domain),
%     `kernel` a 2d convolution kernel (in the Fourier domain),
%     `y` the blurred image (in the spatial domain),
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


y = real(ifft2(fft2(x) .* kernel));
