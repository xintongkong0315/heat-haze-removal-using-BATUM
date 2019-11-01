%% Demonstration script of BATUD on a real image from the Otis dataset
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

% Load real blurry image
load('data/Otis_door.mat');

% Define callback function to show results during processing
callback = @(t, xhat, kernel, a_coeffs, changes) ...
    cb_blind_deblurring(t, y, xhat, kernel, changes);

% Run blind deblurring using BATUD and the defined callback function
xhat = batud(y, [], 'callback', callback);
