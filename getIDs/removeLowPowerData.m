function removeFlag = removeLowPowerData(file)

fieldName = 'cell';

phase = file.(fieldName).CWTmaxValues(1);
freq = file.(fieldName).CWTmaxValues(2);
power = file.(fieldName).CWTmaxValues(3);

if ~isfield(file.(fieldName),'meanSpectralNoise')
    [file.(fieldName).meanSpectralNoise,file.(fieldName).stdSpectralNoise] = estimateSpectralNoise(file,fieldName,0); % estimate spectral noise
    save([file.saveFolder filesep 'data.mat'],'file','-mat','-nocompression'); % save updated file struct
end

% std_factor = 3; % peak data power must be 3 std above the mean spectral noise
% power_threshold = file.(fieldName).meanSpectralNoise + std_factor*file.(fieldName).stdSpectralNoise; % pA^2

power_threshold = 20; % pA^2

freq_threshold = 55;
phase_threshold = 3;
% width?

removeFlag = (freq > freq_threshold) & ...
                    (power > power_threshold) & ...
                    (phase > -1*phase_threshold) & ...
                    (phase < phase_threshold);

removeFlag = ~removeFlag;

end