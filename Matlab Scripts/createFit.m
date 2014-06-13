function [fitresult, gof] = createFit(CPU, TCT, job)
%CREATEFIT(CPU,TCT)
%  Create a fit.
%
%  Data for 'curve fit' fit:
%      X Input : CPU data -- single column
%      Y Output: TCT data -- single column
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%


%% Fit: 'curve fit'.

[xData, yData] = prepareCurveData( CPU, TCT );

% Set up fittype and options.
ft = fittype( 'exp2' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf -Inf];
opts.StartPoint = [0.895775889852398 0.00360043611152319 0.0229432157634263 0.0318090334165192];
opts.Upper = [Inf Inf Inf Inf];
opts.Normalize = 'off';

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

%disp(gof);
% Plot fit with data.
figure1 = figure;

plot1 = plot( fitresult, xData, yData );
legend('tct vs. cpu', 'curve fit', 'Location', 'NorthWest' );
title(job,'FontWeight','bold','FontSize',20);
% Label axes
xlabel( 'cpu' );
ylabel( 'tct' );
grid on;
set(gcf,'Visible', 'off', 'PaperUnits','inches','PaperSize',[8.5,11],'PaperPosition',[0 0 9 4])
path = './results/';
saveas(figure1,fullfile(path,job),'epsc2');
