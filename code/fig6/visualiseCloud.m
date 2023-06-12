% Initial code to visualise .ply file and extract water surface elevation
% at the far (left) bank
% code authored by Dr Seb Pitman

clear all; close all; clc

data_in = 'Y:\livox\livox_processed\'; % directory containing the processed lvx data downloaded from: ...
data_out = 'C:\_git_local\livox-poc-article\code\Fig6\Data\'; % location where .mat outputs will be saved to

addpath(data_in)
lst = dir( fullfile( data_in,  ['*MERGED.ply'] )  );

plotFlag=0; % 0 to avoid plots, 1 to plot

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
    subplot(2,1,1)
    hold on
else
end


for i=1:length(x1)
    if plotFlag==1
        line([x1(i) x2(i)],[y1(i) y2(i)]);
    else
    end
    if i > 10
        lines(i).x=linspace(x1(i),x2(i),200);
        lines(i).y=linspace(y1(i),y2(i),200);
        if plotFlag==1
            scatter3(lines(i).x,lines(i).y,20,'r.')
        end
    else
    end

    if ismember(i,[6,9,12])
        lines(i).x=linspace(x1(i),x2(i),200);
        lines(i).y=linspace(y1(i),y2(i),200);
        if plotFlag==1
            scatter3(lines(i).x,lines(i).y,20,'w.')
        end
    else
    end

end


channel=[5 25;12 23; 17 22;35 17];
if plotFlag==1
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

        pcshow(ptCloud.Location)
        %colorbar
        view(0,90);
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

        if plotFlag==1;
            scatter(lines(i).x(lines(i).locMin),lines(i).y(lines(i).locMin),'yo','filled')
        else
        end
        queryPts(i,1:2)=[lines(i).x(lines(i).locMin),lines(i).y(lines(i).locMin)];
    end

    distances = pdist2(ptCloud.Location(:,1:2),queryPts); % Find all points to be counted in water calculation

    closePoints = distances < 0.5;
    closePoints=double(closePoints);
    cpall=sum(closePoints,2);
    [M,I]=find(cpall>0);
    if plotFlag==1
        hold on
        scatter(ptCloud.Location(M,1),ptCloud.Location(M,2),'g*')
        ylim([0 35])
        xlim([0 25])
    else
    end

    lowestElevation=ptCloud.Location(M,3);

    P5=prctile(ptCloud.Location(M,3),5);
    P10=prctile(ptCloud.Location(M,3),10);
   
    if plotFlag==1
        %backgroundColor = [10./255, 102./255,151./255]; % same as cloudcompare
        %set(gca,'Color',backgroundColor);
        %set(gcf,'Color',backgroundColor);
        %axis off
        f=gcf;
        exportgraphics(f,[lst(K).name(1:16) '_v2.png'],'Resolution',300)
    else
    end

    DATA(1).name=path;
    DATA(1).elevations=ptCloud.Location(M,3);
    DATA(1).tenthPrctile=P10;
    DATA(1).fifthPrctile=P5;

    eval(['save ' data_out 'GaugingData_' lst(K).name(1:19) '.mat DATA K'])
  
end




