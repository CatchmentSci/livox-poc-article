clear all; close all; clc;


% Edit the input variables below to match the locations of the data on your
% PC. Data variables described can be accessed/downloaded from:
% 10.25405/data.ncl.23501091. % This script will generate Figure 6.

ploter = 0;

%othercolor_dir  = 'C:\_git_local\livox-data\Fig4\othercolor'; % Specify the path of the othercolor directory (it accompanies the code downloaded from GitHub)
sfm_data_dir    = 'Y:\livox-data\Fig4\goldrill_20211110_SfM_cloud - final align - clipped.txt'; % Specify the path of the sfm pointcloud i.e. folder containing "goldrill_20211110_SfM_cloud - final align - clipped.txt" from 10.25405/data.ncl.23501091
lvx_data_dir    = 'Y:\livox-data\Fig4\M3C2 lvx output.txt'; % Specify the path of the livox m3c2 data i.e. folder containing "M3C2 lvx output.txt" from 10.25405/data.ncl.23501091
riegl_data_dir  = 'Y:\livox-data\Fig4\M3C2 riegl output.txt'; % Specify the path of the riegl m3c2 data i.e. folder containing "M3C2 riegl output.txt" from 10.25405/data.ncl.23501091
output_dir      = pwd; % define the location where the Figure will be saved to


%% first plot - sfm
ptCloud = readtable(sfm_data_dir);
location        = ptCloud{:,1:3};
colors          = (ptCloud{:,4:6}./255);

fig=figure(1); hold on;
fig.Units='pixels';
set(fig,'DefaultTextFontName','Arial');
set(fig,'Position',[100, 0, 2480./2, 3508./2]); % A4 aspect ratio
fig.Units='normalized';

ax0 = subplot(4,2,1:2);hold on
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

% modify the depth of water for visualisation purposes
bed1 = location(:,3) < -2.9;
location(bed1,3) = -2.85;


s = scatter3(location(:,1),location(:,2),location(:,3),...
    [2],...
    colors,...
    'filled');

if ploter == 1
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

end

axis equal
set(ax0,'xlim',[-60 2])
set(ax0,'ylim',[-10   45])
set(ax0,'zlim',[-2.9   2])
set(ax0,'view',[90 ,14])
axis tight
set(ax0,'position', [0.1300    0.72    0.8    0.2]);

x1 = [-15 -15];
y1 = [27, 37];
z1 = [-2 -2];
line([-5 -5],y1,z1,...
    'color','k',...
    'lineWidth', 2);
text(-1,mean(y1)-1.25,'10m','FontSize',14);

%annotation(fig,'textbox',...
%    [0.146643781039373 0.848510922631289 0.0251942237661938 0.0342465753424658],...
 %   'String','A)',...
 %   'FontWeight','bold',...
 %   'FontSize',16,...
 %   'FontName','Arial',...
 %   'FitBoxToText','off',...
 %   'EdgeColor','none');

annotation(fig,'rectangle',...
     [0.229032258064516 0.793044469783353 0.10241935483871 0.0102622576966931],...
     'LineWidth', 2);

 annotation(fig,'rectangle',...
     [0.396774193548387 0.799315849486887 0.0703548387096775 0.0102622576966931],...
     'LineWidth', 2);

annotation(fig,'rectangle',...
    [0.468548387096774 0.802736602052452 0.121774193548387 0.0131128848346637],...
     'LineWidth', 2);

annotation(fig,'textbox',...
    [0.252288942329695 0.800456100342075 0.060614283476756 0.0195876005963322],...
    'String','Zone 1',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.404708297168405 0.80672748004561 0.060614283476756 0.0195876005963322],...
    'String','Zone 2',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.501482490716792 0.811288483466363 0.060614283476756 0.0195876005963322],...
    'String','Zone 3',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');


%% second plot (livox)
ptCloud         = readtable(lvx_data_dir);
sig_change      = find(ptCloud{:,8} > 0);
location        = ptCloud{sig_change,1:3};
M3C2            = ptCloud{sig_change,10};
%uncertainty     = ptCloud{:,9};
%significance    = ptCloud{:,8};
clear uncertainty significance idx_use

%% third plot (riegl)
ptCloud          = readtable(riegl_data_dir);
sig_change       = find(ptCloud{:,8} > 0);
location1        = ptCloud{sig_change,1:3};
M3C21            = ptCloud{sig_change,10};
clear ptCloud cData

cdf_zones_show

exportgraphics(fig,[output_dir '\validation_M3C2.png'],'Resolution',600)
