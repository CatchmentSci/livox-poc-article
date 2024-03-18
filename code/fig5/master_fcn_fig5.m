
% Edit the input variables below to match the locations of the data on your
% PC. Data variables described can be accessed/downloaded from:
% 10.25405/data.ncl.23501091. % This script will generate Figure 5.

initial_icp_logs      = 'X:\Staff\MTP\_livox-poc-article-data\initial_icp_logs\'; % the directory containing the logs of the initial icp alignment i.e. folder containing txt files unzipped from "initial_icp_logs.7z"
registration_matrix   = 'X:\Staff\MTP\_livox-poc-article-data\registration_matrix\'; % the directory containing the registration matrices following the initial alignment i.e. folder containing txt files unzipped from "registration_matrix.7z"
accelerometer_data    = 'X:\Staff\MTP\_livox-poc-article-data\accelerometer_data\'; % the directory containing the accelerometer data i.e. folder containing csv files unzipped from "accelerometer_data.7z"
outputLocation        = 'C:\_git_local\livox-poc-article\code\Fig5\'; % the directory where the plot will be exported to

iter = 1;
for looper = 1:2

    internal = looper;

    extract_initial_rmse

    transformation_extraction

    acceleration_extraction

    %%
    fig_idx = [1 3 5 2 4 6];

    if internal == 1
        f0 = figure(); hold on
        f0.Units='pixels';
        set(f0,'Position',[1722, 42, 1717.9, 1314]);
        f0.Units='normalized';
    end


    ax0 = subplot(3,2,fig_idx(iter));hold on
    iter = iter + 1;
    set(ax0,'DefaultTextFontName','Arial')
    axes(ax0); hold on
    ax0.Color = 'none';

    yyaxis left
    h0 = plot(dateTime(1:end),RMSE, ...
        'color', [0 0 0]...
        ); hold on;

    NumTicks = 10;
    L = get(gca,'XLim');
    set(gca,'XTick',linspace(L(1),L(2),NumTicks))
    pbaspect([2 1 1])
    axis tight
    xLim = xlim;
    yLim = ylim;
    xticklabels({})
    set(ax0,'yLim', [0, yLim(2)])
    set(ax0,'fontname','Arial')
    set(ax0,'fontweight','normal')
    set(ax0,'fontsize',16)

    % internal or external alignment?
    if internal == 1
        ylabel('RMSE [m]', 'fontweight','bold');
        yticks([0 0.01 0.02 0.03])
    else
        yticks([0 0.02 0.04 0.06 0.08])
    end

    yyaxis right
    if internal == 1
        xticklabels({})
    end

    ax0.YAxis(1).Color = [0 0 0];
    set(ax0,'yLim',[0.0471 0.11])

    h1 = plot(uc_dn(1:end),noisy(1:end), ...
        'color', [1 0.5 0.5], ...
        'LineStyle','-',...
        'LineWidth',0.5); hold on;

    h1.Color = [h1.Color 0.5];
    set(ax0,'xLim', [xLim(1), xLim(2)])
    ax0.YAxis(2).Color = [1 0.5 .5];
    if internal == 2
        ax0.YAxis(2).Label.String = 'RMS total acceleration [m s^{-2}]';
        ax0.YAxis(2).Label.FontWeight = 'bold';
        set(ax0,'yticklabels',{'0.05', '0.06', '0.07', '0.08', '0.09' , '0.10',''})

    else
        set(ax0,'yticklabels','')
    end

    % move axes closer
    if internal == 2
        plotPos = get(ax0,'Position');
        plotPos(1) = 0.508;
        set(ax0,'Position',plotPos);
    end


    %%

    ax1 = subplot(3,2,fig_idx(iter));hold on
    axes(ax1); hold on
    iter = iter + 1;
    set(ax1,'DefaultTextFontName','Arial')
    ax1.Color = 'none';

    plot(dateTime(1:end),translation(:,1), ...
        'color', [[189,215,231]./255] ...
        ); hold on

    plot(dateTime(1:end),translation(:,2), ...
        'color', [[107,174,214]./255] ...
        ); hold on

    plot(dateTime(1:end),translation(:,3), ...
        'color', [[8,81,156]./255]); hold on

    NumTicks = 10;
    L = get(gca,'XLim');
    set(gca,'XTick',linspace(L(1),L(2),NumTicks))
    pbaspect([2 1 1])
    axis tight
    xLim = xlim;
    yLim = ylim;
    set(ax1,'yLim', [yLim(1), yLim(2)])
    set(ax1,'fontname','Arial')
    set(ax1,'fontweight','normal')
    xticklabels({})
    set(ax1,'fontsize',16)
    if internal == 1
        ylabel('Translation [m]', 'fontweight','bold');
        legend('\partial X', '\partial Y', '\partial Z',...
            'location', 'northwest')
    end
    % move the axes closer
    pos = get( ax1, 'Position' );
    pos(2) = 0.48 ;
    set( ax1, 'Position', pos );
    if internal == 2
        plotPos = get(ax1,'Position');
        plotPos(1) = 0.508;
        set(ax1,'Position',plotPos);
    end



    %%
    ax2 = subplot(3,2,fig_idx(iter));hold on
    axes(ax2); hold on
    iter = iter + 1;
    set(ax2,'DefaultTextFontName','Arial')
    ax2.Color = 'none';


    plot(dateTime(1:end),thetaX, ...
        'color', [[186,228,179]./255] ...
        ); hold on

    plot(dateTime(1:end),thetaY, ...
        'color', [[116,196,118]./255] ...
        ); hold on

    plot(dateTime(1:end),thetaZ, ...
        'color', [[0,109,44]./255] ...
        ); hold on

    NumTicks = 10;
    L = get(ax2,'XLim');
    set(ax2,'XTick',linspace(L(1),L(2),NumTicks))
    datetick('x', 'dd/mm/yyyy','keepticks')
    pbaspect([2 1 1])
    axis tight

    set(ax2,'yLim', [nanmin([thetaX;thetaY;thetaZ]), nanmax([thetaX;thetaY;thetaZ])])
    set(ax2,'fontname','Arial')
    set(ax2,'fontweight','normal')
    xlabel('Date', 'fontweight','bold');
    set(ax2,'fontsize',16);
    if internal == 1
        ylabel('Rotation [deg]', 'fontweight','bold');
        legend('\Theta X', '\Theta Y', '\Theta Z',...
            'location', 'northwest')
    end
    % move the axes closer
    pos = get( ax2, 'Position' );
    pos(2) = 0.25 ;
    set( ax2, 'Position', pos );

    if internal == 2
        plotPos = get(ax2,'Position');
        plotPos(1) = 0.508;
        set(ax2,'Position',plotPos);
    end

    if internal == 1

        % label the plots
        annotation(f0,'textbox',...
            [0.086088346325669 0.894337899543378 0.0251942237661938 0.0342465753424658],...
            'String','A)',...
            'FontWeight','bold',...
            'FontSize',16,...
            'FontName','Arial',...
            'FitBoxToText','off',...
            'EdgeColor','none');

        annotation(f0,'textbox',...
            [0.0820136892953722 0.667549467275493 0.0251942237661938 0.0342465753424658],...
            'String','B)',...
            'FontWeight','bold',...
            'FontSize',16,...
            'FontName','Arial',...
            'FitBoxToText','off',...
            'EdgeColor','none');

        annotation(f0,'textbox',...
            [0.0820136892953722 0.434824961948248 0.0251942237661938 0.0342465753424658],...
            'String','C)',...
            'FontWeight','bold',...
            'FontSize',16,...
            'FontName','Arial',...
            'FitBoxToText','off',...
            'EdgeColor','none');

    else
        annotation(f0,'textbox',...
            [0.844359277644803 0.894337899543378 0.0251942237661938 0.0342465753424658],...
            'String','D)',...
            'FontWeight','bold',...
            'FontSize',16,...
            'FontName','Arial',...
            'FitBoxToText','off',...
            'EdgeColor','none');

        annotation(f0,'textbox',...
            [0.844359277644803 0.667549467275493 0.0251942237661938 0.0342465753424658],...
            'String','E)',...
            'FontWeight','bold',...
            'FontSize',16,...
            'FontName','Arial',...
            'FitBoxToText','off',...
            'EdgeColor','none');

        annotation(f0,'textbox',...
            [0.844359277644803 0.434824961948248 0.0251942237661938 0.0342465753424658],...
            'String','F)',...
            'FontWeight','bold',...
            'FontSize',16,...
            'FontName','Arial',...
            'FitBoxToText','off',...
            'EdgeColor','none');


    end



end

exportgraphics(f0,[outputLocation '\transformation_plot.png'],'Resolution',600)
