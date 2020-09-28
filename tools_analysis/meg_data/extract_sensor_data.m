% AW 5/8/20

% extract preprocessed sensor data into cosmo friendly format
rootdir    = '/group/woolgar-lab/projects/Dorian/EvAccum/';
megdatadir = fullfile(rootdir, 'data/meg_pilot_1/megdata/');
behavdatadir   = fullfile(rootdir,'data/meg_pilot_1/behavioural/');
behavfile = fullfile(behavdatadir,'S03/subj_3_MEGRTs.mat');

addpath(genpath('/imaging/local/software/spm_cbu_svn/releases/spm12_fil_r7487')); %spm
addpath('/group/woolgar-lab/projects/Dorian/EvAccum/tools_analysis/meg_data'); %where Ale's extract_chans function lives
%filename = '/imaging/at07/Matlab/Projects/Dorian/evaccum2/data/meg_pilot_1/megdata/subj_3/MEEG/Preprocess/SL_subj_3.mat';
%filename='/imaging/aw02/tempEA/SL_subj_3.mat';
filename='/group/woolgar-lab/projects/Dorian/EvAccum/data/meg_pilot_1/megdata/subj_3/MEEG/Preprocess/SL_subj_3.mat';
[EEG,MEGMAG,MEGPLANAR,conditions,chanlabels,badchans, trialinfo] = extract_chans_withtrialnums(filename);

load(behavfile,'MEG_RT'); % load the behavioural data
condnums = double(MEG_RT(:,5)); % pull the condition numbers and convert them from string array to number array
% so now we have the condition numbers (condnums) and the trials are tagged
% with the value needed to index into condnums (first row of trialinfo)

% Yields channel * timepoints * trials matrices

% next: reshape into cosmo format: 
% ds.samples = trials * timepoints
% ds.sa.targets = list of conditions (numeric)
% will also need chunks - any restrictions on what to hold out?
% ds.sa.rep can all be ones (is the repetitions of each condition per
% chunk)

% NB are we doing decoding next, or RSA?? :)
