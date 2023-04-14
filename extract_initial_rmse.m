clear all; close all; clc;

inputLocation   = 'Y:\livox\livox_pcd_exported\';
listing         = dir(inputLocation);

for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(3:end);
files_temp  = cellfun(@(v)v(1:19),listingName,'UniformOutput',false);
uc          = unique(files_temp) ;

files_temp2  = cellfun(@(uc)[uc '_initial_icp_logfile.txt'],files_temp,'UniformOutput',false);

RMSE(1:numel(files_temp2),:) = NaN;
dateTime(1:numel(files_temp2),:) = NaN;
for a = 1:length(files_temp2)
    tempTable   = readtable([inputLocation char(files_temp2(a))]);
    tempTable   = table2cell(tempTable);
    index       = cellfun(@(x) contains(x, 'RMS'), tempTable);
    if numel(tempTable(index)) > 0
        RMScells    = tempTable(index);
        RMSE(a)     = str2double(regexp(RMScells{1}, '(?<=RMS: )\d+(\.\d+)?', 'match'));
        dateTime(a) = datenum(files_temp2{a}(1:19),'yyyy-mm-dd_HH-MM-SS');
    end
end



f0 = figure();hold on
ax1 = gca(f0);
set(ax1,'DefaultTextFontName','Arial') 
f0.Units='normalized';
set(f0,'Position',[0.5003    0.0285    0.4994    0.9125])
scatter(dateTime,RMSE);
NumTicks = 6;
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1),L(2),NumTicks))
datetick('x', 'dd/mm/yyyy')
pbaspect([2 1 1])
axis tight
xLim = xlim;
yLim = ylim;
set(ax1,'yLim', [0, yLim(2)])
set(ax1,'fontname','Arial') 
set(ax1,'fontweight','normal')
xlabel('Date', 'fontweight','bold');
ylabel('RMSE [m]', 'fontweight','bold');
set(ax1,'fontsize',20)


