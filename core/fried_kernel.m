function [kernel, a_coefs, X, V] = fried_kernel(n1, n2, varargin)
% FRIED_KERNEL  Generate the Fried kernel
%
%   [kernel, a_coefs, X, V] = FRIED_KERNEL(n1, n2) generates a Fried kernel using arbitrary
%     wavelength, path length, pupil diameter and refractive index.
%     `n1`, `n2` are the size 2d discrete kernel to generate,
%     `kernel' is the generated 2d discrete kernel (in the Fourier domain),
%     `a_coefs` is the vector of the 2 canonical parameters of the Fried kernel (refer to [1]),
%     `X`, `V` are the alternate 2 parameters of the Fried kernel (refer to [1]).
%
%   FRIED_KERNEL(..., 'a_coefs', [A1 A2]) uses instead the canonical parameters A1 and A2.
%
%   FRIED_KERNEL(..., 'V', V, 'X', X) uses instead the alternate parameters V and X.
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


options          = makeoptions(varargin{:});
a_coefs = getoptions(options, 'a_coefs', []);
if isempty(a_coefs)
    X = getoptions(options, 'X', []);
    V = getoptions(options, 'V', []);
    if isempty(X)
        lambda = (0.36e-6 + 15e-6) / 2;
        d = (0.2 + 0.01) / 2;
        l = (4000 + 500) / 2;
        Cn2 = (1e-16 + 1e-12) / 2;
        q = log2(d/sqrt(lambda*l));
        X = d/(3.0177*((2*pi./lambda)^2*l*Cn2)^(-3/5));
        if q>-1.5
            qa = 1.35*(q+1.5);
            A  = 0.84+0.116*(exp(qa)-1)/(exp(qa)+1);
        else
            qc = 0.51*(q+1.5);
            A  = 0.84+0.28*(exp(qc)-1)/(exp(qc)+1);
        end
        qb = 1.45*(q-0.15);
        B  = 0.805+0.265*(exp(qb)-1)/(exp(qb)+1);
        V  = A+(B/10)*exp(-((log10(X)+1)^3)/3.5);
    end
    a_coefs(1)   = (2.1 * X).^(5/3);
    a_coefs(2)   = (2.1 * X).^(5/3) .* V;
end

[u, v] = fftgrid(n1, n2);
R      = max(max(u(:)), max(v(:)));
u      = u / R;
v      = v / R;
w      = sqrt(u.^2 + v.^2);
M0     = iif(abs(w) > 1, 0, 2/pi * (acos(abs(w)) - abs(w) .* sqrt(1 - abs(w).^2)));
MSA    = exp(-a_coefs(1) * abs(w).^(5/3) + a_coefs(2) .* abs(w).^2);

kernel = M0 .* MSA;
