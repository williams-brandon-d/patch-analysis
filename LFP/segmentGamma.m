function file = segmentGamma(file,plotnum)
% find gamma cycles in gamma filtered data

nCycles = numel(file.cycles);

delta_phase = 2*pi/file.cycle_length;
cycle_phase = (-pi:delta_phase:pi)'; 

maxGammaFreq = file.gamma_bandpass(2); % Hz
minPeakDist = floor(file.Fs / maxGammaFreq); % samples

noise_time_length = 0.3; % seconds
% noise_start_index = file.cycle_start_index(end) + file.cycle_length; % start after stim
noise_start_index = 1; % start at beginning

noise_stop_index = noise_start_index + noise_time_length*file.Fs;
noise_indices = noise_start_index:noise_stop_index;
noise_data = file.lfp.gamma_data(noise_indices);

% change this parameter to change threshold
minPeakHeight = 2.5*std(noise_data);
minPeakProm = 2*minPeakHeight;

% generate noise PSD
% TW = 3;
% ntapers = 2*TW-1;
% params.Fs = frame_rate;
% params.tapers = [TW,ntapers];
% params.pad = -1; % no padding
% params.trialave = 0;
% [S,f] = mtspectrumc( noise_data, params );
% figure;
% plot(f,S)
% xlabel('Frequency (Hz)');
% ylabel('PSD (uV^2/Hz)');
% xlim(lfp.gamma_bandpass);

% data = lfp.gamma_data_ds(lfp.stim_indices_ds);
% phase = lfp.gamma_phase_ds(lfp.stim_indices_ds);

stim_indices = file.cycle_start_index(file.cycles(1)):(file.cycle_start_index(file.cycles(end))+file.cycle_length);

file.lfp.gamma_start_indices = cell(nCycles,1);
file.lfp.gamma_stop_indices = cell(nCycles,1);

% for each theta cycle find gamma peaks and separate by gamma cycle 
file.lfp.gamma_cycle_bins = zeros(numel(stim_indices),1);

for iCycle = 1:nCycles 
    cycle = file.cycles(iCycle);
    cycle_indices = file.cycle_start_index(cycle) + (0:file.cycle_length);

    data = file.lfp.gamma_data(cycle_indices);
    phase = file.lfp.gamma_phase(cycle_indices);

    [~,locs_pos] = findpeaks(data,'MinPeakDistance',minPeakDist,'MinPeakHeight',minPeakHeight,'MinPeakProminence',minPeakProm);
%     [~,locs_neg] = findpeaks(-1*data,'MinPeakDistance',minPeakDist,'MinPeakHeight',minPeakHeight,'MinPeakProminence',minPeakProm);

    if isempty(locs_pos); continue; end % skip cycles with no peaks above threshold

    % exclude peaks outside +- 3*pi/4
    phase_threshold  = 2*pi/3;
    locs_pos = locs_pos( (locs_pos > find(cycle_phase < -1*phase_threshold,1,'last')) & (locs_pos < find(cycle_phase > phase_threshold,1,'first')) );

    if isempty(locs_pos); continue; end % skip cycles with no peaks above threshold

    % find first and last peak then find all positive peaks in between
    [~,locs_all] = findpeaks(data,'MinPeakHeight',0);
    locs_mid = locs_all( (locs_all > locs_pos(1)) & (locs_all < locs_pos(end)) );
    locs_mid = reshape(locs_mid,[],1); % column vector
    locs_pos = [locs_pos(1); locs_mid; locs_pos(end)];
    
    % find local min phase prior to gamma peak and max phase after
    [~,phase_min_locs] = findpeaks(-1*phase,'MinPeakDistance',3,'MinPeakHeight',pi/2,'MinPeakProminence',pi);
    [~,phase_max_locs] = findpeaks(phase,'MinPeakDistance',3,'MinPeakHeight',pi/2,'MinPeakProminence',pi);
    
    nGammaPeaks = numel(locs_pos);
    gamma_cycle_start = zeros(nGammaPeaks,1);
    gamma_cycle_stop = zeros(nGammaPeaks,1);
    
    for iGamma = 1:nGammaPeaks
        prev_phase_min = phase_min_locs(phase_min_locs < locs_pos(iGamma));
        after_phase_max = phase_max_locs(phase_max_locs > locs_pos(iGamma));

        if isempty(after_phase_max) || isempty(prev_phase_min)
            locs_pos(iGamma) = 0;
        else
            if iGamma == 1 
                gamma_cycle_start(iGamma) = prev_phase_min(end); % find local min phase prior to gamma peak
            else 
                gamma_cycle_start(iGamma) = gamma_cycle_stop(iGamma-1) + 1;
            end
            gamma_cycle_stop(iGamma) = after_phase_max(1); % find local max phase after gamma peak
        end
    end

    % remove zero values from locs_pos and gamma cycle indices 
    locs_pos(locs_pos == 0) = [];
    gamma_cycle_start(gamma_cycle_start == 0) = [];
    gamma_cycle_stop(gamma_cycle_stop == 0) = []; 

    % plot gamma cycles data and phase
    if plotnum
        plotGammaCycles(data,phase,cycle_phase,locs_pos,gamma_cycle_start,gamma_cycle_stop);
    end

    % save gamma cycle indices
    file.lfp.gamma_start_indices{iCycle} = gamma_cycle_start; % save gamma start indices
    file.lfp.gamma_stop_indices{iCycle} = gamma_cycle_stop; % save gamma start indices

    % save gamma mask with cycle numbers 
    for iGamma = 1:numel(gamma_cycle_start)
        gamma_indices = file.cycle_length*(iCycle-1) + (gamma_cycle_start(iGamma):gamma_cycle_stop(iGamma)) - 1;
        file.lfp.gamma_cycle_bins(gamma_indices) = iGamma;
    end

