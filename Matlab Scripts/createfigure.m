function createfigure(X, YMATRIX, job, xAxisLabel, yAxisLabel)
%CREATEFIGURE(X1, YMATRIX1)
%  X:  CPU utilization values
%  YMATRIX:  TCT of predicted and observed data


% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,'FontSize',30);
box(axes1,'on');
hold(axes1,'all');
xlim(axes1,[(min(X)-5) (max(X)+10)]);
grid on;

% Create multiple lines using matrix input to plot
plot1 = plot(X,YMATRIX,'Parent',axes1);
set(plot1(1),'MarkerSize',24, 'Marker','.', 'LineStyle','none','DisplayName','Observed data');
set(plot1(2),'MarkerSize',8,'Marker','+','LineWidth',3,'LineStyle','--','Color',[1 0 0],'DisplayName','Predicted data');

% Create xlabel
xlabel(xAxisLabel,'FontWeight','bold','FontSize',30);

% Create ylabel
ylabel(yAxisLabel,'FontWeight','bold','FontSize',30);

% Create title
%title('Predicted Vs. Observed','FontWeight','bold','FontSize',20);

% Create legend
legend1 = legend(axes1,'show');
set(legend1,'Location','NorthWest');
set(gcf, 'Visible', 'off');
set(gcf,'PaperUnits','inches','PaperSize',[8.5,11],'PaperPosition',[0 0 9 4])
path = './results/';
saveas(figure1,fullfile(path,job),'epsc2');

