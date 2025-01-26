function [x,y,z,CWTcycleValues] = thetaCWT(file,fieldName,cycle_start_index_noArtifacts)

    % make scalogram for theta stim ephys data
    wname = 'amor'; % 'morse' (default), 'amor', 'bump'
    VoicesPerOctave = 32; % number of scales per octave
    flimits = [0 300]; % frequency limits for wavelet analysis
    
    delta_phase = 2*pi/file.cycle_length;
    cycle_phase = -pi:delta_phase:pi;
    fb = cwtfilterbank('Wavelet',wname,'SignalLength',numel(cycle_phase),...
    'FrequencyLimits',flimits,'SamplingFrequency',file.Fs,'VoicesPerOctave',VoicesPerOctave);
    
    % only use cycles without artifacts
    nCycles = numel(cycle_start_index_noArtifacts);
    
    cycles = 1:nCycles;

    CWTcycleValues = zeros(nCycles,3);
    
    for icycle = 1:numel(cycles)
           cycle = cycles(icycle);
           cycle_start = cycle_start_index_noArtifacts(cycle);
           cycle_stop = cycle_start + file.cycle_length; 
           
           window_data = file.(fieldName).gamma_data(cycle_start:cycle_stop);
    
%            figure;
%            subplot(2,1,1); plot(window_data)
%            subplot(2,1,2); plot(file.stim.raw_data(cycle_start:cycle_stop))

           if icycle == 1
               [wt,freq] = cwt(window_data,'FilterBank',fb);
               [x,y] = meshgrid(cycle_phase,freq);
               z_cycle = abs( wt ).^2;
               z = z_cycle;
           else
               [wt,~] = cwt(window_data,'FilterBank',fb);
               z_cycle = abs( wt ).^2;
               z = z + z_cycle;
           end

        CWTcycleValues(icycle,:) = getMaxValues(x,y,z_cycle);

    end
    z = z / nCycles;
        
end