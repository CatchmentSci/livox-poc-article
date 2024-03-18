
clear all; close all; clc

% Edit the input variables below to match the locations of the data on your
% PC. Data variables described can be accessed/downloaded from:
% 10.25405/data.ncl.23501091 and https://www.dropbox.com/sh/0x3zrgdzbtncjed/AACWkr69x_NbNSZW8kF75FBka?dl=0

% The 'level_dir' folder should contain: i)
% "Goldrill_level_data.xlsx"; and ii) a folder containing 1016 .mat files.
% Both these sets of files can be downloaded from
% 10.25405/data.ncl.23501091. In the case of the 1016 .mat files these are
% stored within a .7z file in the repository so they will need to be
% unzipped following download, prior to analysis. Alternatively, these data
% may be reproduced by executing the "visualiseCloud.m" file

% This script will generate Figure 9.

% specify the input directories
root_dir        = 'C:\_git_local\livox-poc-article\code\fig9\'; % Specify the path where the code from the GitHub repository is stored
code_dir        = [root_dir 'Code'];
lvx_data_dir    = 'Y:\livox\livox_processed\'; % directory containing the processed livox data. This can be downloaded from: https://www.dropbox.com/sh/0x3zrgdzbtncjed/AACWkr69x_NbNSZW8kF75FBka?dl=0 from within the "livox_processed" folder.
xs_data_in      = 'Y:\livox-data\Fig9\'; % directory containing the cross-section extractions i.e. folder containing ONLY four MAT files. These can be downloaded from "cross_section_outputs.7z" at 10.25405/data.ncl.23501091. The four MAT files are in a 7z archive so will need to be unzipped prior to running the script.
level_dir       = 'Y:\livox-data\Fig8\'; % directory containing the water level data - modify this (as described in preamble)
output_dir      = pwd; % directory where the Figure will be saved to

addpath(genpath(root_dir));
listing         = dir(lvx_data_dir);
for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(3:end);

%this section pulls out the times at 12 noon for each day of monitoring
s1 = {datenum('20220129_120000','yyyymmdd_HHMMSS')};
s2 =  datenum('20220431_120000','yyyymmdd_HHMMSS');
s3 = {datestr(cell2mat(s1),'yyyymmdd_HHMMSS')};

a = 2;
while datenum(s3{a-1},'yyyymmdd_HHMMSS') < s2
    s3{a,1} = datestr(addtodate(datenum(s3{a-1},'yyyymmdd_HHMMSS'),168,'h'),'yyyymmdd_HHMMSS'); % add 2hours
    a = a + 1;
end
s3_datenum = datenum(s3,'yyyymmdd_HHMMSS');
s3 = s3(s3_datenum<s2);
s3_datenum = s3_datenum(s3_datenum<s2);

% find the livox files that match with the chosen analysis times
for a = 1:length(listingName)
    t1 = char(listingName(a));
    listingName_timeStr{a,1} = [t1(1:4) t1(6:7) t1(9:10) '_' t1(12:13) t1(15:16) t1(18:19)];
    listingName_timeNum(a,1) = datenum(listingName_timeStr{a,1},'yyyymmdd_HHMMSS');
end

