function xhat = nonblind_deblurring(y, kernel, sig)
% NONBLIND_DEBLURRING  Deblur an image with FEPLL using the knowledge of the convolution kernel.
%
%   xhat = NONBLIND_DEBLURRING(y, kernel) performs non-blind deblurring where:
%     `y` is a 2d blurry image in grayscale (in the spatial domain),
%     `kernel` is a 2d convolution kernel (in the Fourier domain),
%     `xhat` is the deblurred image.
%
%   NONBLIND_DEBLURRING(y, kernel, sig) same but assume the noise standard deviation to
%      be `sig'. Otherwise, if not provided or `sig`=[], `sig` is estimated using stdmad.
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


[n1, n2] = size(y);

if ~exist('sig', 'var') || isempty(sig)
    sig = stdmad(y);
end

prior_model = get_prior_model(0.99);
xhat = fepll(y, sig, prior_model, ...
             'operator', operators('blur', size(y, 1), size(y, 2), ...
                                   'kernel', real(fftshift(ifft2(kernel)))), ...
             'verbose', false);
