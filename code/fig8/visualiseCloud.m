% Initial code to visualise .ply file and extract water surface elevation
% at the far (left) bank code producedby Dr Seb Pitman.
% Edit the input variables below to match the locations of the data on your
% PC. Data variables described can be accessed/downloaded from:
% 10.25405/data.ncl.23501091. % This script will generate Figure 8.

clear all; close all; clc

data_in = 'Y:\livox\livox_processed\'; % directory containing the processed lvx data downloaded from: https://www.dropbox.com/sh/0x3zrgdzbtncjed/AACWkr69x_NbNSZW8kF75FBka?dl=0 This folder should consist of 3048 files.
data_out = 'C:\_git_local\livox-data\Fig8\'; % location where .mat outputs should be saved to

addpath(data_in)
lst = dir( fullfile( data_in,  ['*MERGED.ply'] )  );

plotFlag = 0; % 0 to avoid plots, 1 to plot point cloud with ws locations; 3 for elevation and density

% Construct some profile lines
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


% Visualise cloud
if plotFlag==1
    figure('Position',[1 41 1920 963])
    %subplot(2,1,1)
    hold on
else
end

for i=1:length(x1)
    if plotFlag==1 && i > 10 % only plot those that are used in the calcs
        l1 = line([x1(i) x2(i)],[y1(i) y2(i)]);
        l1.Color = [216,179,101]./255;
        l1.LineWidth = 2;

    else
    end
    if i > 10
        lines(i).x=linspace(x1(i),x2(i),200);
        lines(i).y=linspace(y1(i),y2(i),200);
        if plotFlag==2
            scatter3(lines(i).x,lines(i).y,20,'r.')
        end
    else
    end

    if ismember(i,[6,9,12])
        lines(i).x=linspace(x1(i),x2(i),200);
        lines(i).y=linspace(y1(i),y2(i),200);
        if plotFlag==2
            scatter3(lines(i).x,lines(i).y,20,'w.')
        end
    else
    end

end


channel=[5 25;12 23; 17 22;35 17];
if plotFlag == -1
    plot3(channel(:,1),channel(:,2),repmat(20,length(channel)))
else
end


