function p = graphs( X, Y, xAxisLabel, yAxisLabel )
%GRAPHS Summary of this function goes here
%   Detailed explanation goes here
% The new defaults will not take effect if there are any open figures. To
% use them, we close all figures, and then repeat the first example.
%close all;

job='TPCWwithPiandWc';
figure1 = figure;
clf;

% Now we repeat the first example but do not need to include anything
% special beyond manually specifying the tick marks.


%get the dimensions of y axis
[yRows,yCols] = size(Y);

% Create axes
axes1 = axes('Parent',figure1,'FontSize',20);
box(axes1,'on');
xlim([50 1400]);
ylim([-150 8000]);
%xlim(axes1,[(min(X)-5) (max(X)+10)]);
%ylim(axes1,[(min(Y)-100) (max(Y)+100)]);
hold(axes1,'all');

%%
plot1 = plot(X,Y,'Parent',axes1);
set(gcf, 'Visible', 'off'); % Don't show graph now, it's not yet complete.

for r = 1:yCols
    if r==1
        set(plot1(1),'Marker','o','MarkerSize',10,'LineStyle','-','LineWidth',3,'Color',[0 0 0],'DisplayName','TPCW Alone');
    end
    if r==2
        set(plot1(2),'Marker','+','MarkerSize',10,'LineStyle','-','LineWidth',3,'Color',[0 0 1],'DisplayName','Default TPW w/WC');
    end
    if r==3
        set(plot1(3),'Marker','d','MarkerSize',10,'LineStyle','--','LineWidth',3,'Color',[1 0 0],'DisplayName','MI TPCW w/WC');
    end
    if r==4
        set(plot1(4),'Marker','*','MarkerSize',10,'LineStyle','-','LineWidth',3,'DisplayName','TPCWdefaultwithWC','Color',[1 0 1]);
    end
    if r==5
        set(plot1(5),'Marker','x','MarkerSize',10,'LineStyle','--','LineWidth',3,'DisplayName','TPCWbatchwithWC','Color',[0 1 0]);
    end
end
%%
% Create legend
legend1 = legend(axes1,'show');
set(legend1,'Location','NorthWest');

xlabel(xAxisLabel,'FontWeight','demi','FontSize',26);
ylabel(yAxisLabel,'FontWeight','demi','FontSize',26);
%title(figTitle,'FontWeight','demi','FontSize',20);

set(gcf, 'Visible', 'on');
set(gcf,'PaperUnits','inches','PaperSize',[8.5,11],'PaperPosition',[0 0 9 4])
path = './results/';
saveas(figure1,fullfile(path,job),'epsc2');

