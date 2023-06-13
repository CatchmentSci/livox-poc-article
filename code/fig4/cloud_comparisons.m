clear all; close all; clc;


% Edit the input variables below to match the locations of the data on your
% PC. Data variables described can be accessed/downloaded from:
% 10.25405/data.ncl.23501091. % This script will generate Figure 4.


othercolor_dir  = 'C:\_git_local\livox-data\Fig4\othercolor'; % Specify the path of the othercolor directory (it accompanies the code downloaded from GitHub)
sfm_data_dir    = 'C:\_git_local\livox-data\Fig4\goldrill_20211110_SfM_cloud - final align - clipped.txt'; % Specify the path of the sfm pointcloud i.e. folder containing "goldrill_20211110_SfM_cloud - final align - clipped.txt" from 10.25405/data.ncl.23501091
lvx_data_dir    = 'C:\_git_local\livox-data\Fig4\M3C2 lvx output.txt'; % Specify the path of the livox m3c2 data i.e. folder containing "M3C2 lvx output.txt" from 10.25405/data.ncl.23501091
riegl_data_dir  = 'C:\_git_local\livox-data\Fig4\M3C2 riegl output.txt'; % Specify the path of the riegl m3c2 data i.e. folder containing "M3C2 riegl output.txt" from 10.25405/data.ncl.23501091
output_dir      = pwd; % define the location where the Figure will be saved to


%% first plot - sfm
addpath(genpath(othercolor_dir));
ptCloud = readtable(sfm_data_dir);

location        = ptCloud{:,1:3};
colors          = (ptCloud{:,4:6}./255);

fig=figure(1); hold on;
fig.Units='pixels';
set(fig,'Position',[1715.84, 261.00, 958.00, 1094.98]);
fig.Units='normalized';
set(fig,'DefaultTextFontName','Arial')

ax0 = subplot(3,1,1);hold on
ax0.Units='normalized';
ax0.Title.Visible = 'off';
ax0.XLabel.Visible = 'off';
ax0.YLabel.Visible = 'off';
xticks([]);
yticks([]);
ax0.XAxis.Visible = 'off';
ax0.YAxis.Visible = 'off';
ax0.ZAxis.Visible = 'off';
ax0.ZGrid = 'off';
ax0.Color = 'none';
set(ax0,'fontsize',16)

s = scatter3(location(:,1),location(:,2),location(:,3),...
    [2],...
    colors,...
    'filled');

% input modified 20220428
angles = linspace(0.025, 0.5*pi, 25);
radius = 5;
CenterX = 5;
CenterY = 5;
x1 = radius * cos(angles) + CenterX;
y1 = radius * sin(angles) + CenterY;

angles = linspace(0.25*pi, 0.55*pi, 25);
radius = 30;
CenterX = 15;
CenterY = 5;
x2 = radius * cos(angles) + CenterX;
y2 = radius * sin(angles) + CenterY;

% transform sfm data so that it corresponds with lvx and riegl
T   = [-0.3909684644300371 -0.9181939008415587 -0.0637465315023548 1.7058831233230304; ...
0.9202140134528127 -0.3913565213386322 -0.0068001949083332 3.8005302166329286; ...
-0.0187037233267998 -0.0613191133586141 0.9979429528137507 -1.5254539223420512; ...
0.0000000000000000 0.0000000000000000 0.0000000000000000 1.0000000000000000]';
tform1 = affine3d(T);
z = zeros(length(x1),1);
[xT, yT, zT] = transformPointsForward(tform1,[x1',x2'],[y1',y2'], [z,z]);
annot_val = 4;

for a = 1:length(x1)
if ~ismember(a,[9 14 20 24])
    plot([xT(a,1), xT(a,2)], [yT(a,1), yT(a,2)] ,'k-',...
        'lineWidth', 1);
else
    plot([xT(a,1), xT(a,2)], [yT(a,1), yT(a,2)] ,'b-',...
        'lineWidth', 1)
    
    ha = annotation('textbox',...
        'String',['T' num2str(annot_val)],...
        'FontWeight','bold',...
        'FontSize',14,...
        'FontName','Arial',...
        'FitBoxToText','off',...
        'EdgeColor','none');

    ha.Parent = fig.CurrentAxes;  % associate annotation with current axes
    ha.Position = [xT(a,2)-6, yT(a,2)-0.8,0.0251942237661938, 0.0342465753424658];
    annot_val = annot_val - 1;
end
end

axis equal
set(ax0,'xlim',[-60 0])
set(ax0,'ylim',[-4.8280   40.6270])
set(ax0,'zlim',[-2.67   0])
set(ax0,'view',[90,14])

