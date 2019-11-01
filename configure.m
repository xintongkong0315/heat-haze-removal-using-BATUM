% Download FEPLL
if ~exist('fepll', 'dir')
    disp('Downloading FEPLL (this may take a while)');
    !git clone 'https://github.com/pshibby/fepll_public' 'fepll'
end

% Add FEPLL in Path
addpath('fepll');

% Add all subdirectories in Path
addpathrec('.');
