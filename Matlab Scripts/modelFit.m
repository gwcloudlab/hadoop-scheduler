function [fitresult, gof] = modelFit(CPU, TCT, job)



%% Fit: 'MIMP model fit'.
[xData, yData] = prepareCurveData( CPU, TCT );

% Set up fittype and options.
ft = fittype( 'exp2' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf -Inf];
opts.StartPoint = [0.500819303283227 0.318014040088208 0.00587940163720572 2.30080801996101];
opts.Upper = [Inf Inf Inf Inf];
opts.Normalize = 'off';

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,'FontSize',20);
xlim(axes1,[20 180]);
ylim(axes1,[0 7]);
box(axes1,'on');
grid(axes1,'on');
hold(axes1,'all');


plot1 = plot( fitresult, xData, yData );
%axis([20 180 0 7])
set(plot1(1),'MarkerSize',10, 'Marker','.', 'LineStyle','none');
set(plot1(2),'LineWidth',4,'LineStyle','-','Color',[1 0 0]);
set(legend,'visible','off')
%legend( plot1, ' Training Data ', 'MIMP model fit', 'Location', 'NorthWest' );
%title(job,'FontWeight','bold','FontSize',20);
% Label axes
xlabel( 'Web CPU Utilization','FontWeight','bold','FontSize',20 );
ylabel( 'Normalized TCT','FontWeight','bold','FontSize',20 );
grid on

%% Save figure in eps format
set(gcf,'Visible', 'off', 'PaperUnits','inches','PaperSize',[8.5,11],'PaperPosition',[0 0 9 4])
path = './results/';
saveas(figure1,fullfile(path,job),'epsc2');

