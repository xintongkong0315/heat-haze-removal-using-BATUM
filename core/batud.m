function [xhat, kernel, a_coefs, lambda] = batud(y, sig, varargin)
% BATUD  Blindly deblur an image with BATUD (without knowing the convolution kernel)
%
%   [xhat, kernel, a_coefs, lambda] = BATUD(y) performs blind deblurring where:
%     `y` is a 2d blurry image in grayscale (in the spatial domain),
%     `xhat` is the estimated clean image (in the spatial domain),
%     `kernel` is the estimted convolution kernel (in the Fourier domain),
%     `a_coefs` is a vector of parameters for the convolution kernel,
%     `lambda` is the regularization parameter that has been chosen.
%
%   BATUD(y, sig) same but assume the noise standard deviation to be `sig'.
%      Otherwise, if not provided or `sig`=[], `sig` is estimated using stdmad.
%
%   BATUD(..., 'T', T) uses a maximum of T iterations (default T=150).
%
%   BATUD(..., 'thresh', TAU) uses a stopping criterion with relative
%     error TAU between consecutive updates (default TAU=0.0002)
%
%   BATUD(..., 'gamma', GAMMA) uses the hyper-parameter GAMMA (default
%     GAMMA=8.5e-3). The larger GAMMA, the smaller the amplitudes of the Kernel.
%
%   BATUD(..., 'callback', CB) CB is an anonymous function that will be
%     called at each iteration. It takes arguments (t, xhat, kernel, a_coefs, changes)
%     where `t` will be the current iteration index, `xhat` the current deblurred
%     image, `kernel` the current estimated kernel, `a_coefs` the current estimated
%     parameters, `changes` an array of size `t` x 3 containing in columns the relative
%     errors between two consecutive iterations for the three quantities to be estimated.
%     By default CB does nothing.
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


[xhat, kernel, a_coefs, lambda] = blind_deblurring(y, sig, varargin{:});