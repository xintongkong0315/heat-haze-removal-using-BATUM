function [kernel, a] = kernel_estimator(y, x, A, f, sig, lambda, a_coefs_guess, varargin)
% KERNEL_ESTIMATOR  Estimate a Blur Kernel parameterized by a N dimensional vector `a` as:
%
%       M(a)(w) = A(w) exp( sum_{i=1}^N a_i f_i(w) )  where  w is the frequency
%
%   where `a` is estimated by minimizing:
%
%       E = 1/(2 sig^2) ||M(a) * x - y||^2 + lambda ||M(a)||^2
%
%   [kernel, a] = KERNEL_ESTIMATOR(y, x, A, f, sig, lambda, a_coefs_guess) performs
%     the optimization where:
%     `y` is a blurry image (in the spatial domain),
%     `x` is a clean image (or an estimation of it),
%     `A` is a function of the frequencies,
%     `f` is a cell-array of N functions of the frequencies,
%     `sig` is the noise standard deviation,
%     `lambda` is the regularization parameter,
%     `a_coefs_guess` is a N dimensional vector used as initialization for 'a',
%     `kernel` is a 2d array corresponding to M(a),
%     `a` is the estimated vector of parameters.
%
%   KERNEL_ESTIMATOR(..., 'optimizer', METHOD) performs the optimization using
%     METHOD as optimizer. If METHOD='newton' (default) then Newton descent is used,
%     if METHOD='fminsearch' then fminsearch is used.
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


options          = makeoptions(varargin{:});
optimizer        = getoptions(options, 'optimizer', 'newton');

% Take the normalized Fourier transform of the input images
[m, n]  = size(x);
y = fft2(y) / sqrt(n * m);
x = fft2(x) / sqrt(n * m);

% Number of parameters in the Kernel
N = length(f);

% Reparamterization of E
lambda = lambda * 2 * sig^2;

% Define frequencies
[u, v]                = fftgrid(m, n);
R                     = max(max(u(:)), max(v(:)));
u                     = u / R;
v                     = v / R;
w                     = sqrt(u.^2 + v.^2);

% Evaluate A and f for all frequencies of interest
Aw                    = A(w);
fw                    = zeros(size(y, 1), size(y, 2), N);
for i = 1:N
    fw(:, :, i)             = f{i}(w);
end

% COmpute outer-product f
fww                   = zeros(size(y, 1), size(y, 2), N, N);
for i = 1:N
    for j = 1:N
        fww(:, :, i, j) = f{i}(w) .* f{j}(w);
    end
end

% Define M as a function of the vector a
logM                  = @(a) sum(reshape(a, [1, 1, N]) .* fw, 3);
M                     = @(a) Aw .* exp(logM(a));

% Define the loss
Sum                   = @(x) sum(x(:));
loss = @(Ma) Sum(abs(x .* Ma - y).^2) + lambda * Sum(abs(Ma).^2);
loss = @(a) loss(M(real(a)));

switch optimizer
    case 'fminsearch'
        a = fminsearch(loss, a_coefs_guess);
        kernel = M(a);
    case 'newton'
        % Define 1st and 2nd partial derivative
        for i = 1:N
            dEda{i}           = @(Ma, xMa) ...
                Sum(real(fw(:, :, i) .* conj(xMa) .* (xMa - y)) ...
                    + lambda .* real((fw(:, :, i)) .* abs(Ma).^2));
            for j = 1:N
                d2Edada{i}{j} = @(Ma, xMa) ...
                    Sum(real(fww(:, :, i, j) .* conj(xMa) .* (2 * xMa - y)) ...
                        + lambda .* real(2 * (fww(:, :, i, j)) .* abs(Ma).^2));
            end
        end

        % Runs Newton descent
        a = a_coefs_guess;
        g = zeros(N, 1);
        H = zeros(N, N);
        for k = 1:20
            Ma = M(a);
            xMa = x .* Ma;
            for i = 1:N
                % Gradient computation
                g(i) = dEda{i}(Ma, xMa);
                % Hessian computation
                for j = i:N
                    H(i, j) = d2Edada{i}{j}(Ma, xMa);
                end
            end
            % Hessian symmetry
            for i = 1:N
                for j = 1:(i-1)
                    H(i, j) = H(j, i);
                end
            end
            % Turn off warning and backup last one
            s = warning('off', 'all');
            [omsglast, omsgidlast] = lastwarn;
            % Newton update
            delta = H \ g;
            % Catch if a warning was raised, restore old one, and turn back on
            [msglast, msgidlast] = lastwarn;
            warning(omsglast, omsgidlast);
            warning(s);
            % Run fminsearch if inversion did not succeed as expected (just a safe guard)
            if strcmp(msgidlast, 'MATLAB:singularMatrix') || ...
                    strcmp(msgidlast, 'MATLAB:illConditionedMatrix') || ...
                    strcmp(msgidlast, 'MATLAB:nearlySingularMatrix') || ...
                    sum(isnan(delta)) > 0 || sum(isinf(delta)) > 0
                a = fminsearch(loss, a_coefs_guess);
                break;
            end
            % Gradient clipping (just a safe guard)
            if norm(delta) > 2 * norm(a)
                delta = delta / norm(delta) * 2 * norm(a);
            end
            % Gradient descent
            a = a - delta;
            % In case of numerical errors
            a = real(a);
            % Stopping criterion
            if norm(delta) < 2e-4 * norm(a)
                break;
            end
        end
        kernel = M(a);
end
