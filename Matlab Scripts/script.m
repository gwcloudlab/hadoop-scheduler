
clear all; close all; clc;
load('new-trace-6datanodes-2013.11.12.mat')
normalizeTCT;
jobs = {'grepsearch'; 'grepsort'; 'kmeansclass'; 'kmeansiterator'; 'pi'; 'sort'; 'terasort'; 'wc'};
RMSE_array = [];

for i = 1: length(jobs)

    job = char(jobs(i));

    observed_cpu = eval(['tpcw_',job, '_cpu']); 
    observed_tct = eval(['tpcw_',job, '_tct']);

    predicted_cpu = eval([job, '_cpu']);
    predicted_tct = eval([job, '_tct']);

    %%
    %Clean the data. We want to predict the values only upto which we have
    %trained data values for. For example, if we have training data only upto a CPU
    %utilization value of 170, we should predict only upto 170 and not more
    %than that. So, we trim the observed(actual) data from tpcw or cloudstone
    %upto the max of predicted CPU.

    max_trained_cpu = max(predicted_cpu);
    indices = find(observed_cpu <= max_trained_cpu);
    observed_cpu = observed_cpu(indices);
    observed_tct = observed_tct(indices);

    %%
    [fitresult, gof] = createFit(predicted_cpu, predicted_tct, job);
    [ predicted_tct, predicted_cpu, MSE, RMSE ] = training_error( observed_cpu, observed_tct, fitresult);
    RMSE_array = [RMSE_array RMSE];
    
    % Save the output to a file to plot it in gnuplot
    eval([jobs{i} '= ' '[observed_cpu, observed_tct, predicted_tct]' ';']);
    save(['results/exp2' jobs{i} '.txt'],jobs{i}, '-ascii','-tabs');
    
    createfigure(observed_cpu,[observed_tct,predicted_tct], job, 'CPU Utilization', 'Normalized TCT');
    
    
    
    display(job)
    display(fitresult)
    display(gof)
    display(MSE)
    display(RMSE)
end