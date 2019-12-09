%%
clear all
clear classes

close all
clc
addpath /hpc-software/matlab/cbu/

addpath /imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Preprocessing/
addpath /imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Preprocessing/lib/

droot = '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/MEGData/';
infld = '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/MEGData/%s/MEEG/MaxfilterOutput/';
tarfld= '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/MEGData/%s/MEEG/Preprocess/';
behav = '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Behav/MEGBehav/%s_MEGRT.mat';
megrt = '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Behav/%s_MEGtrg_RT.mat';
ICA   = '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/MEGData/%s/MEEG/ICAOutput/ICA%s_PD.mat';
outpt = '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/MEGData/%s/MEEG/Preprocess/MSL_%s.mat';
addpath(droot);


[dname,IDnum] = getnames(droot,7);
bname         = getnames('/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Behav/MEGBehav/',10);
bname = unique({bname{:}});

%% parallel processing
locpar = 0;%1 local 0 cluster

%%
clc


filename    = 'Run%d_%s_trans.fif';
outfirst    = 'Run%d_%s_trans.mat';
outfilename =  '%s_trans.mat';

settings.fld = tarfld;

settings.freshstart = 1;%delete everything before starting again -not needed for 1st preprocessing run
settings.overwrite = 0;
settings.ICAoverwrite = 1;


dependencies_path = {
    '/neuro/meg_pd_1.2/'
    '/hpc-software/matlab/cbu/'
    '/imaging/at07/Matlab/CommonScripts'
    '/imaging/at07/Matlab/CommonScripts/lib/'
    '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Preprocessing/'
     '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Preprocessing/lib/'
    '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/MEGData/'
    '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Behav/'
    '/imaging/at07/Matlab/Projects/CBU2016/RDK_PD/Behav/MEGBehav/'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/external'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/adminfunc'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/guifunc'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/javachatfunc'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/miscfunc'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/popfunc'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/resources'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/sigprocfunc'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/statistics'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/studyfunc'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/functions/timefreqfunc'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/plugins'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/plugins/ADJUST1.1.1'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/plugins/dipfit2.3'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/plugins/dipfit2.3/standard_BEM'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/plugins/dipfit2.3/standard_BEM/elec'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/plugins/dipfit2.3/standard_BEM/skin'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/plugins/dipfit2.3/standard_BESA'
    '/imaging/at07/Matlab/Toolboxes/eeglab13_5_4b/plugins/firfilt1.6.1'
    };


funanon = @fun_rdk_preproc_PD;


%%
J = [];
ind = 0;

for subi = 1:length(dname)
    
       ID = getMEGID(sprintf('AT_RDK2_%s',IDnum{subi}));
       
       settings.outfname= sprintf([tarfld,outfilename],dname{subi},dname{subi});
       settings.dname = dname{subi};
       settings.ctr   = ID.ctr;
       settings.bEEG  = ID.bad_eeg;
       settings.bMEG  = ID.bad_meg;
       settings.behav = sprintf(behav,bname{subi});
       settings.svbeh = sprintf(megrt,dname{subi}); 
       settings.ICA   = sprintf(ICA,dname{subi},dname{subi}); 
  
       settings.infname = {};settings.outfirst={};

        for runi = 1:12
            
            if exist(sprintf([infld filename], dname{subi}, runi, dname{subi}),'file')
                settings.infname{end+1} = sprintf([infld filename], dname{subi}, runi, dname{subi});
                settings.outfirst{end+1}= sprintf([tarfld outfirst], dname{subi}, runi, dname{subi});
            end
        end       

        if ~exist(sprintf(outpt,dname{subi},dname{subi}),'file') || settings.overwrite
        %if ~exist(sprintf(outpt, dname{subi},ID.subj),'file')||settings.overwrite %don't repeat if exists
            ind = ind + 1;
            J(ind).task = funanon; %#ok<*SAGROW>
            J(ind).n_return_values = 0;
            J(ind).input_args = {settings};
            J(ind).depends_on = 0;
       end
    
    
end

if locpar
    % ParType = 0;  % Fun on Login machines (not generally advised!)
    % ParType = 1;   % Run maxfilter call on Compute machines using spmd (faster)
    ParType = 2;   % Run on multiple Compute machines using parfar (best, but less feedback if crashes)
    
    % open matlabpool if required
    % matlabpool close force CBU_Cluster
    if ParType
        if  isempty(gcp('nocreate'))%matlabpool('size')==0;
            P = cbupool(6);
            P.ResourceTemplate='-l nodes=^N^,mem=22GB,walltime=10:00:00';
            parpool(P);
        end
    end
    
    parfor subi = 1:length(dname)
        
        fun_rdk_preproc_PD(J(subi).input_args{1});
        
    end
    
    if ParType
        parpool close force CBU_Cluster
    end
    
    
    
elseif locpar == 0
    
    S = cbu_scheduler();
    S.NumWorkers = 37;
    S.SubmitArguments = '-l mem=20GB -l walltime=96:00:00'; %20GB 96:00:00 more than 10GB recommended
    
    if ~exist('/home/at07/matlab/jobs/rdkICA/','dir'); mkdir('/home/at07/matlab/jobs/rdkICA/');end
    S.JobStorageLocation = '/home/at07/matlab/jobs/rdkICA/';
    
    %%
    !rm -r /home/at07/matlab/jobs/rdkICA/*
    cbu_qsub(J, S, dependencies_path)
    
end