function [CellStatsCell, NucleusStatsCell, Contact, Nucleus] = ...
    analyzecells(contactWidth, nucleusWidth)

% Select files.
[cadherinFileNameCell, folderNameStr] = uigetfile('*.tiff', ...
    'Select cadherin TIF', 'MultiSelect', 'on');
nucleusFileNameCell = uigetfile('*.tiff', ...
    'Select nucleus TIF', folderNameStr, 'MultiSelect', 'on');

% Check if single-string variable needs to be converted into cell.
if ~iscell(cadherinFileNameCell)
    cadherinFileNameCell = {cadherinFileNameCell};
    nucleusFileNameCell = {nucleusFileNameCell};
end

% Load files and project average intensity.
cadherinCell = cellfun(@(x) mean(imstack([folderNameStr, x]), 3), ...
    cadherinFileNameCell, 'UniformOutput', false);
nucleusCell = cellfun(@(x) mean(imstack([folderNameStr, x]), 3), ...
    nucleusFileNameCell, 'UniformOutput', false);

% Loop over each strain point.
noFrames = numel(cadherinCell);
[Contact, Nucleus] = maskcells(cadherinCell{1}, nucleusCell{1}, ...
    contactWidth, nucleusWidth);
if noFrames > 1
    Contact(noFrames).rawIm = [];
    Nucleus(noFrames).rawIm = [];
    for iFrame = 1 : noFrames
        [Contact(iFrame), Nucleus(iFrame)] = maskcells(...
            cadherinCell{iFrame}, nucleusCell{iFrame}, ...
            contactWidth, nucleusWidth);
    end
end

% Extract properties.
CellStatsCell = arrayfun(@(x) regionprops(x.bwIm, ...
    'Area', 'MajorAxisLength', 'Orientation'), ...
    Contact, 'UniformOutput', false);
NucleusStatsCell = arrayfun(@(x) regionprops(x.bwIm, ...
    'Area', 'Centroid'), Nucleus, 'UniformOutput', false);
end