clear all; clc; close all;

%%
% 24 lots -- need to resave
% 5 some -- but complicated by trees -- not being used
% 9 -- some -- not on the long profile plot
% trying 10 so that it is on the plot -- works really well
% 14 and 20 none
% trying 16 to find the complicated movement bit

xs_number = 24;
inputLocation   = 'Y:\livox\livox_processed\';
outputLocation  = 'C:\_git_local\livox-poc-article\code\Fig9\Data\'; % location where the outputs are stored to
listing         = dir(inputLocation);

for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(3:end);

%this section pulls out the times at 12 noon for each day of monitoring
s1 = {datenum('20220218_000000','yyyymmdd_HHMMSS')};
s2 =  datenum('20220225_230000','yyyymmdd_HHMMSS');
s3 = {datestr(cell2mat(s1),'yyyymmdd_HHMMSS')};

a = 2;
while datenum(s3{a-1},'yyyymmdd_HHMMSS') < s2
    s3{a,1} = datestr(addtodate(datenum(s3{a-1},'yyyymmdd_HHMMSS'),2,'h'),'yyyymmdd_HHMMSS'); % add 2hours
    a = a + 1;
end
s3_datenum = datenum(s3,'yyyymmdd_HHMMSS');

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


%%
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

% setup the colormap for display
nsamples    = length(indexUse);
c_map       = colormap(parula(nsamples));
indices     = cell(1,nsamples);
indices_b2  = cell(1,nsamples);

ii = randperm(nsamples); % randomise the input
ii = 1:(nsamples); % linear input

for a  = ii

    t1 = char(listingName_timeStr(indexUse(a)));
    fileInput_mod = [t1(1:4) '-' t1(5:6) '-' t1(7:8) '_' t1(10:11) '-' t1(12:13) '-' t1(14:15)];
    ptCloud        = pcread(['Y:\livox\livox_processed\' fileInput_mod '_MERGED.ply']);

    for i=1:length(x1)

        if a == ii(1)
            % set up the search area
            ptCloud_area_temp{i}      = [x1(i), y1(i), 0; ...
                x1(i), y1(i), 8.00; ...
                x1(i)+0.1, y1(i), 0.00; ...
                x1(i)+0.1, y1(i), 8.00; ...
                x2(i), y2(i), 0.00; ...
                x2(i), y2(i), 8.00; ...
                x2(i)+0.1, y2(i), 0.00; ...
                x2(i)+0.1, y2(i), 8.00; ...
                ];

            ptCloud_area = ptCloud_area_temp{i};

            x = min(ptCloud_area(:,1)):0.10:max(ptCloud_area(:,1));
            y = min(ptCloud_area(:,2)):0.10:max(ptCloud_area(:,2));
            z = min(ptCloud_area(:,3)):0.10:max(ptCloud_area(:,3));
            [X,Y] = meshgrid(x,y);

            shp = alphaShape(ptCloud_area(:,1),ptCloud_area(:,2),ptCloud_area(:,3),1000,...
                'HoleThreshold',10000);
            h = plot(shp);
            Vertices{i} = h.Vertices;
            Faces{i} = h.Faces;
            close all

        end

        % extract for the particular scan
        if i==length(x1)
            for b = xs_number %1:length(Faces{i})  % specify the lines to plot
                temp        = inpolyhedron(Faces{b},Vertices{b},ptCloud.Location);
                temp2       = find(temp>0);
                indices{a}  = [indices{a}; temp2];
            end

            if a == ii(1)
                fig=figure(1); hold on;
                fig.Units='normalized';
                set(fig,'DefaultTextFontName','Arial')
                h = gca(); %(fig,'visible','off');
                h.Title.Visible = 'on';
                h.XLabel.Visible = 'on';
                h.YLabel.Visible = 'on';
                xlabel(h,'X [m]','FontWeight','bold');
                ylabel(h,'Y [m]','FontWeight','bold');
                zlabel(h,'Z [m]','FontWeight','bold');

            elseif a == ii(end)

                c = colorbar(h); 
                c.Limits = [listingName_timeNum(indexUse(1)),listingName_timeNum(indexUse(end))];
                set(c, 'YTick', linspace(listingName_timeNum(indexUse(1)), listingName_timeNum(indexUse(end)), 5));
                colormap(c_map);
                c.Label.String = 'Date [mm dd]'; % Set the label for the colorbar
                %caxis(h,[minColorLimit,maxColorLimit]);             % set colorbar limits
                set(c,'fontname','Arial')
                set(c,'fontweight','normal')
                set(c,'fontsize',16)
                datetick(c,'y',...
                    'keeplimits');
            end

            cData (1:length(ptCloud.Location(indices{a},1))) = listingName_timeNum(indexUse(a));
            s_data{a} = [ptCloud.Location(indices{a},1),ptCloud.Location(indices{a},2),ptCloud.Location(indices{a},3),cData'];
            s(a) = scatter3(ptCloud.Location(indices{a},1),ptCloud.Location(indices{a},2),ptCloud.Location(indices{a},3),...
                [12],...
                cData,...
                'Marker', '+',...
                'MarkerEdgeColor',c_map(a,1:3) ...
                ); hold on;
            clear cData

            intersection_analysis_run = 1;
            if intersection_analysis_run ==1
                intersection_analysis

                % text boxes to figure out whcih transects are of interest
                textIn = 1:30;
                zin(1:length(textIn)) = 2;
                %ts = text( [x2 ], [y2], zin, num2cell(textIn), 'FontSize',20);


                for z  = 1:length(output)

                    if a == ii(1)
                        try
                            temp_z = output{z}{xs_number};
                            [~, startingPos{z} ] = kmeans(temp_z(:,1:2),1);
                        catch
                            [startingPos{z}] = [NaN, NaN];

                        end


                    else
                        try
                            temp_z = output{z}{xs_number};
                            [~,C] = kmeans(temp_z(:,1:2),1);
                            location_abs{z}(a,1:2) = C;
                            changeDist_xy{z}(a,1:2) = C - startingPos{z};
                            changeDist_mag{z}(a,1) = sqrt(changeDist_xy{z}(a,1).^2 + changeDist_xy{z}(a,2).^2);
                            %scatter(z,changeDist_mag{z}(a,1),'k+'); hold on;
                        catch
                            location_abs{z}(a,1:2) = NaN;
                            changeDist_xy{z}(a,1:2) = NaN;
                            changeDist_mag{z}(a,1) = NaN;

                        end

                    end
                end
            end
        end

    end

end

save([outputLocation 'cross_section_output_b_' num2str(xs_number)]);