end

% figure; plot(gamma_cycle_bins); xlim([-inf inf]);


function plotGammaCycles(data,phase,cycle_phase,locs_pos,gamma_cycle_start,gamma_cycle_stop)
    tickfontsize = 15;
    color = load_fav_colors();

    N = numel(locs_pos);

%     nSamples = numel(data); 
%     dt = 1 / frame_rate;
%     time = (0:nSamples-1)*dt;

    figure;
    subplot(2,1,1);
    plot(cycle_phase,data,'k','Linewidth',2)
    xlim([-inf inf]);
    ylim([-30 30]); % uV
    hold on
%     plot(cycle_indices(locs_pos),data(locs_pos),'or')
%     plot(cycle_indices(gamma_cycle_start),data(gamma_cycle_start),'ob')
%     plot(cycle_indices(gamma_cycle_stop),data(gamma_cycle_stop),'og')
    for i = 1:N
        if i < N
           cycle_stop = gamma_cycle_start(i+1);
        else 
           cycle_stop = gamma_cycle_stop(i);
        end
        x = cycle_phase(gamma_cycle_start(i):cycle_stop);
        y = data(gamma_cycle_start(i):cycle_stop);
        area(x,y,'FaceColor',color(i,:),'EdgeColor','none');
    end
%     plot(time(locs_neg),data(locs_neg),'ob')
    hold off
    ylabel({'Gamma';'Amplitude (uV)'})
    title('Filtered Data');
    xticks([-pi -pi/2 0 pi/2 pi]);
    xticklabels({'-π','-π/2','0','π/2','π'});
    ax = gca;
    ax.YAxis.FontSize = tickfontsize;
    ax.YAxis.FontWeight = 'bold';
    ax.XAxis.FontSize = tickfontsize;
    ax.XAxis.FontWeight = 'bold';

    subplot(2,1,2);
    plot(cycle_phase,phase,'k','Linewidth',2)
    xlim([-inf inf]);
    ylim([-pi pi]); 
    hold on
%     plot(cycle_indices(locs_pos),phase(locs_pos),'or')
%     plot(cycle_indices(gamma_cycle_start),phase(gamma_cycle_start),'ob')
%     plot(cycle_indices(gamma_cycle_stop),phase(gamma_cycle_stop),'og')
    for i = 1:N
        if i < N
           cycle_stop = gamma_cycle_start(i+1);
        else 
           cycle_stop = gamma_cycle_stop(i);
        end
        x = cycle_phase(gamma_cycle_start(i):cycle_stop);
        y = phase(gamma_cycle_start(i):cycle_stop);
        area(x,y,'FaceColor',color(i,:),'EdgeColor','none');
    end
%     plot(time(locs_neg),phase(locs_neg),'ob')
    hold off
    ylabel({'Gamma';'Phase (rad)'});
    yticks([-pi -pi/2 0 pi/2 pi]);
    xticklabels({'-π','-π/2','0','π/2','π'});
    xticks([-pi -pi/2 0 pi/2 pi]);
    xticklabels({'-π','-π/2','0','π/2','π'});
    title('Hilbert Phase');
    xlabel('Stim Theta Phase (rad)')
    ax = gca;
    ax.YAxis.FontSize = tickfontsize;
    ax.YAxis.FontWeight = 'bold';
    ax.XAxis.FontSize = tickfontsize;
    ax.XAxis.FontWeight = 'bold';

end

end