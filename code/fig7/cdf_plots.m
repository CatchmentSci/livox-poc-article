
% Edit the input variables below to match the locations of the data on your
% PC. Data variables described can be accessed/downloaded from:
% 10.25405/data.ncl.23501091. % This script will generate Figure 7.

% load the data from a user-specified path
input_dir = 'Y:\livox-data\Fig7\'; % the directory containing m3c2 ecdf data i.e. folder containing a MAT file called "m3c2_ecdf_data.mat" from  10.25405/data.ncl.23501091
outputdir = pwd; % specify the dir where the Figure will be saved to

% produce the plots
load([input_dir 'm3c2_ecdf_data.mat'])
fig7=figure(1); hold on;
fig7.Units='pixels';
set(fig7,'Position',[680, 415, 878.92, 583.05])
fig7.Units='normalized';
pbaspect([1 1 1]);
set(fig7,'DefaultTextFontName','Arial')
ax0 = gca; hold on
ax0.Units='normalized';
ax0.Title.Visible = 'off';
set(ax0,'xlim',[-4 4])

xlabel(ax0,'M3C2 Change [m]','FontWeight','bold');
ylabel(ax0,'F(x)','FontWeight','bold');
ax0.Color = 'none';
set(ax0,'fontsize',16)

plot(x1a,f1a,'r','linewidth',1); hold on;
plot(x1b,f1b,'r--', 'linewidth',1);
plot(x2a,f2a,'b','linewidth',1); hold on;
plot(x2b,f2b,'b--','linewidth',1);
plot(x3a,f3a,'k','linewidth',1); hold on;
plot(x3b,f3b,'k--','linewidth',1);

legend('Zone 1 Livox','Zone 1 Riegl', ...
    'Zone 2 Livox','Zone 2 Riegl', ...
    'Zone 3 Livox','Zone 3 Riegl', ...
    'Location','southeast', ...
    'FontSize',12);

exportgraphics(fig7,[pwd '\ecdf_plots.png'],'Resolution',600)
