function file = analyzeThetaVoltageLFP(fullfilename,printnum,savenum,saveFolder,info)

file.name = fullfilename;
file.info = info;

file.stimType = 'theta';

% choose data to analyse
file.cycles = 1:40; % choose data cycles for average analysis
file.trials = 1; % choose trials for to average scalogram over

% filter params
file.theta_bandpass = [4 12]; % Hz
file.gamma_bandpass = [50 200]; % Hz
file.filter_order = 4; % theta filter must be max order 4 - gamma can be higher

% detect artifact parameters
file.cell.range_threshold = 200; % (mV) window data ranges > threshold are detected as artifacts 
file.lfp.range_threshold = 1000; % (uV) window data ranges > threshold are detected as artifacts 

% load data from .abf file
[data,si,file_info] = abfload(file.name,'start',0,'stop','e');

backslash_index = strfind(file_info.protocolName,'\');
file.protocol_name = file_info.protocolName(backslash_index(end)+1:end-4);

switch file.protocol_name
    case 'theta_stim_bothChannels'
        file.cell.raw_data = squeeze(data(:,1,:));
        file.lfp.raw_data = squeeze(data(:,2,:))*1000; % mV to uV
        file.stim.raw_data = squeeze(data(:,3,:));   
        file.cell.data_units = char(file_info.recChUnits(1));
        file.lfp.data_units = 'uV'; % lfp data is converted to uV instead of mV
        file.dataChannels = {'cell','lfp'};
    case 'theta_stimulus_LFP'
        % lfp channel not connected
        file.cell.raw_data = squeeze(data(:,2,:));
        file.stim.raw_data = squeeze(data(:,3,:));   
        file.cell.data_units = char(file_info.recChUnits(2));
        file.dataChannels = {'cell'};
%     case 'theta_current_stim'
%         % single data channel - 8 Hz current input
%         file.cell.raw_data = squeeze(data);
%         file.cell.data_units = char(file_info.recChUnits(1));
%         file.dataChannels = {'cell'};
%     case 'theta_pulse_stim'
%         % 8 Hz pulse led input - 54 % duty cycle
%         file.cell.raw_data = squeeze(data(:,1,:));
%         file.stim.raw_data = squeeze(data(:,2,:));   
%         file.cell.data_units = char(file_info.recChUnits(1));
%         file.dataChannels = {'cell'};
     otherwise
        file.cell.raw_data = squeeze(data(:,1,:));
        file.stim.raw_data = squeeze(data(:,2,:));   
        file.cell.data_units = char(file_info.recChUnits(1));
        file.dataChannels = {'cell'};
end

file.nDataChannels = numel(file.dataChannels);

file.dt = si*(1e-6); % sampling interval (seconds)
file.Fs = 1/file.dt; % sampling frequency (Hz)

% get experimental params
if numel([file_info.DACEpoch]) > 1
    dacInitLevels = [file_info.DACEpoch.fEpochInitLevel];
    dacPulsePeriods = [file_info.DACEpoch.lEpochPulsePeriod];
    file.led_input = dacInitLevels(end); % mV
    file.cycle_length = dacPulsePeriods(end);
else
    file.led_input = file_info.DACEpoch.fEpochInitLevel(end); % mV
    file.cycle_length = file_info.DACEpoch.lEpochPulsePeriod(end);
end

% can also get stim freq from
file.stim_freq = round(file.Fs / file.cycle_length); % Hz

if isfield(file_info, 'comment')
    file.comment = file_info.comment;
else 
    file.comment = 'no comment found';
end

if printnum
    fprintf('Protocol: %s\n',file.protocol_name);
    fprintf('LED Input = %g mV\n',file.led_input);
    fprintf('Stim Frequency: %g Hz\n',file.stim_freq);
    fprintf('%s\n',file.comment);
end

[nSamples,~,ntrials] = size(data);

if strcmp(file.trials,'all')
   file.trials = 1:ntrials;
end
file.nTrials = numel(file.trials);

% construct time axis for plotting
time = (0:nSamples-1)*file.dt; % time in sec
file.time = time'; % column vector

file.cycle_start_index = getCycleStartIndices(file.stim.raw_data, file.cycle_length, file.time, 0);

file.nCycles = numel(file.cycles);

if numel(file.cycle_start_index) < file.nCycles 
    disp('SKIPPED FILE: cycles indices out of range');
    return;
end

file.saveFolder = sprintf('%s - %g mV',saveFolder,file.led_input);
if ~exist(file.saveFolder, 'dir')
   mkdir(file.saveFolder)
end

% alternative add theta and gamma components to make threshold
file = detectArtifacts(file); % skip theta cycles with artifacts

for i = 1:file.nDataChannels
    fieldName = file.dataChannels{i};

%     if file.nTrials > 1 
%         % average data across trials 
%         file.(fieldName).raw_data = mean(file.(fieldName).raw_data,2);
%     end

    % concatenate data from cycles with no artifacts?
    file.cycles_noArtifacts = reshape(file.cycles(~file.(fieldName).spikes(file.cycles)),1,[]); % row vector
    file.cycle_start_index_noArtifacts = file.cycle_start_index(file.cycles_noArtifacts); % assumes 1 trial of data

    switch fieldName
        case 'cell'
            % write function for detecting spikes
            [file,figSpikes,figRaster,figFRs] = detectPatchSpikes(file,fieldName,1);

            figData = plotThetaVoltageData(file,fieldName);

            if savenum
                print(figSpikes,'-vector','-dsvg',[file.saveFolder filesep fieldName ' Data spike detection.svg']);
                print(figData,'-vector','-dsvg',[file.saveFolder filesep fieldName ' Data example.svg']);
                print(figRaster,'-vector','-dsvg',[file.saveFolder filesep fieldName ' Raster.svg']);
                print(figFRs,'-vector','-dsvg',[file.saveFolder filesep fieldName ' FRs.svg']);
            end

        case 'lfp'
            % filter data into theta and gamma frequency components
            file.(fieldName).theta_data = filterData(file.(fieldName).raw_data,file.Fs,file.theta_bandpass,file.filter_order);
            file.(fieldName).gamma_data = filterData(file.(fieldName).raw_data,file.Fs,file.gamma_bandpass,file.filter_order);
            
            % only analyze data without artifacts 
            [x,y,z] = thetaCWT(file,fieldName);
            file.(fieldName).CWTmaxValues = getMaxValues(x,y,z);
            file.(fieldName).CWTpeakStats = getXmaxPeakStats(x,y,z,file.(fieldName).CWTmaxValues(1),[0 200],0);
            
            % plot all data trials and artifacts 
            figData = plotData(file,fieldName);
            sgtitle(figData,sprintf( '%s - Stim: %g Hz - LED Input: %g mV - Peak Gamma: %d Hz',file.name,file.stim_freq,file.led_input,round(file.(fieldName).CWTmaxValues(2)) ),'FontWeight','bold','Interpreter','none');
            
            file = plotHeatMap(file, fieldName, savenum);

            % plot scalogram from data without artifacts 
            figCWT = plotScalogram(x,y,z,"",file.(fieldName).CWTmaxValues,file.(fieldName).data_units,file.stimType);
            
            % compute and plot PSD from data without artifacts 
            % need to better identify gamma peak in PSD
            [file.(fieldName),figPSD] = plotCyclePSD(file.(fieldName),file.Fs,file.cycle_start_index_noArtifacts,file.cycle_length);
            
            if printnum
                fprintf('%s Gamma Frequency: %d Hz\n',fieldName,round(file.(fieldName).CWTmaxValues(2)));
            end
            
            % change gamma bandpass filter here based on CWT peak?
            
            if savenum
                print(figData,'-vector','-dsvg',[file.saveFolder filesep fieldName '.svg']);
                print(figPSD,'-vector','-dsvg',[file.saveFolder filesep fieldName ' Raw Data Cycle PSD.svg']);
                saveas(figCWT,[file.saveFolder filesep fieldName ' scalogram.svg']);
            end
      
    end
    
end

% spikeLFP analysis
if file.nDataChannels == 2

%     figRasterLFP = plotRasterLFP(file); % plot average gamma per theta cycle on raster plot

%     plotRasterLFPHeatmap(file); % plot LFP Gamma heatmap on top of raster plot

    file = getLFPphase(file, 1, 1, 0); % LFP theta and gamma phase
    file = segmentGamma(file,0); % segment gamma cycles over each theta stim period
    plotGammaBins(file, 1); % plot gamma bins as heatmap
    
%     % spike gamma bin analysis - not applicable - plot for each neuron?
%     spikes = spikeGammaBinHistogram(spikes,lfp,1); % combine cell type data for patch
%     spikeGammaBinHeatMap(spikes,lfp, 1); % spike gamma bin heatmap instead of histogram - sort by cycle #

%     plotPolar(spikes, lfp, 1); % polar plots for spike times relative to theta and gamma
%     
%     % plotPPCs(spikes, lfp, 1); % pairwise phase consisency - unbiased phase locking value
%     plotCyclePPCs(spikes, lfp, 1)

%     % plotSTAs(spikes, lfp, frame_rate, 1); % plot STAs for each neuron for both theta and gamma
%     plotCycleSTAs(spikes, lfp, frame_rate, 1) % compute STA for each first, second, third spike etc.

%     % cycle by cycle spike coherence?
%     plotSpikeCoherence(spikes, lfp, frame_rate, 1); % spike-field coherence

    % plot spikes on top of gamma
%     figSpikeGamma = spikeGammaOverlay(file);


%     [file,figXcorr] = patchLFPxcorr(file); % cycle current-lfp cross corr
%     if savenum == 1
%         saveas(figXcorr,[saveFolder filesep fieldName ' Xcorr.png']);
%     end
end




end