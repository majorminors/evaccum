function [EEG,MEGMAG,MEGPLANAR,conditions,chanlabels,badchans,trialinfo] = extract_chans_withtrialnums(filename)
%Extract MEEG timeseries from D spm object 
% output: chans x samples x trials
% example: [EEG,MEGMAG,MEGPLANAR,conditions,chanlabels,badchans] = extract_chans(SL_subj_3.mat)
%at 2020

%Make sure you have your SPM in the path
%%addpath(SPM)

D = spm_eeg_load(filename);
conditions = D.conditions;
trialinfo = trialtag(D, ':');
trialinfo = cell2mat(trialinfo);%it includes trial number and run number - more info can be added in the pipeline
modalities = {'EEG','MEGMAG','MEGPLANAR'};

for im = 1:length(modalities)
    
    %select channels
    indCh = D.indchantype(modalities{im});
    chanlabels{im} = D.chanlabels(indCh);
    badchans{im} = ismember(indCh,D.badchannels);%if bad channels
    
    eval(sprintf('%s = D(indCh,:,:);',modalities{im}));
    
end