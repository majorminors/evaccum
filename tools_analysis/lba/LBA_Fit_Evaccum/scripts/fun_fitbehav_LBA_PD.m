function fun_fitbehav_LBA_PD(settings,data)
% Fit LBA model to RDK-tapping task
% Use for  3-choice task: CONDITIONS segregated
% JZ 15/10/2014 - 4-choice tapping task
% AT 17/02/2016 adapted to 3-choice RDK task
% DM 02/2020 adapted to 2-choice RDK task

rseed = settings.rseed;
rng(rseed,'twister') % for reproducibility

%clear all
%%
savename = settings.savename;
Model_Feature = settings.modfeat; % model variant for this job

% optional but doesn't save time (thought it would be faster than normal
% gradient descent, but isn't)
if ~isfield(settings,'bayesOptim')
    bayesian = 0;
else
    bayesian = settings.bayesOptim;
    if bayesian
        addpath(genpath('/imaging/at07/Matlab/Toolboxes/bads'));
    end
end

num_subjs = sum(~cellfun('isempty',{data.id})); % get the number of not empty arrays from the first field of the 'data' structure

%initialise cells
data2fit={}; ;%#ok

for idxsubj = 1:length(num_subjs)
    %%
    clear rt conds resp acc % clear vars from behavioural data to avoid reading mixed subject data
    fprintf('loading subject %1.0f \n',data(idxsubj).id);
    
    % pull the data
    subjdata = data(idxsubj).data; % put the data in a readable variable
    dataValid = []; % now we'll strip invalid responses out
    validLabs = {};
    for i = 1:size(subjdata,1)
        if subjdata{i,5} >= 0 % if there's a valid response
            dataValid(end+1,:) = [subjdata{i,2} subjdata{i,3} subjdata{i,4} subjdata{i,5}]; % add the following rows to this new variable in order: condition code, response, rt, accuracy
            temp = subjdata{i,1}; % extract valid condition label (can't do in one step with multi-level structures and non-scalar indexing)
            validLabs{end+1} = temp; % add the valid condition label
        end
    end; clear i temp;
    
    % converting again to readable variables
    conds = dataValid(:,1);
    resp = dataValid(:,2);
    rt = dataValid(:,3);
    acc = dataValid(:,4);    
    
    % do descriptive stats    
    minRT(idxsubj) = min(rt(rt>=0.1)); % not used
    

    %%
    %Pool conditions according to design matrix & calculate stats
    for level = 1:4 % four conditions
        
        trialn = conds == level;
        dataRaw{idxsubj,level}  = [resp(trialn) rt(trialn)];
        
        data2fit{idxsubj,level} = data_stats(dataRaw{idxsubj,level});

        % add some info to data2fit (the condition labels as a string, and
        % the minRT - in the case that the min rt is smaller than the
        % non-decision time - let's leave this for now, just in case)
        data2fit{idxsubj,level}.cond = validLabs{trialn};
        data2fit{idxsubj,level}.minRT = round(minRT(idxsubj),2);
        %parange(end,1) = round(minRT(idxsubj),2);%constrain the lower bound of T0 to the shortest RT
    end
    %%
end



% fit the basic model
% startpar=[1,1,1,1,1, .1 .3]; % initial parameter [boundary,four drift rate, non-decisiontime, drift rate std]
% upper staring-point is fixed
%randiter = 500;%100; % randome search 100 iters before optimization
%nosession = 100;%100;%20; % 20 optimization iterations

randiter  = settings.randiter;
nosession = settings.nosession;


% Model fitting

% model features that are available
% 1- std differs across fingers
% 2- C0  differs across fingers
% 3- B differs across conditions
% 4- Drift rate differs across conditions
% 5- t0 differs across conditions

%design_space={};
% design_space={[1,3],[1,4],[1,3,4],[1,3,4,5],[1,2],[1,2,3],[1,2,4],[1,2,3,4],[1,2,3,4,5]};
% Model_Feature=[1  4];
%
% numParam   =getModelParam_cell_RDK(Model_Feature,4);
%
% parange=[zeros(1,numParam);zeros(1,numParam)+10]';


%%


numParam   = getModelParam_cell_RDK(Model_Feature,2); % you will change this 4 to two - reflects response options
parange=[zeros(1,numParam);zeros(1,numParam)+10]';


for idxsubj = 1:length(num_subjs)
    
    [bestpar{idxsubj,1},bestval{idxsubj,1},BIC{idxsubj,1}]=fitparams_refine_template_RDK('fiterror_cell_RDK',Model_Feature,{data2fit{idxsubj,1:4}},randiter,nosession,[],parange,bayesian);%#ok
    
end

save(savename,'bestpar','bestval','BIC','rseed','settings');%,'bestpar_PA','bestval_PA','BIC_PA')

% Plotting...
% for iplot = 1:length(data2fit)
%     
%     figure; hold on;
%     plot(data2fit{iplot}.allObs(1:end-1,1),data2fit{iplot}.allObs(1:end-1,2),'k','Marker','o');
%     plot(data2fit{iplot}.allObs(1:end-1,1),cumRT_Free(1:end-1),'r','Marker','*');
%     legend({'data','model'},'Location','SouthEast');
%     % title({['Model params (B, A, Astd,To): [' num2str(bestpar(best_indx,:),2) ']'] });
%     title('Chosen condition');
%     ylim([0 1]);
%     % xlim([0.2,0.6]);
%     ylabel('Cumulative probability');
%     xlabel('Response Time (s)');
%     
%     figure; hold on;
%     temp=[data2fit{iplot}.priorProb{1:end}];
%     choiceProb=[temp;priorMod_FT];
%     bar(choiceProb');
%     legend({'data','model'});
%     set(gca,'XTick',[1:2]);
%     set(gca,'XTickLabel',{'Button 1' 'Button 2'});
%     title('Choice probability');
% end; clear iplot;

end