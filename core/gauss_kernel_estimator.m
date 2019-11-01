function [kernel, a, gamma] = gauss_kernel_estimator(y, x, sig, lambda, a_coefs_guess)
% GAUSS_KERNEL_ESTIMATOR  Estimate a Gauss Kernel
%
%   [kernel, a, X, V] = GAUSS_KERNEL_ESTIMATOR(y, x, sig, lambda)
%     the optimization where:
%     `y` is a blurry image (in the spatial domain),
%     `x` is a clean image (or an estimation of it),
%     `sig` is the noise standard deviation,
%     `lambda` is the regularization parameter,
%     `kernel` is a 2d array corresponding to M(a),
%     `a` is the canonical parameter (refer to [1]).
%     `gamma` is the bandwidth of the Gauss kernel (refer to [1]).
%
%   GAUSS_KERNEL_ESTIMATOR(y, x, sig, lambda, a_coefs_guess) uses the value of
%     `a_coefs_guess` as initialization for 'a' (useful for warm start).
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


if ~exist('a_coefs_guess', 'var') || isempty(a_coefs_guess)
    a_coefs_guess = 1;
end

A      = @(w) 1;
f{1}   = @(w) -abs(w).^2;

[kernel, a] = kernel_estimator(y, x, A, f, sig, lambda, a_coefs_guess);

nu     = 1 / sqrt(2 * a);
gamma  = 1 / nu;

end
