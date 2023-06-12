axes(ax1); hold on


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

% plot the outline of the area of interest
ptCloud_area_temp2 = replace_num(ptCloud_area_temp2,-3.3,-2.5);
r1 = plot3(ptCloud_area_temp2([1,2,6,5,1],1)-3,ptCloud_area_temp2([1,2,6,5,1],2),ptCloud_area_temp2([1,2,6,5,1],3),...
    'Color','k',...
    'LineWidth',2);

temp_b1        = find(inpolyhedron(Faces2{1},Vertices2{1},location)>0);
temp_b2        = find(inpolyhedron(Faces2{1},Vertices2{1},location1)>0);
[f1a,x1a] = ecdf(M3C2(temp_b1));
[f1b,x1b] = ecdf(M3C21(temp_b2));


%% no erosion on bank area
ptCloud_area_temp2 = [...
    -25, 8.4, -3.3; ...
    -25, 8.4, -1.7; ...
    -35, 8.4, -3.3; ...
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
r2 = plot3(ptCloud_area_temp2([1,2,6,5,1],1)-5,ptCloud_area_temp2([1,2,6,5,1],2),ptCloud_area_temp2([1,2,6,5,1],3),...
    'Color','k',...
    'LineWidth',2);

temp_b1        = find(inpolyhedron(Faces2{1},Vertices2{1},location)>0);
temp_b2        = find(inpolyhedron(Faces2{1},Vertices2{1},location1)>0);
[f2a,x2a]      = ecdf(M3C2(temp_b1));
[f2b,x2b]      = ecdf(M3C21(temp_b2));

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
r3 = plot3(ptCloud_area_temp2([1,2,6,5,1],1)-6,ptCloud_area_temp2([1,2,6,5,1],2),ptCloud_area_temp2([1,2,6,5,1],3),...
    'Color','k',...
    'LineWidth',2);

temp_b1        = find(inpolyhedron(Faces2{1},Vertices2{1},location)>0);
temp_b2        = find(inpolyhedron(Faces2{1},Vertices2{1},location1)>0);
[f3a,x3a]      = ecdf(M3C2(temp_b1));
[f3b,x3b]      = ecdf(M3C21(temp_b2));