for K=1:length(lst)


    % For one test file, initially:
    path=[lst(K).folder '\' lst(K).name];
    disp(['Processing ' num2str(K) ' of ' num2str(length(lst))])

    % Load the file
    ptCloud        = pcread(path);

    % Crop to 50 x 50 m square
    indices = findPointsInROI(ptCloud,[0 50;0 50; -10 10]);
    xyz=ptCloud.Location(indices,:);
    ptCloud=pointCloud(xyz);

    if plotFlag==1

        cd = summer(256);
        interpIn = linspace(min(ptCloud.Location(:,3),[],'omitnan'),3.00,length(cd));
        cd = interp1(interpIn,cd,ptCloud.Location(:,3)); % map color to hgt values
        pcshow(ptCloud.Location, cd)
        set(gca,'color','w');
        set(gcf,'color','w');
        set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
        %colorbar
        %view(0,90);
        view(40,20)
    end

    %% Find measurement locations

    for i=11:length(lines)

        [lines(i).xi,lines(i).yi] = polyxpoly(lines(i).x,lines(i).y,channel(:,1),channel(:,2)) ; % Find initial search point
        D=pdist2([lines(i).x' lines(i).y'],[lines(i).xi lines(i).yi]);
        [~,lines(i).loc]=min(D);

        D=pdist2(ptCloud.Location(:,1:2),[lines(i).x' lines(i).y']); % Find distance of all points in the point cloud relative to the profile line points
        closePoints = D < 0.05; % Only count those points within 0.05 m
        closePoints=double(closePoints);
        closePoints=sum(closePoints,1);

        lines(i).binCount=closePoints; % Create a density profile along the line

        clear lp1 Dist R
        if plotFlag == 3 && i == 17

            for lp1 = 1:length(ptCloud.Location)
                [R(lp1,1), Dist(lp1,1)] = isPointOnLine([x1(17), y1(17)],[x2(17), y2(17)] ,ptCloud.Location(lp1,1:2));
            end
            
            
            R = R == 1 & ptCloud.Location(:,1) >  x1(17) & ptCloud.Location(:,1) <  x2(17);
            startXS = [x1(17), y1(17)];
            x_in = ptCloud.Location(R,1);
            y_in = ptCloud.Location(R,2);
            z_in = ptCloud.Location(R,3);
            out = cell2mat(cellfun(@(x) x-startXS ,{[x_in, y_in]},'un',0)); % calculate x and y distance relative to start
            out2 = [sqrt(out(:,1).^2 + out(:,2).^2),z_in] ; % calculate the magnitude i.e. absolute distance
            
            % prep the figure
            fig=figure(1); hold on;
            fig.Units='pixels';
            set(fig,'DefaultTextFontName','Arial');
            set(fig,'Position',[2000, 42, 2480./2, 3508./2]); % A4 aspect ratio
            fig.Units='normalized';

            % setup the axes
            ax0 = subplot(2,1,1); hold on
            axes(ax0); % activate ax0
            ax0.Units='normalized';
            ax0.Title.Visible = 'on';
            ax0.XLabel.Visible = 'on';
            ax0.YLabel.Visible = 'on';
            pos_alpha = get(ax0, 'Position'); % gives the position of current sub-plot
            ylim([-0.2 2.5]);
            ylabel(ax0,'Elevation [m]','FontWeight','bold');
            ax0.ZAxis.Visible = 'off';
            ax0.ZGrid = 'on';
            ax0.Color = 'none';
            grid on;
            set(ax0,'fontsize',16)

            % subplot1
            [out2sorted,I] = sort(out2(:,1));
            out2sorted(:,2) = out2(I,2);
            out2sorted(diff(out2sorted(:,1))>0.05,1) = NaN;
            p0 = plot(out2sorted(:,1),smooth(out2sorted(:,2),5));
            p0.Color = [0 0 0 ];
            p0.LineWidth = [2];

            xticklabels({})
            pbaspect([4 1 1]);
     


            % subplot2 prep (plotted later)
            x_in = lines(17).x';
            y_in = lines(17).y';
            out = cell2mat(cellfun(@(x) x-startXS ,{[x_in, y_in]},'un',0)); % calculate x and y distance relative to start
            out3 = [sqrt(out(:,1).^2 + out(:,2).^2)] ; % calculate the magnitude i.e. absolute distance

        end

        idx_bank=lines(i).binCount(lines(i).loc:end)>50;
        idx = find(idx_bank);
        lines(i).idx_bank=idx(1)+lines(i).loc;

        TF1 = islocalmin(fliplr(lines(i).binCount(1:lines(i).idx_bank)),'FlatSelection','first'); % Look for where the signal bottoms out at zero, working back from the initial search location
        TF2=fliplr(lines(i).binCount(1:lines(i).idx_bank));
        for j=1:length(TF1)
            if TF1(j)==1 & TF2(j)==0 % If the signal has bottomed out, and the count has dropped to zero, record this location
                TF3(j)=1;
            else
                TF3(j)=0;
            end
        end

        [d dd]=find(TF3);
        lines(i).locMin=lines(i).idx_bank-dd(1)-1; % If the signal has bottomed out, and the count has dropped to zero, record this location

        if plotFlag==1
            scat1 = scatter(lines(i).x(lines(i).locMin),lines(i).y(lines(i).locMin),'yo','filled');
            scat1.SizeData = 70;
        else
        end
        queryPts(i,1:2) = [lines(i).x(lines(i).locMin),lines(i).y(lines(i).locMin)];
        DATA(1).point_nbr(i)           = sum(lines(1,i).binCount); % collate the number of points present

    end

    distances = pdist2(ptCloud.Location(:,1:2),queryPts); % Find all points to be counted in water calculation

    closePoints = distances < 0.5;
    closePoints=double(closePoints);
    cpall=sum(closePoints,2);
    [M,I]=find(cpall>0);
    if plotFlag==1
        hold on
        scat2 = scatter(ptCloud.Location(M,1),ptCloud.Location(M,2),'r*');
        ylim([0 35])
        xlim([0 25])
    else
    end

    lowestElevation=ptCloud.Location(M,3);

    P5=prctile(ptCloud.Location(M,3),5);
    P10=prctile(ptCloud.Location(M,3),10);

if plotFlag==3

    x_in = ptCloud.Location(M,1);
    y_in = ptCloud.Location(M,2);
    out = cell2mat(cellfun(@(x) x-startXS ,{[x_in, y_in]},'un',0)); % calculate x and y distance relative to start
    out4 = [sqrt(out(:,1).^2 + out(:,2).^2)] ; % calculate the magnitude i.e. absolute distance
    
    ax1 = subplot(2,1,2); hold on
    axes(ax1); % activate ax0
    ax1.Units='normalized';
    ax1.Title.Visible = 'on';
    ax1.XLabel.Visible = 'on';
    ax1.YLabel.Visible = 'on';
    pos_alpha = get(ax1, 'Position'); % gives the position of current sub-plot
    %ylim([-0.2 2.5]);
    %xticklabels({})
    xlabel(ax1,'Distance [m]','FontWeight','bold');
    grid on

    ylabel(ax1,'Density [points m]','FontWeight','bold');
    ax1.YAxis(1).Label.String = 'Density [points m^{-2}]';
    ax1.ZAxis.Visible = 'off';
    ax1.ZGrid = 'off';
    ax1.Color = 'none';
    set(ax1,'fontsize',16)
    pbaspect([4 1 1])
    set(ax1,'Position',[0.13 0.345137533274184 0.775 0.341162790697677]); % move closer to top plot


    p1 = plot(out3,lines(17).binCount'.*356.1254); % point density
    p1.Color = [0 0 0 ];
    p1.LineWidth = [2];
        
    s1 = scatter(median(out4),P5);
    s1.MarkerEdgeColor = ['r'];
    s1.MarkerFaceColor = ['r'];
    s1.SizeData = 70;;


    axes(ax0); % activate ax0
    s2 = scatter(median(out4),P5);
    s2.MarkerEdgeColor = ['r'];
    s2.MarkerFaceColor = ['r'];
    s2.SizeData = 70;

    set(ax0,'xlim', [0 30]) % reset axis range

    annotation(fig,'textbox',...
        [0.879708297168405 0.827462289263534 0.0251942237661938 0.0342465753424657],...
        'String','B)',...
        'FontWeight','bold',...
        'FontSize',16,...
        'FontName','Arial',...
        'FitBoxToText','off',...
        'EdgeColor','none');

    annotation(fig,'textbox',...
        [0.879708297168405 0.586246672582078 0.0251942237661938 0.0342465753424657],...
        'String','C)',...
        'FontWeight','bold',...
        'FontSize',16,...
        'FontName','Arial',...
        'FitBoxToText','off',...
        'EdgeColor','none');

    %exportgraphics(fig,[output_dir '\lp_and_bank_sub.png'],'Resolution',600);
    exportgraphics(fig,'height_density.png','Resolution',600);



end
   
    if plotFlag==1
        %backgroundColor = [10./255, 102./255,151./255]; % same as cloudcompare
        %set(gca,'Color',backgroundColor);
        %set(gcf,'Color',backgroundColor);
        %axis off
        f=gcf;
        exportgraphics(f,[lst(K).name(1:16) '_v2.png'],'Resolution',300)
    else
    end

    DATA(1).lines           = path;
    DATA(1).elevations      = ptCloud.Location(M,3);
    DATA(1).tenthPrctile    = P10;
    DATA(1).fifthPrctile    = P5;

    eval(['save ' data_out 'GaugingData_' lst(K).name(1:19) '.mat DATA K'])
  
end




