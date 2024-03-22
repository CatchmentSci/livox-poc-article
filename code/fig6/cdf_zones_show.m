
ax1 = subplot(4,2,3);hold on
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
set(ax1, 'Position', [0.1752    0.604    0.3347    0.1577]);

annotation(fig,'textbox',...
     [0.17083732942647 0.67793614595211 0.0251942237661938 0.0342465753424659],...
    'String','1A)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');


%% erosional area
ptCloud_area_temp2 = [...
    -25, -3, -3.3; ...
    -25, -3, -1.7; ...
    -30, -3, -3.3; ...
    -30, -3, -1.7; ...
    -25, 4.1, -3.3; ...
    -25, 4.1, -1.7; ...
    -30, 4.1, -3.3; ...
    -30, 4.1, -1.7; ...
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

temp_b1        = find(inpolyhedron(Faces2{1},Vertices2{1},location)>0);
temp_b2        = find(inpolyhedron(Faces2{1},Vertices2{1},location1)>0);

% find the maximum range
min_lim = nanmin([M3C2(temp_b1,1)]);
max_lim = nanmax([M3C2(temp_b1,1)]);

% set up the color scheme
cd = colormap(ax1, parula); % take your pick (doc colormap)
cd = flip(coolwarm(length(cd)));
interpIn = linspace(min_lim,max_lim,length(cd));
cd1 = interp1(interpIn,cd,M3C2(temp_b1)); % map color to chnage values

% plot params
s1 = scatter3(location(temp_b1,1),location(temp_b1,2),location(temp_b1,3),2,cd1,'filled');  % livox
pause(5)

% configure axes
view([90, 0]);
axis equal
set(ax1, 'xlim', [-32.8265  -22.1735])
set(ax1, 'ylim', [-3.0000    4.1000])
set(ax1, 'zlim', [-3.6360   -1.3640])


[f1a,x1a] = ecdf(M3C2(temp_b1));
[f1b,x1b] = ecdf(M3C21(temp_b2));


ax2 = subplot(4,2,4);hold on
ax2.Units='normalized';
ax2.Title.Visible = 'off';
ax2.XLabel.Visible = 'off';
ax2.YLabel.Visible = 'off';
ax2.ZAxis.Visible = 'off';
ax2.ZGrid = 'off';
ax2.Color = 'none';
set(ax2,'fontsize',14)
xticks([]);
yticks([]);
ax2.XAxis.Visible = 'off';
ax2.YAxis.Visible = 'off';
set(ax2, 'Position', [ 0.5252    0.604    0.3347    0.1577]);

% set up the color scheme
cd1 = interp1(interpIn,cd,M3C21(temp_b2)); % map color to chnage values

% plot params
s2 = scatter3(location1(temp_b2,1),location1(temp_b2,2),location1(temp_b2,3),2,cd1,'filled');
pause(5)

% configure axes so that they match those on the left
view([90, 0]);
axis equal
set(ax2, 'xlim', [-32.8265  -22.1735])
set(ax2, 'ylim', [-3.0000    4.1000])
set(ax2, 'zlim', [-3.6360   -1.3640])


% colorbar setup
c = colorbar(ax2, 'Position', [0.882480645161291 0.652793614595211 0.0172043010752689 0.0556675138610979]);
clim(ax2,[min_lim, max_lim]);
colormap(ax2,cd);
set(c,'fontname','Arial')
set(c,'fontweight','normal')
set(c,'fontsize',12)

text('String','Change [m]',...
    'Position',[1.4088859752257 40.6765794981623 -3.85195859112983],...
    'FontSize', 14);

annotation(fig,'textbox',...
     [0.52083732942647 0.67793614595211 0.0251942237661938 0.0342465753424659],...
    'String','1B)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');



%% no erosion on bank area
ptCloud_area_temp2 = [...
    -25, 8.4, -3.3; ...
    -25, 8.4, -1.7; ...
    -35, 8.4, -3.3; ...ax1
    -35, 8.4, -1.7; ...
    -25, 13.5, -3.3; ...
    -25, 13.5, -1.7; ...
    -35, 13.5, -3.3; ...
    -35, 13.5, -1.7; ...
    ];


shp2 = alphaShape(ptCloud_area_temp2(:,1),ptCloud_area_temp2(:,2),ptCloud_area_temp2(:,3),1000,...
    'HoleThreshold',10000);
h2 = plot(shp2,...
    'EdgeColor','none',...
    'LineStyle','--', ...
    'LineWidth',0.0000001,...
    'FaceColor','none');Vertices2{1} = h2.Vertices;
Faces2{1} = h2.Faces;

% plot the outline of the area of interest
ptCloud_area_temp2 = replace_num(ptCloud_area_temp2,-3.3,-2.5);
temp_b1        = find(inpolyhedron(Faces2{1},Vertices2{1},location)>0);
temp_b2        = find(inpolyhedron(Faces2{1},Vertices2{1},location1)>0);

% find the maximum range
min_lim = nanmin([M3C2(temp_b1,1)]); % clipped to lvx -  M3C21(temp_b1,1)]);
max_lim = nanmax([M3C2(temp_b1,1)]); % cliiped to lvx -  M3C21(temp_b1,1)]);

