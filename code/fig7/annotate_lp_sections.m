
% plot the transects on top of the long profile map
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

idx = [10, 14, 20, 24];
textIdx = {'T4', 'T3', 'T2', 'T1'};

for a = 1:length(idx)

    id = idx(a);
    xIn = [x1(id), x2(id); 0, 0]';
    yIn = [y1(id); y2(id)];

    [b,bint,r,rint,stats] = regress(yIn,xIn); % Run the regression
    Acoeff = b(2,1); % Pull out the a coefficient in log
    Bcoeff  = b(1,1); % Pull out the b coefficient in log

    % & plot of pre-diversion data
    if idx(a) == 10
        xvalues = [22.9:0.01:23.25];
    elseif idx(a) == 14
        xvalues = [19:0.01:19.2];
    elseif idx(a) == 20
        xvalues = [13.5:0.01:13.65];
    elseif idx(a) == 24
        xvalues = [9.8:0.01:10.5];
    end

    curvefit1 = Bcoeff.*xvalues+Acoeff; % Produce data
    plot(xvalues,curvefit1, 'color', 'k', 'linestyle','-','linewidth',2);
    if a~=1
        ts = text( [xvalues(end)], [curvefit1(end)], char(textIdx(a)), 'FontSize',16);
    else
        ts = text( [23.25], [26.57], char(textIdx(a)), 'FontSize',16);
    end



end















