function fig = plotCyclePPCs(dataCell,cellType)

% types = {'Stim','Theta','Gamma'};
% maxSpikes = 4;

minTotalSpikes = 10;

nNeurons = numel(dataCell);
nCycles = numel(dataCell{1});

switch cellType
    case 'stellate'
        color = [1 0 0];
        maxSpikes = 3;
    case 'pyramidal'
        color = [1 0.4 0];
        maxSpikes = 3;
    case 'fast spiking'
        color = [0 0 1];
        maxSpikes = 4;
end

ppc0 = cell(nNeurons,maxSpikes);

for iNeuron = 1:nNeurons
    spike_phases = dataCell{iNeuron}; % nCycles x 1 cell array

     for iSpike = 1:maxSpikes
        phase_cell = cell(nCycles,1); % make raster cell for each trace
        
        for iCycle =  1:nCycles
            cycle_spike_phases = spike_phases{iCycle}; % vector of spike phases

            if numel(cycle_spike_phases) < iSpike
                phase_cell{iCycle} = double.empty(1,0); 
            else
                phase_cell{iCycle} = cycle_spike_phases(iSpike);
            end

        end

        phase_cell = phase_cell(~cellfun('isempty',phase_cell)); % remove empty cells 
        phases = cell2mat(phase_cell);

        % if number of cycles with spikes is < 10... do not record PPC
        if numel(phases) < minTotalSpikes
            ppc0{iNeuron,iSpike} = NaN;
        else
            ppc0{iNeuron,iSpike} = PPC(phases); 
        end

     end
end

ppcArray = cell2mat(ppc0);
fig = plotPPC(ppcArray,cellType,color); % plot PPC

    function fig = plotPPC(ppc0,cellType,color)
        % add nice colors
%         c =  [0.45, 0.80, 0.69;...
%               0.98, 0.40, 0.35;...
%               0.55, 0.60, 0.79;...
%               0.90, 0.70, 0.30]; 

        % check if any columns are all NaN - remove group but save correct labels
        nGroups = size(ppc0,2);

        lin_ppc0 = ppc0(:);

        nan_mask = isnan(lin_ppc0);
        lin_ppc0(nan_mask) = []; % remove NaNs from linear array

        groups = ones(numel(ppc0),1);
        for i = 2:nGroups
            idx_start = ((i-1)*size(ppc0,1)) + 1;
            idx_stop = idx_start + size(ppc0,1) - 1;
            groups(idx_start:idx_stop) = i*ones(size(ppc0,1),1);
        end
        groups(nan_mask) = []; % remove NaNs from linear array

        newGroups = unique(groups);
        newNGroups = numel(newGroups);

        colors = repmat(color,[newNGroups, 1]);

        labels = cell(newNGroups,1);
        for iGroup = 1:newNGroups
            group = newGroups(iGroup);
            ppc_group = lin_ppc0(groups == group);
            N = numel(ppc_group);
            labels{iGroup} = sprintf('%s_{S%d} (n=%d)',cellType,group,N);
        end

        tickfontsize = 15;

        % plot PPC
        fig = figure;
        if ~isempty(lin_ppc0)
            if nargin < 3 
                daviolinplot(lin_ppc0,'groups',groups,'xtlabels',labels); % default colors
            else
                daviolinplot(lin_ppc0,'groups',groups,'xtlabels',labels,'color',colors); % my colors
            end
        end
        ylim([-0.5 1.5])
        ylabel({'Pairwise Phase';'Consistency'});
        ax = gca;
        ax.YAxis.FontSize = tickfontsize;
        ax.YAxis.FontWeight = 'bold';
        ax.XAxis.FontSize = tickfontsize;
        ax.XAxis.FontWeight = 'bold';
    end

end