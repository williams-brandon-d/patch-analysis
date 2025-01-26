function plotCellPSDdata(dataSets, comment_group1, savenum)
% independent group plots and comparisons

dataTypes = {'PSDpower','PSDfrequency'};

params.comments = comment_group1;
comments = cell2mat(params.comments);

% find ID parameters for analysis
params.locations = 'all';
params.cell_nums = 'all';
params.protocols = {'theta'};
protocol = params.protocols{1};

if strcmp(dataSets,'all'); dataSets = {'Camk2','Thy1','PV Transgenic','PV Viral'}; end

nDataTypes = length(dataTypes);

for iSet = 1:numel(dataSets)
dataSet = dataSets{iSet};

[info,~,data_path] = getInfo(dataSet);

switch dataSet
    case 'Thy1'
         saveFolder = 'C:\Users\brndn\Downloads\Thy1-ChR2\Raw Data\mEC\results\Summary';
%          experiments = {'excitation','inhibition'};
         experiments = {'inhibition'};
    case 'PV Transgenic'
         saveFolder = 'C:\Users\brndn\Downloads\PV-ChR2 Transgenic\Summary';
         experiments = {'inhibition'};
    case 'PV Viral'
         saveFolder = 'C:\Users\brndn\Downloads\PV-ChR2\Summary';
         experiments = {'inhibition'};
    case 'Camk2'
         saveFolder = 'C:\Users\brndn\Downloads\CaMK2-ChR2\Summary';
         experiments = {'excitation','inhibition'};
end

if ~exist(saveFolder, 'dir')
   mkdir(saveFolder)
end

nExperiments = length(experiments);

for iExp = 1:nExperiments
params.experiments = experiments(iExp);
experiment = experiments{iExp};

switch experiment
    case 'inhibition'
        cell_types = {'stellate','pyramidal','fast spiking'};
    case 'excitation'
        cell_types = {'stellate','pyramidal','fast spiking'};
end
nCellTypes = length(cell_types);

allPower = cell(nCellTypes,1);
allFreq = cell(nCellTypes,1);

for iCell = 1:nCellTypes
    cellType = cell_types{iCell};
    params.cell_types = cell_types(iCell);

%     comments = cell2mat(params.comments);

    IDs = getIDs(info,params);

    IDs = removeIDs(IDs,info); % skip bad recordings - get params for cells to skip
    
    if (isempty(IDs)); fprintf('No %s %s Files Found.',params.cell_types,comments); continue; end
    
    nIDs = numel(IDs);

    powerArray = cell(nIDs,1);
    freqArray = cell(nIDs,1);

    for iID = 1:nIDs
    
        ID = IDs{iID};
        ID_index = find_index(info,'ID',ID);

        p = info(ID_index);
    
        if isempty(p.comments)
            comment = 'No Comment';
        else
            comment = p.comments;
        end

        filename = sprintf('%s.abf',ID);
        fprintf('%s %s %s Analyzing %s,File %d/%d\n',dataSet,cellType,comment,filename,iID,nIDs)
    
        commentFolder = sprintf('%sresults\\%s\\%s\\%s\\%s\\%s\\%s\\%s',data_path,p.location,p.cell_type,p.cell_num,p.experiment,p.protocol,comment);
    
        dataFolder = getIDFolder(commentFolder,ID);
    
        dataFilename = [dataFolder filesep 'data.mat'];
    
        load(dataFilename,'file');
        % gather relevant data 

        % compute and plot PSD from each theta cycle without artifacts 
%         [file.cell,~] = plotCyclePSD(file.cell,file.Fs,file.cycle_start_index_noArtifacts,file.cycle_length,'pwelch',file.cell.data_units,0);
%         freq = file.cell.max_psd_gamma_freq;
%         power = file.cell.sum_gamma_power;

        % compute and plot PSD from all stim data
        [file.cell,~] = plotallCyclePSD(file.cell,file.Fs,file.cycle_start_index_noArtifacts,file.cycle_length,'pwelch',file.cell.data_units,0);
        freq = file.cell.max_psd_gamma_freq_all;
        power = file.cell.sum_gamma_power_all;

%         % if data is frequency - remove low power data 
%         if strcmp(dataType,'PSDfrequency')
%             removeFlag = removeLowPowerData(file);
%            if removeFlag; freq = []; end
%         end 

        powerArray{iID} = power;
        freqArray{iID} = freq;
        clearvars file;
    end

    allPower{iCell,1} = cell2mat(powerArray); % save cell data
    allFreq{iCell,1} = cell2mat(freqArray); % save cell data
end

for iType = 1:nDataTypes
    dataType = dataTypes{iType};
    
    switch dataType
        case 'PSDpower'
            allData = allPower;
        case 'PSDfrequency'
            allData = allFreq;
    end
    
    % convert data to log for power plots and stats
    if strcmp(dataType,'PSDpower')
        allData = cellfun(@log10,allData,'UniformOutput',false); % returns cell array
    %     saveFilename = [saveFolder filesep sprintf('%s %s %s %s LOG stats.xlsx',dataSet,protocol,experiment,dataType)];
    %     LOGstats = myMultipleIndependentGroupStats(allData,cell_types,comments,saveFilename,savenum);
    end
    
    saveFilename = [saveFolder filesep sprintf('%s %s %s %s stats.xlsx',dataSet,protocol,experiment,dataType)];
    stats = myMultipleIndependentGroupStats(allData,cell_types,comments,saveFilename,savenum);
    
    groupLabels = myGroupLabels(cell_types);
    [colors,alphas] = getColorAlpha(cell_types,1);
    y = getYparams(dataType,protocol,'normal');
    pTitle = sprintf('%s %s %s',dataSet,protocol,experiment);
    
    figBox = myBoxplot(allData,groupLabels,y,colors,alphas,stats.kw);
    sgtitle(pTitle,'Fontweight','bold');
    
    figBar = myBarChart(allData,groupLabels,y,colors,alphas,stats.kw);
    sgtitle(pTitle,'Fontweight','bold');
    
    figViolin = plotViolin(allData,groupLabels,y,colors,alphas);
    sgtitle(pTitle,'Fontweight','bold');
    
    if savenum
        saveFilename = [saveFolder filesep sprintf('%s %s %s %s',dataSet,protocol,experiment,dataType)];
        print(figBox,'-vector','-dsvg',[saveFilename ' Boxplot.svg']); % save boxplot as svg file
        print(figBar,'-vector','-dsvg',[saveFilename ' BarChart.svg']); % save barchart as svg file
        print(figViolin,'-vector','-dsvg',[saveFilename ' Violin.svg']); % save violin plots as svg file
    end

end


end


end



end

