function [kernel, a_coeffs, gamma] = gauss_kernel(n1, n2, gamma)
% GAUSS_KERNEL  Generate the Fried kernel
%
%   [kernel, a_coefs, gamma] = GAUSS_KERNEL(n1, n2) generates a Gaussian kernel using a
%     bandwidth of 4 pixels.
%     `n1`, `n2` are the size 2d discrete kernel to generate,
%     `kernel' is the generated 2d discrete kernel (in the Fourier domain),
%     `a_coefs` is the canonical parameters of the Gaussian kernel,
%     `gamma` is the bandwidth of the Gaussian kernel.
%
%   GAUSS_KERNEL(n1, n2, gamma) uses instead the bandwidth `gamma`.
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


if ~exist('gamma', 'var')
    gamma = 4;
end

[u, v] = fftgrid(n1, n2);
R      = max(max(u(:)), max(v(:)));
u      = u / R;
v      = v / R;
w      = sqrt(u.^2 + v.^2);

nu     = 1 / gamma;
a_coeffs = 1 / (2 * nu^2);

kernel = exp(-a_coeffs * abs(w).^2);

