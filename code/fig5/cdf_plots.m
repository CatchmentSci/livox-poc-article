%% load the data from a user-specified path
input_dir = 'C:\_git_local\livox-poc-article\code\Fig5\'; % directory containing them3c2_ecdf_data.mat data
outputdir = pwd; % specify the dir where the Figure will be saved to

%% produce the plots
load([input_dir 'm3c2_ecdf_data.mat'])
fig5=figure(1); hold on;
fig5.Units='normalized';
pbaspect([1 1 1]);
set(fig5,'Position',[0.1974    0.2875    0.2555    0.4049])
set(fig5,'DefaultTextFontName','Arial')
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

legend('Zone A Livox','Zone A Riegl', ...
    'Zone B Livox','Zone B Riegl', ...
    'Zone C Livox','Zone C Riegl', ...
    'Location','southeast', ...
    'FontSize',12);

exportgraphics(fig5,[pwd '\ecdf_plots.png'],'Resolution',600)