A = repmat(listingName_timeNum,[1 length(s3_datenum)]);
[minValue,closestIndex] = min(abs(A-s3_datenum'));
closestValue = listingName_timeNum(closestIndex);

h        = unique(closestIndex);
ii       = 1:length(h);
indexUse = h(ii(1:length(ii)));

% setup the colormap for display
nsamples    = length(indexUse);
c_map       = colormap(parula(nsamples));
indices     = cell(1,nsamples);
indices_b2  = cell(1,nsamples);


%% define the area of interest
ptCloud_area_temp2 = [...
    4, 17, 1.2; ...
    4, 17, 1.3; ...
    50, 17, 1.2; ...
    50, 17, 1.3; ...
    4, 31, 1.2; ...
    4, 31, 1.3; ...
    50, 31, 1.2; ...
    50, 31, 1.3; ...
    ];


shp2 = alphaShape(ptCloud_area_temp2(:,1),ptCloud_area_temp2(:,2),ptCloud_area_temp2(:,3),1000,...
    'HoleThreshold',10000);
h2 = plot(shp2,...
    'EdgeColor','none',...
    'LineStyle','--', ...
    'LineWidth',0.0000001,...
    'FaceColor','none');
Vertices2{1} = h2.Vertices;
Faces2{1} = h2.Faces;
close all;


%% Prep the figure

fig=figure(1); hold on;
fig.Units='pixels';
set(fig,'DefaultTextFontName','Arial');
set(fig,'Position',[2000, 42, 2480./2, 3508./2]); % A4 aspect ratio
fig.Units='normalized';

% setup the axes
ax0 = subplot(4,2, 1:2); hold on
ax1 = subplot(4,2, 3); hold on
ax2 = subplot(4,2, 4); hold on
ax3 = subplot(4,2, 5); hold on
ax4 = subplot(4,2, 6); hold on
ax5 = subplot(4,2, 7:8); hold on
axes(ax0); % activate ax0

ax0.Units='normalized';
ax0.Title.Visible = 'on';
ax0.XLabel.Visible = 'on';
ax0.YLabel.Visible = 'on';
pos_alpha = set(ax0, 'Position', [0.156612903225806 0.83291911154364 0.680376344086022 0.157741935483871]); % gives the position of current sub-plot
xlabel(ax0,'X coordinate [m]','FontWeight','bold');
ylabel(ax0,'Y coordinate [m]','FontWeight','bold');
ax0.ZAxis.Visible = 'off';
ax0.ZGrid = 'off';
ax0.Color = 'none';
set(ax0,'fontsize',12)

%%
for a  = ii

    t1 = char(listingName_timeStr(indexUse(a)));
    fileInput_mod = [t1(1:4) '-' t1(5:6) '-' t1(7:8) '_' t1(10:11) '-' t1(12:13) '-' t1(14:15)];
    ptCloud        = pcread([lvx_data_dir fileInput_mod '_MERGED.ply']);

    temp        = inpolyhedron(Faces2{1},Vertices2{1},ptCloud.Location);
    temp2       = find(temp>0);
    indices{a}  = [indices{a}; temp2];

    [data_temp] = ptCloud.Location(indices{a},1:3);
    [~, idx]    = sort(data_temp(:,1)); % increasing with x
    data_use    = data_temp(idx,1:3);

    % only use data where moving window variance is low
    M = movvar(data_use(:,2),5);
    ok = find(M<0.1);

    if a == 1
        cd = colormap(ax0, parula); % take your pick (doc colormap)
        cd = coolwarm(length(cd));
        interpIn = linspace(listingName_timeNum(indexUse(1)),listingName_timeNum(indexUse(end)),length(cd));
        cd = interp1(interpIn,cd,listingName_timeNum(indexUse)); % map color to velocity values
    end

    % plot using smoothed data with a moving windown of 5
    s(a) = plot(data_use(ok,1),smoothdata(data_use(ok,2),'gaussian',5),...
        'Color',cd(a,1:3) ...
        ); hold on;
end

c = colorbar(ax0, 'Position', [0.75238064516129 0.83291911154364 0.0153 0.157741935483871]);
clim(ax0,[min(listingName_timeNum(indexUse)),max(listingName_timeNum(indexUse))]);
temp = clim;
clim1 = temp(1);
clim2 = temp(2);
colormap(ax0,cd);
c.Label.String = 'Date [Month]'; % Set the label for the colorbar
set(c,'fontname','Arial')
set(c,'fontweight','normal')
set(c,'fontsize',12)
datetick(c,'y','keeplimits')

pbaspect([2 1 1])
axis equal
set(gca,'xlim',[4.7 23.93])
set(gca,'ylim',[25 30.5])

annotate_lp_sections

bank_retreat_subplots

water_level_subplots

exportgraphics(fig,[pwd '\long_bank_profile.png'],'Resolution',600)


