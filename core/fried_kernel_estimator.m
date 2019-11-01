function [kernel, a, X, V] = fried_kernel_estimator(y, x, sig, lambda, a_coefs_guess)
% FRIED_KERNEL_ESTIMATOR  Estimate a Fried Kernel
%
%   [kernel, a, X, V] = FRIED_KERNEL_ESTIMATOR(y, x, sig, lambda)
%     the optimization where:
%     `y` is a blurry image (in the spatial domain),
%     `x` is a clean image (or an estimation of it),
%     `sig` is the noise standard deviation,
%     `lambda` is the regularization parameter,
%     `kernel` is a 2d array corresponding to M(a),
%     `a` is the estimated vector of the two canonical parameters (refer to [1]).
%     `X`, `V` are the alternate 2 parameters of the Fried kernel (refer to [1]).
%
%   FRIED_KERNEL_ESTIMATOR(y, x, sig, lambda, a_coefs_guess) uses the 2 dimensional
%     vector `a_coefs_guess` as initialization for 'a' (useful for warm start).
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


if ~exist('a_coefs_guess', 'var') || isempty(a_coefs_guess)
    a_coefs_guess = [18.60, 19.75]'; % coeffs estimated on natural images
end

A    = @(w) iif(abs(w) > 1, 0, 2/pi * (acos(abs(w)) - abs(w) .* sqrt(1 - abs(w).^2)));
f{1} = @(w) -w.^(5/3);
f{2} = @(w)  w.^(2);

[kernel, a] = kernel_estimator(y, x, A, f, sig, lambda, a_coefs_guess);

X    = a(1).^(3/5) / 2.1;
V    = a(2) / a(1);

end
