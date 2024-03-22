% Code to plot LIVOX-derived flow stage against gauging data
close all 
clear all
clc

% Edit the input variables below to match the locations of the data on your
% PC. Data variables described can be accessed/downloaded from:
% 10.25405/data.ncl.23501091. % This script will generate Figure 8.

% The specified folder should contain: i)
% "Goldrill_level_data.xlsx"; and ii) a folder containing 1016 .mat files.
% Both these sets of files can be downloaded from
% 10.25405/data.ncl.23501091. In the case of the 1016 .mat files these are
% stored within a .7z file in the repository so they will need to be
% unzipped following download, prior to analysis. Alternatively, these data
% may be reproduced by executing the "visualiseCloud.m" file

input_dir   = 'Y:\livox-data\Fig8\'; % modify this (as described above)

cd(input_dir)
ls          = dir('GaugingData_2022*.mat');
for i=1:length(ls)
    eval(['load ' ls(i).name])
    LivoxStage(i,1)     = DATA.fifthPrctile;
    point_nbr(i,1:length(find(DATA.point_nbr>0))) = DATA.point_nbr(DATA.point_nbr>0);
end
point_nbr       = point_nbr(:);
mean_point_nbr  = nanmean(point_nbr(point_nbr>0)); % mean number of points for the transect slices

for i=1:length(ls)
    LivoxDate(i,1)=datenum(str2num(ls(i).name(13:16)),str2num(ls(i).name(18:19)),str2num(ls(i).name(21:22)),str2num(ls(i).name(24:25)),...
        str2num(ls(i).name(27:28)),str2num(ls(i).name(30:31)));
end


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
tbl = readtable([input_dir 'Goldrill_level_data.xlsx'], opts, "UseExcel", false);

% Convert to output type
FlowGaugeTime   = tbl.DATETIMEGMT;
FlowGaugeStage  = tbl.LEVELM;

% Clear temporary variables
clear opts tbl
FlowGaugeStage = FlowGaugeStage + 0.13; %increase the pt hgt data rather than reducing the livox as originally planned
%LivoxStage  = LivoxStage-0.13;

%% Plot

f1 = figure('Position',[300 215 1153 611]); hold all
f1.Units='normalized';
subplot(2,1,1); hold on;
ax1 = gca;
ax1.Color = 'none';

time=datetime(datevec(LivoxDate));

FlowGaugeStage(FlowGaugeStage<0)=NaN;
plot(time,LivoxStage,'k.-')
plot(FlowGaugeTime,FlowGaugeStage,'b')

% add box
line([datetime(2022,02,18,0,0,0) datetime(2022,02,26,0,0,0), datetime(2022,02,26,0,0,0), datetime(2022,02,18,0,0,0), datetime(2022,02,18,0,0,0)],...
    [0.1 0.1 1.4 1.4 0.1],...
    'color',[0.5 0.5 0.5]);

xlabel('Date','FontWeight','bold')
ylabel('Flow Stage [m]','FontWeight','bold')
legLabs={'Fifth Percentile Livox';'Gauging station';''};
legend(legLabs)
box on 
grid off

xlim([datetime(datevec(datenum(2022,02,01))) datetime(datevec(datenum(2022,05,01)))])
ylim([0 1.5])
text('FontWeight','bold','FontSize',16,'String','A)',...
    'Position',[5.5 1.4 0]);

subplot(2,1,2);
hold on;
ax2 = gca;
ax2.Color = 'none';
for i=1:length(time)
    [val,idx]=min(abs(FlowGaugeTime-time(i)));
    sampleTime(i)=idx;
end

scatter(FlowGaugeStage(sampleTime),LivoxStage,'k*')

xlim([0 1.4])
ylim([0 1.4])
grid off
box on

c_fifth = polyfit(FlowGaugeStage(sampleTime),LivoxStage,1);

y_fifth = polyval(c_fifth,FlowGaugeStage(sampleTime));

[R_fifth,~] = corrcoef(FlowGaugeStage(sampleTime),LivoxStage);

hold on 
plot(FlowGaugeStage(sampleTime),y_fifth,'r-','LineWidth',2)

line([0 1.4],[0 1.4],'Color','blue')

legLabs={'Fifth Percentile Livox';'Linear Fit Fifth';'1:1 line'};

legend(legLabs,Location='southeast')

xlabel('Gauging Station Flow Stage [m]','FontWeight','bold')
ylabel('Livox-derived Flow Stage [m]','FontWeight','bold')
text('FontWeight','bold','FontSize',16,'String','B)',...
    'Position',[0.03 1.25 0]);

% extract the summary statistics for the article text
ref = FlowGaugeStage(sampleTime);
lvx = LivoxStage;
q5 = prctile([ref, lvx],5); %5th percentile
q50 = prctile([ref, lvx],50); %50th percentile
q90 = prctile([ref, lvx],90); %90th percentile
q95 = prctile([ref, lvx],95); %95th percentile

q50_rmse = rmse(lvx(lvx < q50(2)), ref(lvx < q50(2))); % rmse upto q50
q90_rmse = rmse(lvx(lvx < q90(2)), ref(lvx < q90(2))); % rmse upto q90

exportgraphics(f1,[pwd '\AllFlowData_v2.png'],'Resolution',600);

