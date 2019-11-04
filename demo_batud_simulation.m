%% Demonstration script of BATUD in a simulated Atmospheric Turbulemce scenario
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

% Define the Fried blur kernel
difficulty = 'weak';
switch difficulty
    case 'weak'
        kernel_true = fried_kernel(n1, n2, 'X', 2.25, 'V', 1.29);
    case 'medium'
        kernel_true = fried_kernel(n1, n2, 'X', 3, 'V', 1);
    case 'strong'
        kernel_true = fried_kernel(n1, n2, 'X', 5, 'V', 0.8);
end

% Enter a determinisic environment (ie we fix the random generator seed)
state = deterministic('on');

% Generate randomly a noisy and blurry image
y = blur(x, kernel_true) + sig * randn(n1, n2);

% Return to a non-deterministic environment
deterministic('off', state);

% Run non-blind deblurring (Oracle)
xhato = nonblind_deblurring(y, kernel_true, sig);

% Define callback function to show results during processing
callback = @(t, xhat, kernel, a_coeffs, changes) ...
    cb_blind_deblurring_for_simulations(t, y, xhat, kernel, xhato, kernel_true, x, changes);

% Run blind deblurring using BATUD and the defined callback function
xhat = batud(y, sig, 'callback', callback);