% set up the color scheme
interpIn = linspace(min_lim,max_lim,length(cd));


[f2a,x2a]      = ecdf(M3C2(temp_b1));
[f2b,x2b]      = ecdf(M3C21(temp_b2));

ax3 = subplot(4,2,5);hold on
ax3.Units='normalized';
ax3.Title.Visible = 'off';
ax3.XLabel.Visible = 'off';
ax3.YLabel.Visible = 'off';
ax3.ZAxis.Visible = 'off';
ax3.ZGrid = 'off';
ax3.Color = 'none';
set(ax3,'fontsize',14)
xticks([]);
yticks([]);
ax3.XAxis.Visible = 'off';
ax3.YAxis.Visible = 'off';
set(ax3, 'Position', [0.1752    0.526388939566707    0.3347    0.1577]);


% set up the color scheme
cd1 = interp1(interpIn,cd,M3C2(temp_b1)); % map color to chnage values

% plot params
s3 = scatter3(location(temp_b1,1),location(temp_b1,2),location(temp_b1,3),2,cd1,'filled');  % livox
pause(5)

% configure axes 
view([90, 0]);
axis equal
set(ax3, 'xlim', [ -36.8768  -27.8777])
set(ax3, 'ylim', [7.9500   13.9500])
set(ax3, 'zlim', [ -3.3000   -1.7000])


annotation(fig,'textbox',...
     [0.17083732942647 0.604960091220069 0.0251942237661938 0.0342465753424659],...
    'String','2A)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

% 4th sub
ax4 = subplot(4,2,6);hold on
ax4.Units='normalized';
ax4.Title.Visible = 'off';
ax4.XLabel.Visible = 'off';
ax4.YLabel.Visible = 'off';
ax4.ZAxis.Visible = 'off';
ax4.ZGrid = 'off';
ax4.Color = 'none';
set(ax4,'fontsize',14)
xticks([]);
yticks([]);
ax4.XAxis.Visible = 'off';
ax4.YAxis.Visible = 'off';
set(ax4, 'Position', [0.5252    0.526388939566707    0.3347    0.1577]);


% set up the color scheme
cd1 = interp1(interpIn,cd,M3C21(temp_b2)); % map color to chnage values

% plot params
s4 = scatter3(location1(temp_b2,1),location1(temp_b2,2),location1(temp_b2,3),2,cd1,'filled');  % livox
pause(5)

% configure axes so that they match those on the left
view([90, 0]);
axis equal
set(ax4, 'xlim', [ -36.8768  -27.8777])
set(ax4, 'ylim', [7.9500   13.9500])
set(ax4, 'zlim', [ -3.3000   -1.7000])


% colorbar setup
c = colorbar(ax4); %, 'Position', [0.75238064516129 0.83291911154364 0.0153 0.157741935483871]);
clim(ax4,[min_lim, max_lim]);
colormap(ax4,cd);
set(c,'fontname','Arial')
set(c,'fontweight','normal')
set(c,'fontsize',12)
c = colorbar(ax4, 'Position', [0.8825 0.572405929304447 0.0172 0.0642610034207527]);


annotation(fig,'textbox',...
     [0.52083732942647 0.604960091220069 0.0251942237661938 0.0342465753424659],...
    'String','2B)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');


