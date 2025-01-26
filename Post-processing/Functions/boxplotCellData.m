function boxplotCellData(dataSets, comment_group1, savenum)
% independent group plots and comparisons

dataTypes = {'power','frequency','phase'};

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
         experiments = {'excitation'};
%          experiments = {'inhibition'};
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
%         cell_types = {'pyramidal','fast spiking'};
    case 'excitation'
        cell_types = {'stellate','pyramidal','fast spiking'};
%         cell_types = {'fast spiking'};
end
nCellTypes = length(cell_types);

for iType = 1:nDataTypes
dataType = dataTypes{iType};

allData = cell(nCellTypes,1);

for iCell = 1:nCellTypes
    cellType = cell_types{iCell};
    params.cell_types = cell_types(iCell);

%     comments = cell2mat(params.comments);

    IDs = getIDs(info,params);

    IDs = removeIDs(IDs,info); % skip bad recordings - get params for cells to skip
    
    if (isempty(IDs)); fprintf('No %s %s Files Found.',params.cell_types,comments); continue; end
    
    nIDs = numel(IDs);

    dataArray = cell(nIDs,1);

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
        phase = file.cell.CWTmaxValues(1);
        freq = file.cell.CWTmaxValues(2);
        power = file.cell.CWTmaxValues(3);

        switch dataType
            case 'power'
                data = power;
            case 'frequency'
                data = freq;
            case 'phase'
                data = phase;
        end

        % if data is frequency or phase - remove low power data 
        if strcmp(dataType,'phase') || strcmp(dataType,'frequency')
            removeFlag = removeLowPowerData(file);
           if removeFlag; data = []; end
        end 

        dataArray{iID} = data;
        clearvars file;
    end

    allData{iCell,1} = cell2mat(dataArray); % save cell data
end

if nCellTypes > 2
    saveFilename = [saveFolder filesep sprintf('%s %s %s %s stats.xlsx',dataSet,protocol,experiment,dataType)];
    stats = myMultipleIndependentGroupStats(allData,cell_types,comments,saveFilename,savenum);
else 
    stats.kw = [];
end

% use non parametric stats for figures

% convert data to log for power plots
% if strcmp(dataType,'power')
%     allData = cellfun(@log10,allData,'UniformOutput',false); % returns cell array
% %     saveFilename = [saveFolder filesep sprintf('%s %s %s %s LOG stats.xlsx',dataSet,protocol,experiment,dataType)];
% %     LOGstats = myMultipleIndependentGroupStats(allData,cell_types,comments,saveFilename,savenum);
% end

if strcmp(dataType,'power')
    y = getYparams(dataType,protocol,'log');
else
    y = getYparams(dataType,protocol,'normal');
end

groupLabels = myGroupLabels(cell_types);
[colors,alphas] = getColorAlpha(cell_types,1);
pTitle = sprintf('%s %s %s',dataSet,protocol,experiment);

figBox = myBoxplot(allData,groupLabels,y,colors,alphas,stats.kw);
sgtitle(pTitle,'Fontweight','bold');

figViolin = plotViolin(allData,groupLabels,y,colors,alphas);
sgtitle(pTitle,'Fontweight','bold');

if strcmp(dataType,'power') || strcmp(dataType,'frequency')
    figBar = myBarChart(allData,groupLabels,y,colors,alphas,stats.kw);
    sgtitle(pTitle,'Fontweight','bold');
end

if savenum
    saveFilename = [saveFolder filesep sprintf('%s %s %s %s',dataSet,protocol,experiment,dataType)];
    print(figBox,'-vector','-dsvg',[saveFilename ' Boxplot.svg']); % save boxplot as svg file
    if strcmp(dataType,'power') || strcmp(dataType,'frequency')
        print(figBar,'-vector','-dsvg',[saveFilename ' BarChart.svg']); % save barchart as svg file
    end
    print(figViolin,'-vector','-dsvg',[saveFilename ' Violin.svg']); % save violin plots as svg file
end

close all;

end

end

end



end

