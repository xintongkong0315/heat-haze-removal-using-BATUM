function h = plotkernel(kernel, kernelo)
% PLOTKERNEL  Display a Convolution kernel
%
%   H = PLOTKERNEL(KERNEL) displays the filter KERNEL (in the Fourier domain)
%     in a log-scale and recenter the zero-frequency with FFTSHIFT.
%
%   H = PLOTKERNEL(KERNEL, KERNELO) same but display on the top half section
%     KERNELO as well. The two halfs are separated by a red line.
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


if ~exist('kernelo', 'var')
    ima = fftshift(log(abs(kernel)+0.1));
    h = plotimagesc(ima);
else
    [n1, n2] = size(kernel);
    ima = fftshift(log(abs(kernel)+0.1));
    imb = fftshift(log(abs(kernelo)+0.1));
    ima(1:(end/2),:) = imb(1:(end/2),:);
    ima = repmat(ima, [1 1 3]);
    ima((end/2), :, :) = min(ima(:));
    ima((end/2), :, 1) = max(ima(:));
    h = plotimagesc(ima);
    hold on
    plot([.5, n2-.5], [(n1/2)-.5, (n1/2)-.5], '-r');
end
