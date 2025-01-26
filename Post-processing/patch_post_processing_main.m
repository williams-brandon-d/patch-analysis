% patch post processing comparisons

clear variables; close all; clc;
cd('C:\Users\brndn\OneDrive\Desktop\White Lab\Matlab Files\');
addpath(genpath('./')); % add all folders and subfolders in cd to path

dataSets = {'Thy1','PV Transgenic'};
savenum = 1; % 0 = don't save, 1 = save info

% theta 

% voltage clamp

% before and after dnqx boxplots
boxplotBeforeAndAfterDNQX({'Thy1'},{'DNQX before','DNQX before 10 uM'},{'DNQX after','DNQX after 10 uM'}, savenum);

% compare scalogram values
% boxplotCellData(dataSets, {'','DNQX before','GBZ before','DNQX_GABAzine_before', 'Gabazine before'}, savenum);

% compare PSD values - harmonics make it difficult to estimate peak frequency in gamma range
% plotCellPSDdata(dataSets, {'','DNQX before','GBZ before','DNQX_GABAzine_before', 'Gabazine before'}, savenum);

% plot theta cwt values over each cycle - synaptic depression
% plotThetaCycleValues(dataSets, {'','DNQX before','GBZ before','DNQX_GABAzine_before', 'Gabazine before'}, savenum);

% plot theta amplitude across cycles 
% plotThetaAmplitudeValues(dataSets, {'','DNQX before','GBZ before','DNQX_GABAzine_before', 'Gabazine before'}, savenum);

% plotCamk2inhibitionVsLFPpower(); % plot inhibition vs LFP power

% currentclamp
% 
% plotThetaStimSpikePhaseHist(dataSets, savenum); % histogram spike phases for each cell type
% 
% plotThetaStimSpikeRateHist(dataSets, savenum); % histogram all FRs for each cell type

% plotAverageThetaSpikes(dataSets, savenum); % plot violin with average spikes per theta cycle for each cell type

% StimCyclePPCs(dataSets, savenum); % phase locking to stim theta for thy1 and pv data sets

% currentclamp data before and after dnqx has low N values - skip plotting firing rates
% plotThetaPhaseHistDNQX({'Thy1'},{'DNQX before','DNQX before 10 uM'},{'DNQX after','DNQX after 10 uM'}, savenum); % plot paired before and after DNQX comparison for thy1

% spike - lfp analysis for camk2 data
% combine all spike data to check for gamma phase locking?