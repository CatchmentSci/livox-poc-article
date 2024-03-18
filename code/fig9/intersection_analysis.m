
lower_start = 0.8;
upper_finish = 2.00;
y = linspace(lower_start,upper_finish,20);

for yy = 1:length(y)-1
    % set up the search area for the intersection analysis
    upper1 = y(yy+1);
    lower1 = y(yy);

    for i=1:length(x1)
        ptCloud_area_temp2{i}      = [x1(i), y1(i), lower1; ...
            x1(i), y1(i), upper1; ...
            x1(i)+0.1, y1(i), lower1; ...
            x1(i)+0.1, y1(i), upper1; ...
            x2(i), y2(i), lower1; ...
            x2(i), y2(i), upper1; ...
            x2(i)+0.1, y2(i), lower1; ...
            x2(i)+0.1, y2(i), upper1; ...
            ];

        ptCloud_area2 = ptCloud_area_temp2{i};

        x2_2 = min(ptCloud_area2(:,1)):0.10:max(ptCloud_area2(:,1));
        y2_2 = min(ptCloud_area2(:,2)):0.10:max(ptCloud_area2(:,2));
        z2_2 = min(ptCloud_area2(:,3)):0.10:max(ptCloud_area2(:,3));
        [X2,Y2] = meshgrid(x2_2,y2_2);

        shp2 = alphaShape(ptCloud_area2(:,1),ptCloud_area2(:,2),ptCloud_area2(:,3),1000,...
            'HoleThreshold',10000);
        h2 = plot(shp2);
        Vertices2{i} = h2.Vertices;
        Faces2{i} = h2.Faces;
        close all
    end


    if xs_number == 24
        limiter1 = [9.9 Inf];
    elseif xs_number == 5
        limiter1 = [28.3 Inf];
    elseif xs_number == 9
        limiter1 = [23.93 Inf];
    elseif xs_number == 10
        limiter1 = [22.9 Inf];
    elseif xs_number == 14
        limiter1 = [19.0 Inf];
    elseif xs_number == 20
        limiter1 = [13.53 Inf];
    else
        limiter1 = [-Inf Inf];
    end

    %if i == length(x1)
    for b = xs_number %1:length(Faces{i})  % specify the lines to plot
        % for the intersection analysis
        temp_b2        = inpolyhedron(Faces2{b},Vertices2{b},ptCloud.Location);
        temp_b3        = ptCloud.Location(:,1) > limiter1(1) & ptCloud.Location(:,1) < limiter1(2);
        indices_b2{a}  = find((double(temp_b2)+double(temp_b3))==2);
        if ~isempty(  indices_b2{a} )

            %t(a) = scatter3(ptCloud.Location(indices_b2{a},1),ptCloud.Location(indices_b2{a},2),ptCloud.Location(indices_b2{a},3),...
            %    [12],...
            %    'Marker', '+'); hold on;
            temp_output{b} = [ptCloud.Location(indices_b2{a},1),ptCloud.Location(indices_b2{a},2),ptCloud.Location(indices_b2{a},3)];
        else
            temp_output{b} = [NaN, NaN, NaN];
        end
    end
    %end
    output{yy} = temp_output;
end

