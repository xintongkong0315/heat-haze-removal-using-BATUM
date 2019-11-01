function cb_blind_deblurring_for_simulations(t, y, xhat, kernel, xhato, kernelo, x, changes)
% CB_BLIND_DEBLURRING_FOR_SIMULATIONS  Callback function aimed to be used with
%   BLIND_DEBLURRING or BATUD to display intermediate results during the optimization,
%   and to compare them to ground truth and oracle.
%
%   Not documented.
%
%   Citation: if you use this code please cite us as indicated in REAME.md
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


%% Display update at first and every 5 iterations
if ~(t == 1 || mod(t, 5) == 0)
    return
end

%% Pick the handle for the figure or create a new one
figname = 'Blind Deblurring with BATUD (Simulation)';
h = findobj('type', 'figure', 'name', figname);
if isempty(h)
    h = fancyfigure('name', figname);
end
set(0, 'CurrentFigure', h);

%% Prevent figure to be closed while drawing it
hcloser = get(h, 'closer');
hclean = onCleanup(@() set(h, 'closer', hcloser));
set(h, 'closer', '');

%% Display blurry image
ha(1) = subplot(1,5,1);
hold off;
plotimage(y, 'range', [0 1]);
title(sprintf('Blurry image $y$ (%.2f)', psnr(y, x)));

%% Display deblurred image
ha(2) = subplot(1,5,2);
hold off;
plotimage(xhato, 'range', [0 1]);
title(sprintf('Oracle $\\hat{x}^{\\mathrm{oracle}}$ (%.2f/%.3f)', ...
              psnr(xhato, x), ...
              ssim(xhato, x)));

%% Display deblurred image
ha(3) = subplot(1,5,3);
hold off;
plotimage(xhat, 'range', [0 1]);
title(sprintf('$\\hat{x}$ (%d) (%.2f/%.3f)', t, psnr(xhat, x), ...
              ssim(xhat, x)));

%% Linkaxes
linkaxes(ha);

%% Display convolution kernel
subplot(1,5,4);
hold off;
plotkernel(kernel, kernelo);
title(sprintf('kernel (%d) (%.3f)', t, ...
              sum(abs(kernel(:) - kernelo(:)).^2) / sum(abs(kernelo(:)).^2)));

%% Display convergence curves
subplot(1,5,5);
hold off
plot(1:t, 100*changes(1:t, 1), 'LineWidth', 2);
hold all
plot(1:t, 100*changes(1:t, 2), 'LineWidth', 2);
plot(1:t, 100*changes(1:t, 3), 'LineWidth', 2);

% Legend
leg = fancylegend('$x$', '$M_{\bf a}$', '$\lambda$', 'Location', 'NorthEast');
leg.ItemTokenSize = [10, 10];

% Labels
xlabel('Time step $t$')
ylabel('Relative error (in \%)')

% Limits and ticks
if t > 1
    xlim([1, t]);
end
ylim([0, 1.5]);
yticks([0, 1]);

% Remove extreme xticks
xt = xticks;
if xt(1) < t / 8
    xt = xt(2:end);
end
if xt(end) > t - t / 8
    xt = xt(1:(end-1));
end
xticks(xt);

% Square aspect
axis square

%% Force drawing now
drawnow

%% Restore closing property
set(h, 'closer', hcloser);
delete(hclean)