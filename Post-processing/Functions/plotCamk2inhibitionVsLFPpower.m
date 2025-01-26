function plotCamk2inhibitionVsLFPpower()

clear variables; close all; clc;
cd('C:\Users\brndn\OneDrive\Desktop\White Lab\Matlab Files\');

savenum = 1; % 0 = don't save, 1 = save info


% plot inhibition vs LFP power

% for duplicates - take largest value for inhibition?
% skip recordings with bad lfp? <-----
% lfp SNR is variable which makes amplitude comparisons difficult

dataSets = {'Camk2'};
cell_types = {'stellate','pyramidal','fast spiking'};

% find ID parameters for analysis
params.locations = 'all';
params.experiments = {'inhibition'};
params.cell_nums = 'all';
params.comments = {'','Gabazine before'}; % 'GBZ before' 'DNQX_GABAzine_before', 'Gabazine before', 'DNQX before'
params.protocols = {'theta_2chan'};

% if strcmp(dataSets,'all'); dataSets = {'Camk2','Thy1','PV Transgenic','PV Viral'}; end

% load data for figure

nCellTypes = numel(cell_types);

for iSet = 1:numel(dataSets)
dataSet = dataSets{iSet};

[info,info_fullname,data_path] = getInfo(dataSet);

xCell = cell(nCellTypes,1);
yCell = cell(nCellTypes,1);

for iCell = 1:nCellTypes
params.cell_types = cell_types(iCell);
IDs = getIDs(info,params);

if (isempty(IDs)); fprintf('No %s Files Found.',params.cell_types); continue; end

nIDs = numel(IDs);

xArray = zeros(nIDs,1);
yArray = zeros(nIDs,1);

for iID = 1:nIDs

    ID = IDs{iID};
    ID_index = find_index(info,'ID',ID);
    filename = sprintf('%s.abf',ID);
    fprintf('Analyzing %s,File %d/%d\n',filename,iID,nIDs)
    p = info(ID_index);

    if isempty(p.comments)
        comment = 'No Comment';
    else
        comment = p.comments;
    end

    commentFolder = sprintf('%sresults\\%s\\%s\\%s\\%s\\%s\\%s\\%s',data_path,p.location,p.cell_type,p.cell_num,p.experiment,p.protocol,comment);

    dataFolder = getIDFolder(commentFolder);

    dataFilename = [dataFolder filesep 'data.mat'];

    load(dataFilename,'file');

    % gather relevant data 
    if ~isempty(file.cell.CWTmaxValues) && ~isempty(file.lfp.CWTmaxValues)
        xArray(iID) = file.cell.CWTmaxValues(3); % cell peak scalogram power
        yArray(iID) = file.lfp.CWTmaxValues(3); % lfp peak scalogram power
    else
        xArray(iID) = []; % ignore if either value is empty
        yArray(iID) = [];
    end

    clearvars file;
end

xCell{iCell} = xArray;
yCell{iCell} = yArray;

end

end

% plot figure
fig = figure;
hold on;
for iCell = 1:nCellTypes
    cellType = cell_types{iCell};

    switch cellType
        case 'stellate'
            color = [1 0 0];
        case 'pyramidal'
            color = [0 1 0];
        case 'fast spiking'
            color = [0 0 1];
    end

    plot(xCell{iCell},yCell{iCell},'.','Color',color,'DisplayName',cellType)

end
ax = gca;
set(ax, 'YScale', 'log');
set(ax, 'XScale', 'log');

xlabel('CaMK2 Inhibition Peak Gamma (pA^{2})');
ylabel('CaMK2 LFP Peak Gamma Power (uV^{2})');
legend('location','northeastoutside');

if savenum
    saveFolder = 'C:\Users\brndn\OneDrive\Desktop\White Lab\Carmen Grants';
    saveFilename = [saveFolder filesep 'camk2 inhibition vs lfp power.svg'];
    print(fig,'-vector','-dsvg',saveFilename);
end

close all;

end