x1 = [-15 -15];
y1 = [27, 37];
z1 = [-2 -2];
line([-5 -5],y1,z1,...
    'color','k',...
    'lineWidth', 2);
text(-1,mean(y1)-1.25,'10m','FontSize',14);

annotation(fig,'textbox',...
    [0.192611522974857 0.870745814307458 0.0251942237661938 0.0342465753424658],...
    'String','A)',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');


%% second plot (livox)
ptCloud = readtable(lvx_data_dir);

location        = ptCloud{:,1:3};
M3C2            = ptCloud{:,10};
uncertainty     = ptCloud{:,9};
significance    = ptCloud{:,8};

ax1 = subplot(3,1,2);hold on
ax1.Units='normalized';
ax1.Title.Visible = 'off';
ax1.XLabel.Visible = 'off';
ax1.YLabel.Visible = 'off';
ax1.ZAxis.Visible = 'off';
ax1.ZGrid = 'off';
ax1.Color = 'none';
set(ax1,'fontsize',14)
xticks([]);
yticks([]);
ax1.XAxis.Visible = 'off';
ax1.YAxis.Visible = 'off';
set(ax1, 'Position', [0.1300    0.48    0.7750    0.2157]);

annotation(fig,'textbox',...
    [0.192611522974857 0.65 0.0251942237661938 0.0342465753424658],...
    'String','B)',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');


cmap = colormap('parula');
cmap = othercolor('BuOr_12',length(cmap));
cmap = flip(cmap,1);
cData = M3C2;
idx_use = find(~isnan(cData));
t = scatter3(location(idx_use,1),location(idx_use,2),location(idx_use,3),...
    [1],...
    cData(idx_use),...
    'filled');

colormap(cmap);
c = colorbar(ax1,'Position',[0.87 0.27 0.022 0.4]);  % attach colorbar to h
c.Label.String = 'Distance Change [m]'; % Set the label for the colorbar    
clim(ax1,[prctile( M3C2 , 1 ),prctile( M3C2 , 99 )])             % set colorbar limits
set(c,'fontname','Arial')
set(c,'fontweight','normal')
set(c,'fontsize',12)

axis equal
xLims = get(ax1,'XLim');
set(ax1,'xlim',[-60 0])
set(ax1,'ylim',[-4.8280   40.6270])
set(ax1,'zlim',[-2.67   0])
view(90,14);

clear uncertainty significance idx_use

%% third plot (riegl)
ptCloud     = readtable(riegl_data_dir);

k = length(ptCloud{:,1}); % if need to subsample for memory reasons define k as the number of points to show e.g. k = round(length(ptCloud{:,1}./10)); to display 10% of the points
rand_idx = randperm(length(ptCloud{:,1}),k); % and randomise that data that is plotted in case of subsampling

location1        = ptCloud{rand_idx,1:3};
M3C21            = ptCloud{rand_idx,10};

clear ptCloud cData
ax2 = subplot(3,1,3);hold on
ax2.Units='normalized';
ax2.Title.Visible = 'off';
ax2.XLabel.Visible = 'off';
ax2.YLabel.Visible = 'off';
ax2.ZAxis.Visible = 'off';
ax2.ZGrid = 'off';
ax2.Color = 'none';
set(ax2,'fontsize',16)
xticks([]);
yticks([]);
ax2.XAxis.Visible = 'off';
ax2.YAxis.Visible = 'off';
set(ax2, 'Position', [0.1300    0.25    0.7750    0.2157]);

annotation(fig,'textbox',...
    [0.192611522974857 0.428 0.0251942237661938 0.0342465753424658],...
    'String','C)',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

cData1 = M3C21;
idx_use1 = find(~isnan(cData1));
t1 = scatter3(location1(idx_use1,1),location1(idx_use1,2),location1(idx_use1,3),...
    [1],...
    cData1(idx_use1),...
    'filled');

colormap(ax2,cmap);
clim(ax2,get(ax1,'clim'))             % set colorbar limits

axis equal
set(ax2,'xlim',[-60 0])
set(ax2,'ylim',[-4.8280   40.6270])
set(ax2,'zlim',[-2.67   0])
view(90,14);

cdf_zones_show

annotation(fig,'rectangle',...
    [0.188935281837161 0.715955581531268 0.656576200417536 0.192687025131502]);

annotation(fig,'rectangle',...
    [0.188935281837161 0.490393045002922 0.656576200417536 0.192687025131502]);

annotation(fig,'rectangle',...
    [0.188935281837161 0.257349035651666 0.656576200417536 0.20]);

exportgraphics(fig,[output_dir '\validation_M3C2.png'],'Resolution',600)
