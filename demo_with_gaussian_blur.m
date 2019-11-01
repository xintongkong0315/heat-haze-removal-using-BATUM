%% Demonstration script of our blind deblurring in a simulated Gaussian blur scenario.
%
%   If you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


clear all
close all

% This will download FEPLL that is used in backend and update the PATH
configure;

% Load clean image
x = double(imread('data/Kodak_lighthouse.png')) / 255;
[n1 n2] = size(x);

% Define noise level
sig = 1.9 / 255;

% Define true Gaussian kernel
difficulty='weak';
switch difficulty
    case 'weak'
        kernel_true = gauss_kernel(n1, n2, 4);
    case 'medium'
        kernel_true = gauss_kernel(n1, n2, 8);
    case 'strong'
        kernel_true = gauss_kernel(n1, n2, 16);
end

% We enter a determinisic environment (ie we fix the random generator seed)
state = deterministic('on');

% We now generate a randomly a noisy and blurry image
y = blur(x, kernel_true) + sig * randn(size(x));

% We now return to a non-deterministic environment
deterministic('off', state);

% Run non-blind deblurring (Oracle)
xhato = nonblind_deblurring(y, kernel_true, sig);

% Define callback function to show results during processing
callback = @(t, xhat, kernel, a_coeffs, changes) ...
    cb_blind_deblurring_for_simulations(t, y, xhat, kernel, xhato, kernel_true, x, changes);

% Run blind deblurring using our algorithm
xhat = blind_deblurring(y, sig, 'callback', callback, ...
                        'kernel_estimator', @gauss_kernel_estimator);
