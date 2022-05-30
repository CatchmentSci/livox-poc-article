function [scan01_idx, scan02_idx] = splittingLivox(justLimitsX,justLimitsY,justLimitsZ)

%partition the data based on xlimits ylimits and zlimits of the point clouds
for dimx = 1:3

    if dimx ==1
        duse = justLimitsX(:,1);
    elseif dimx ==2
        duse = justLimitsY(:,1);
    else
        duse = justLimitsZ(:,1);
    end

    [i, h]          = sort(duse(:,1));
    j               = diff(i);
    midd_range      = [length(j)./2 - round(length(j)./20), ...
        length(j)./2 + round(length(j)./20)];
    break_pt        = find(j == max(j(midd_range(1):midd_range(2))));

    if dimx ==1
        t1_1            = h(1:break_pt(1)-10); % increased from 1 to 10 to eliminate middle points
        t1_2            = h(break_pt(1)+10:length(h));
    elseif dimx ==2
        t2_1            = h(1:break_pt(1)-10);
        t2_2            = h(break_pt(1)+10:length(h));
    else
        t3_1            = h(1:break_pt(1)-10);
        t3_2            = h(break_pt(1)+10:length(h));
    end

end

[GC,GR] = groupcounts([t1_1; t2_2; t3_1]) ;
scan01_idx = GR(GC == 3);

[GC,GR] = groupcounts([t1_2; t2_1; t3_2]) ;
scan02_idx = GR(GC == 3);