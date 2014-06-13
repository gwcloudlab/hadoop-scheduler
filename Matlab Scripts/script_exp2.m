
clear all; close all; clc;
load('new-trace-6datanodes-2013.11.12.mat')
normalizeTCT;
jobs = {'grepsearch'; 'grepsort'; 'kmeansclass'; 'kmeansiterator'; 'pi'; 'sort'; 'terasort'; 'wc'};


for i = 1: length(jobs)

    job = char(jobs(i));
    predicted_cpu = eval([job, '_cpu']);
    predicted_tct = eval([job, '_tct']);

    %%
    [fitresult, gof] = modelFit(predicted_cpu, predicted_tct, job);
    
    %Generate data for the curve fit to plot using gnuplot
    
    coeffvals = coeffvalues(fitresult);
    
%     fitresult = 
% 
%      General model Exp2:
%      fitresult(x) = a*exp(b*x) + c*exp(d*x)
%        where x is normalized by mean 93.67 and std 46.19 %%%% x is always
%        normalized %%%%%%%
%      Coefficients (with 95% confidence bounds):
%        a =      0.5029  (0.4865, 0.5193)
%        b =      0.1326  (0.09788, 0.1672)
%        c =     0.01248  (0.004791, 0.02017)
%        d =       2.338  (2.01, 2.666)
    
    model_tct = coeffvals(1)*exp(coeffvals(2).*predicted_cpu) + coeffvals(3)*exp(coeffvals(4).*predicted_cpu);
   
    
    
    % Save the output to a file to plot it in gnuplot
    eval([jobs{i} '= ' '[predicted_cpu, predicted_tct, model_tct]' ';']);
    save(['results/exp2' jobs{i} '.txt'],jobs{i}, '-ascii','-tabs'); 
    
    display(job)
    display(fitresult)
    display(gof)
end