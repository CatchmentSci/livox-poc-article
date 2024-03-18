% Code to plot LIVOX-derived flow stage against gauging data for the time
% period shown for Figure 9.

%% Load station gauging
opts = spreadsheetImportOptions("NumVariables", 2);

% Specify sheet and range
opts.Sheet      = "Sheet1";
opts.DataRange  = "A4:B62364";

% Specify column names and types
opts.VariableNames = ["DATETIMEGMT", "LEVELM"];
opts.VariableTypes = ["datetime", "double"];

% Specify variable properties
opts = setvaropts(opts, "DATETIMEGMT", "InputFormat", "");

% Import the data
level_dir = 'Y:\livox-data\Fig8\';  % for testing only [remove]
tbl = readtable([level_dir 'Goldrill_level_data.xlsx'], opts, "UseExcel", false);

% Convert to output type
FlowGaugeTime   = tbl.DATETIMEGMT;
FlowGaugeStage  = tbl.LEVELM;

%% Plot

axes(ax5); % activate ax5
ax5.Units='normalized';
ax5.Title.Visible = 'on';
ax5.XLabel.Visible = 'on';
ax5.YLabel.Visible = 'on';
xlabel(ax5,'Date','FontWeight','bold');
ylabel(ax5,'Flow Stage [m]','FontWeight','bold');
ax5.Color = 'none';
set(ax5,'fontsize',12)
set(ax5,'ylim',[0.3998 1.201])
pos_beta = set(ax5, 'Position', [0.245161290322581 0.0665806566104704 0.562903225806451 0.121429]); 

FlowGaugeStage(FlowGaugeStage<0)=NaN;

FlowGaugeStage = FlowGaugeStage + 0.13; %increase the pt hgt data rather than reducing the livox as originally planned

plot(FlowGaugeTime,FlowGaugeStage,...
    'Color',[0.0196078431372549	0.439215686274510	0.690196078431373]); %[0.5 0.5 0.5]

box on 
grid off

xlim([datetime(datevec(datenum(2022,02,18))) datetime(datevec(datenum(2022,02,26)))])
text('FontWeight','bold','FontSize',14,'String','F)',...
    'Position',[5.5 1.4 0]);

% Annotate the plots
annotation(fig,'textbox',...
    [0.77567255405161 0.149373766366421 0.0251942237661935 0.034246575342466],...
    'String','F)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

scatter(datetime(datevec(datenum(2022,02,20,23,00,00))),...
    FlowGaugeStage(12143)+0.06,...
    100,...
    '*',...
    'MarkerEdgeColor', [0 0 0] );


scatter(datetime(datevec(datenum(2022,02,22,17,00,00))),...
    FlowGaugeStage(12647)+0.04,...
    100,...
    'square',...
    'MarkerEdgeColor', [0 0 0] );

scatter(datetime(datevec(datenum(2022,02,22,17,00,00))),...
    FlowGaugeStage(12617)+0.08,...
    100,...
    'diamond',...
    'MarkerEdgeColor', [0 0 0] );


scatter(datetime(datevec(datenum(2022,02,23,09,00,00))),...
    FlowGaugeStage(12839)+0.04,...
    100,...
    'x',...
    'MarkerEdgeColor', [0 0 0] );

scatter(datetime(datevec(datenum(2022,02,23,09,00,00))),...
    FlowGaugeStage(12863)+0.10,...
    100,...
    '+',...
    'MarkerEdgeColor', [0 0 0] );




