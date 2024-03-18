
dataIn = {'cross_section_output_b_24.mat', 'cross_section_output_b_20.mat', ...
    'cross_section_output_b_14.mat', 'cross_section_output_b_10.mat'};

for a = 1:4

    % modify subplots
    if a == 1
        axes(ax1);
    elseif a == 2
        axes(ax2);
    elseif a == 3
        axes(ax3);
    elseif a == 4
        axes(ax4);
    end

   xs_data_in =  'Y:\livox-data\Fig9\'; % for testing only [remove]
   load_filename = [xs_data_in dataIn{a}];
   tmp = load(load_filename);

   iter = 1;
   for A = 1:length(tmp.location_abs{end})
       for Z  = 1:length(tmp.output)

           cData = tmp.listingName_timeNum(tmp.indexUse(A));

           h_2(iter,1:4) = [tmp.listingName_timeNum(tmp.indexUse(A)),...
               double(tmp.location_abs{Z}(A,1)),...
               double(tmp.location_abs{Z}(A,2)),...
               tmp.y(Z)];
           iter = iter + 1;
       end
   end


   if a == 1
       cd = colormap(ax1, parula); % take your pick (doc colormap)
   elseif a == 2
       cd = colormap(ax2, parula); % take your pick (doc colormap)
   elseif a == 3
       cd = colormap(ax3, parula); % take your pick (doc colormap)
   elseif a == 4
       cd = colormap(ax4, parula); % take your pick (doc colormap)
   end

   %cd = othercolor('BuOr_12',length(cd));
   cd = coolwarm(length(cd));
   %cd = flip(cd,1);
   interpIn = linspace(min(h_2(:,1),[],'omitnan'),max(h_2(:,1)),length(cd));
   cd = interp1(interpIn,cd,h_2(:,1)); % map color to velocity values

   % find the minimum x and y values and define as starting point
   startXS = [1000,1000];
   [i j] = unique(h_2(:,1));
   for b = 1:length(j)-1

       x_in = h_2(j(b):(j(b+1)-1),2);
       y_in = h_2(j(b):(j(b+1)-1),3);
       z_in = h_2(j(b):(j(b+1)-1),4);

        if min(x_in) > 0 && min(x_in) < min(startXS(1))
            startXS(1) = min(x_in);
        end

        if min(y_in) > 0 &&  min(y_in) < min(startXS(2))
            startXS(2) = min(y_in);
        end
   end

   % plots the 2D change data
   for b = 1:length(j)-1

       x_in = h_2(j(b):(j(b+1)-1),2);
       y_in = h_2(j(b):(j(b+1)-1),3);
       z_in = h_2(j(b):(j(b+1)-1),4);
       out = cell2mat(cellfun(@(x) x-startXS ,{[x_in, y_in]},'un',0)); % calculate x and y distance relative to start
       out2 = [sqrt(out(:,1).^2 + out(:,2).^2),z_in] ; % calculate the magnitude i.e. absolute distance

       line(out2(:,1),...
           out2(:,2),...
           'color', cd(j(b),:)); hold on;
       c_map2(b,1:3) = cd(j(b),:);
   end

   % colorbar only needed for one plot
   if a == 1
       c = colorbar(ax1, 'Position', [0.75238064516129 0.264753989348959 0.0153 0.495200000000001]);
       clim(ax1,[min(h_2(:,1)),max(h_2(:,1))]);
       colormap(ax1,c_map2);
       c.Label.String = 'Date [mm/dd]'; % Set the label for the colorbar
       set(c,'fontname','Arial')
       set(c,'fontweight','normal')
       set(c,'fontsize',12)
       %set(c, 'YTick', linspace(min(h_2(:,1)), max(h_2(:,1)), 5));
       datetick(c,'y','keepticks','keeplimits')
   end


   if a == 1
       pbaspect([1 1 1])
       set(ax1,'xlim',[  -0.2 2.5 ])
       set(ax1,'ylim',[  0.7 2.00])
       %view(43,11);
       %grid minor 
       pos_in = [0.216227570880193 0.54149 0.26776 0.22856];
       set(ax1, 'Position',[ pos_in(1)    pos_in(2)  pos_in(3)    pos_in(4)]);
       ax1.XLabel.Visible = 'on';
       ax1.YLabel.Visible = 'on';
       xlabel(ax1,'Distance [m]','FontWeight','bold');
       ylabel(ax1,'Height [m]','FontWeight','bold');
       ax1.Color = 'none';
       set(ax1,'fontsize',12)


       % annotate the plots
       out = cell2mat(cellfun(@(x) x-startXS ,{[9.99,28.48]},'un',0)); % calculate x and y distance relative to start
       out3 = [sqrt(out(:,1).^2 + out(:,2).^2),0.92] ; % calculate the magnitude i.e. absolute distance
       scatter(out3(1),out3(2),...
           100,...
           '*',...
           'MarkerEdgeColor', [0 0 0] );

       out = cell2mat(cellfun(@(x) x-startXS ,{[10.09,28.86]},'un',0)); % calculate x and y distance relative to start
       out4 = [sqrt(out(:,1).^2 + out(:,2).^2),0.92] ; % calculate the magnitude i.e. absolute distance
       scatter(out4(1),out4(2), ...
           100,...
           'square',...
           'MarkerEdgeColor', [0 0 0] );

       out = cell2mat(cellfun(@(x) x-startXS ,{[10.24,29.45]},'un',0)); % calculate x and y distance relative to start
       out5 = [sqrt(out(:,1).^2 + out(:,2).^2),0.92] ; % calculate the magnitude i.e. absolute distance
       scatter(out5(1), out5(2),...
           100,...
           'diamond',...
           'MarkerEdgeColor', [0 0 0] );


   elseif a == 2
       pbaspect([1 1 1])
       set(ax2,'xlim',[  -0.2 2.5 ])
       set(ax2,'ylim',[  0.7 2.00])
       pos_in = [  0.5010    0.54149   0.26776 0.22856];
       set(ax2, 'Position',[ pos_in(1)    pos_in(2)  pos_in(3)    pos_in(4)]);
       ax2.XLabel.Visible = 'on';
       ax2.YLabel.Visible = 'on';       
       xlabel(ax2,'Distance [m]','FontWeight','bold');
       ylabel(ax2,'Height [m]','FontWeight','bold');
       ax2.Color = 'none';
       set(ax2,'fontsize',12)


   elseif a == 3
       pbaspect([1 1 1])
       set(ax3,'xlim',[  -0.2 2.5 ])
       set(ax3,'ylim',[  0.7 2.00])
       pos1 = get(ax1, 'Position'); % gives the position of current sub-plot
       new_pos1 = pos1 +[0 -0.29 0 0];
       set(ax3, 'Position',new_pos1);
       ax3.XLabel.Visible = 'on';
       ax3.YLabel.Visible = 'on';
       xlabel(ax3,'Distance [m]','FontWeight','bold');
       ylabel(ax3,'Height [m]','FontWeight','bold');
       ax3.Color = 'none';
       set(ax3,'fontsize',12)


     
   elseif a == 4
       pbaspect([1 1 1])
       set(ax4,'xlim',[  -0.1 0.75 ])
       set(ax4,'ylim',[  0.7 2.00])
       pos1 = get(ax2, 'Position'); % gives the position of current sub-plot
       new_pos1 = pos1 +[0 -0.29 0 0];
       set(ax4, 'Position',new_pos1);
       ax4.XLabel.Visible = 'on';
       ax4.YLabel.Visible = 'on';
       xlabel(ax4,'Distance [m]','FontWeight','bold');
       ylabel(ax4,'Height [m]','FontWeight','bold');
       ax4.Color = 'none';
       set(ax4,'fontsize',12)


       out = cell2mat(cellfun(@(x) x-startXS ,{[23.15, 26.37]},'un',0)); % calculate x and y distance relative to start
       out6 = [sqrt(out(:,1).^2 + out(:,2).^2),0.92] ; % calculate the magnitude i.e. absolute distance
       scatter(out6(1), out6(2),...
           100,...
           '*',...
           'MarkerEdgeColor', [0 0 0] );

       out = cell2mat(cellfun(@(x) x-startXS ,{[23.24, 26.42]},'un',0)); % calculate x and y distance relative to start
       out7 = [sqrt(out(:,1).^2 + out(:,2).^2),0.92] ; % calculate the magnitude i.e. absolute distance
       scatter(out7(1), out7(2),...
           100,...
           'x',...
           'MarkerEdgeColor', [0 0 0] );

       out = cell2mat(cellfun(@(x) x-startXS ,{[23.29, 26.48]},'un',0)); % calculate x and y distance relative to start
       out8 = [sqrt(out(:,1).^2 + out(:,2).^2),0.92] ; % calculate the magnitude i.e. absolute distance
       scatter(out8(1), out8(2),...
           100,...
           '+',...
           'MarkerEdgeColor', [0 0 0] );

   end

end


% label the plots
annotation(fig,'textbox',...
    [0.722104859464767 0.954783476584671 0.0251942237661938 0.0342465753424658],...
    'String','A)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.199000610020361 0.749142494484081 0.0251942237661937 0.0342465753424657],...
    'String','B)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.720027392761288 0.749142494484081 0.0251942237661936 0.0342465753424657],...
    'String','C)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.199000610020361 0.458735385198445 0.0251942237661936 0.0342465753424657],...
    'String','D)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.720027392761288 0.458735385198445 0.0251942237661936 0.0342465753424658],...
    'String','E)',...
    'FontWeight','bold',...
    'FontSize',14,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

%exportgraphics(fig,[output_dir '\lp_and_bank_sub.png'],'Resolution',600);