annotation(fig,'textbox',...
    [0.850676039103889 0.708095781071836 0.2 0.0176168757126574],...
    'String','Change [m]',...
    'FontWeight','bold',...
    'FontSize',12,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');



%% bit of erosion to right
ptCloud_area_temp2 = [...
    -25, 13.5, -3.3; ...
    -25, 13.5, -1.7; ...
    -35, 13.5, -3.3; ...
    -35, 13.5, -1.7; ...
    -25, 22, -3.3; ...
    -25, 22, -1.7; ...
    -35, 22, -3.3; ...
    -35, 22, -1.7; ...
    ];

shp2 = alphaShape(ptCloud_area_temp2(:,1),ptCloud_area_temp2(:,2),ptCloud_area_temp2(:,3),1000,...
    'HoleThreshold',10000);
h2 = plot(shp2,...
    'EdgeColor','none',...
    'LineStyle','--', ...
    'LineWidth',0.0000001,...
    'FaceColor','none');Vertices2{1} = h2.Vertices;
Faces2{1} = h2.Faces;

% plot the outline of the area of interest
ptCloud_area_temp2 = replace_num(ptCloud_area_temp2,-3.3,-2.5);
%r3 = plot3(ptCloud_area_temp2([1,2,6,5,1],1)-6,ptCloud_area_temp2([1,2,6,5,1],2),ptCloud_area_temp2([1,2,6,5,1],3),...
%    'Color','k',...
%    'LineWidth',2);

temp_b1        = find(inpolyhedron(Faces2{1},Vertices2{1},location)>0);
temp_b2        = find(inpolyhedron(Faces2{1},Vertices2{1},location1)>0);

% find the maximum range
min_lim = nanmin([M3C2(temp_b1,1)]); % clipped to lvx -  M3C21(temp_b1,1)]);
max_lim = nanmax([M3C2(temp_b1,1)]); % cliiped to lvx -  M3C21(temp_b1,1)]);

[f3a,x3a]      = ecdf(M3C2(temp_b1));
[f3b,x3b]      = ecdf(M3C21(temp_b2));

annotation(fig,'textbox',...
     [0.17083732942647 0.52035347776511 0.0251942237661938 0.0342465753424659],...
    'String','3A)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');


ax5 = subplot(4,2,7);hold on
ax5.Units='normalized';
ax5.Title.Visible = 'off';
ax5.XLabel.Visible = 'off';
ax5.YLabel.Visible = 'off';
ax5.ZAxis.Visible = 'off';
ax5.ZGrid = 'off';
ax5.Color = 'none';
set(ax5,'fontsize',14)
xticks([]);
yticks([]);
ax5.XAxis.Visible = 'off';
ax5.YAxis.Visible = 'off';
set(ax5, 'Position', [0.1752    0.45434458380844    0.3347    0.1577]);

% set up the color scheme
cd1 = interp1(interpIn,cd,M3C2(temp_b1)); % map color to chnage values

% plot params
s5 = scatter3(location(temp_b1,1),location(temp_b1,2),location(temp_b1,3),2,cd1,'filled');  % livox
pause(5)

% configure axes 
view([90, 0]);
axis equal
set(ax5, 'xlim', [   -39.3599  -20.1153])
set(ax5, 'ylim', [  12.7500   22.7500])
set(ax5, 'zlim', [    -3.2119   -1.7000])

% 6th sub
ax6 = subplot(4,2,8);hold on
ax6.Units='normalized';
ax6.Title.Visible = 'off';
ax6.XLabel.Visible = 'off';
ax6.YLabel.Visible = 'off';
ax6.ZAxis.Visible = 'off';
ax6.ZGrid = 'off';
ax6.Color = 'none';
set(ax6,'fontsize',14)
xticks([]);
yticks([]);
ax6.XAxis.Visible = 'off';
ax6.YAxis.Visible = 'off';
set(ax6, 'Position', [0.5252    0.45434458380844    0.3347    0.1577]);


% set up the color scheme
cd1 = interp1(interpIn,cd,M3C21(temp_b2)); % map color to chnage values

% plot params
s6 = scatter3(location1(temp_b2,1),location1(temp_b2,2),location1(temp_b2,3),2,cd1,'filled');  % livox
pause(5)

% configure axes so that they match those on the left
view([90, 0]);
axis equal
set(ax6, 'xlim', [   -39.3599  -20.1153])
set(ax6, 'ylim', [  12.7500   22.7500])
set(ax6, 'zlim', [    -3.2119   -1.7000])

% colorbar setup
c = colorbar(ax6); %, 'Position', [0.75238064516129 0.83291911154364 0.0153 0.157741935483871]);
clim(ax6,[min_lim, max_lim]);
colormap(ax6,cd);
c.Label.String = 'Change [m]'; % Set the label for the colorbar
set(c,'fontname','Arial')
set(c,'fontweight','normal')
set(c,'fontsize',12)
c = colorbar(ax6, 'Position', [0.8825 0.514253135689852 0.0172043010752689 0.0371291850834837]);
set(c,'YTick',[-2:2:2])

annotation(fig,'textbox',...
     [0.52083732942647 0.52035347776511 0.0251942237661938 0.0342465753424659],...
    'String','3B)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');


