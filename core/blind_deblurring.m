function [xhat, kernel, a_coefs, lambda] = blind_deblurring(y, sig, varargin)
% BLIND_DEBLURRING  Blindly deblur an image (without knowing the convolution kernel)
%
%   [xhat, kernel, a_coefs, lambda] = BLIND_DEBLURRING(y) performs blind deblurring where:
%     `y` is a 2d blurry image in grayscale (in the spatial domain),
%     `xhat` is the estimated clean image (in the spatial domain),
%     `kernel` is the estimted convolution kernel (in the Fourier domain),
%     `a_coefs` is a vector of parameters for the convolution kernel,
%     `lambda` is the regularization parameter that has been chosen.
%
%   BLIND_DEBLURRING(y, sig) same but assume the noise standard deviation to be `sig'.
%      Otherwise, if not provided or `sig`=[], `sig` is estimated using stdmad.
%
%   BLIND_DEBLURRING(..., 'T', T) uses a maximum of T iterations (default T=150).
%
%   BLIND_DEBLURRING(..., 'thresh', TAU) uses a stopping criterion with relative
%     error TAU between consecutive updates (default TAU=0.0002)
%
%   BLIND_DEBLURRING(..., 'gamma', GAMMA) uses the hyper-parameter GAMMA (default
%     GAMMA=8.5e-3). The larger GAMMA, the smaller the amplitudes of the Kernel.
%
%   BLIND_DEBLURRING(..., 'update_lambda', FALSE, 'lambda', LBD) uses the
%     regularization paramter LBD (default LBD=5). If 'update_lambda' is TRUE
%     (default) the value of LBD is ignored.
%
%   BLIND_DEBLURRING(..., 'callback', CB) CB is an anonymous function that will be
%     called at each iteration. It takes arguments (t, xhat, kernel, a_coefs, changes)
%     where `t` will be the current iteration index, `xhat` the current deblurred
%     image, `kernel` the current estimated kernel, `a_coefs` the current estimated
%     parameters, changes an array of size `t` x 3 containing in columns the relative
%     errors between two consecutive iterations for the three quantities to be estimated.
%     By default CB does nothing.
%
%   BLIND_DEBLURRING(..., 'kernel_estimator', KEST) KEST is an anonymous function that will be
%     used to estimate the kernel. It takes arguments the current (y, xhat, sig, lambda, a_coefs)
%     and returns [kernel, a_coefs] the updated kernel and vector or parameters. By default
%     the Fried kernel estimator is used (see function FRIED_KERNEL_ESTIMATOR).
%
%   BLIND_DEBLURRING(..., 'kernel_init', KERNEL) KERNEL is the initial 2d kernel to be used.
%     By default it is a Fried kernel of canoncial parameters [18.60, 19.75].
%
%   BLIND_DEBLURRING(..., 'deblurrer', DEB) DEB is an anonymous function that will be
%     used to perform non-blind deblurring. It takes arguments the current (y, kernel, sig)
%     and returns `xhat` the updated image. By default FEPLL is used.
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


[n1, n2] = size(y);

options          = makeoptions(varargin{:});
T                = getoptions(options, 'T', 150);
thresh           = getoptions(options, 'thresh', 0.0002);
update_lambda    = getoptions(options, 'update_lambda', true);
lambda           = getoptions(options, 'lambda', 5);
gamma            = getoptions(options, 'gamma', 8.5e-03);
callback         = getoptions(options, 'callback', @(t, xhat, kernel, a_coefs, changes) []);

kernel_estimator = getoptions(options, 'kernel_estimator', []);
kernel_init      = getoptions(options, 'kernel_init', []);
deblurrer        = getoptions(options, 'deblurrer', []);

% By default the Fried kernel estimator is used
if isempty(kernel_estimator)
    kernel_estimator = @fried_kernel_estimator;
end
% By default a Fried kernel is used at initialization
if isempty(kernel_init)
    kernel_init = fried_kernel(n1, n2, 'a_coefs', [18.60, 19.75]');
end
% By default FEPLL is used for non-blind deblurring
if isempty(deblurrer)
    prior_model = get_prior_model(0.99);
    deblurrer = @(y, kernel, sig) ...
        fepll(y, sig, prior_model, ...
              'operator', operators('blur', size(y, 1), size(y, 2), ...
                                    'kernel', real(fftshift(ifft2(kernel)))), ...
              'verbose', false);
end
% Is sig is not provided or empty, we estimate it using stdmad
if ~exist('sig', 'var') || isempty(sig)
    sig = stdmad(y);
end

% Regularization paramter alpha as a function of gamma
alpha = gamma * sqrt(n1 * n2) / sig;

% Initalizations
changes = zeros(T, 3);
kernel = kernel_init;
xhat = deblurrer(y, kernel, sig);
a_coefs = [];

% Main loop
for t = 1:T
    xhat_old = xhat;
    kernel_old = kernel;
    lambda_old = lambda;

    % Update lambda
    if update_lambda
        A = sqrt(sum(abs(kernel(:)).^2));
        lambda = alpha / A;
    end

    % Update kernel
    [kernel a_coefs] = kernel_estimator(y, xhat, sig, lambda, a_coefs);

    % Update image
    xhat = deblurrer(y, kernel, sig);

    % Compute changes
    changes(t, 1) = norm(xhat_old - xhat) / norm(xhat_old);
    changes(t, 2) = norm(kernel_old - kernel) / norm(kernel_old);
    changes(t, 3) = norm(lambda_old - lambda) / norm(lambda_old);

    % Call callback function
    callback(t, xhat, kernel, a_coefs, changes);

    % Stopping criterion
    if max(changes(max(1,t-3):t, :)) < thresh
        break
    end
end
