
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

   cd = othercolor('PuBu4',length(cd)); %Greys4
   cd = flip(cd,1);
   interpIn = linspace(min(h_2(:,1),[],'omitnan'),max(h_2(:,1)),length(cd));
   cd = interp1(interpIn,cd,h_2(:,1)); % map color to velocity values


   [i j] = unique(h_2(:,1));
   for b = 1:length(j)-1

       line(h_2(j(b):(j(b+1)-1),2),...
           h_2(j(b):(j(b+1)-1),3),...
           h_2(j(b):(j(b+1)-1),4), ...,
           'color', cd(j(b),:)); hold on;
       c_map2(b,1:3) = cd(j(b),:);
   end


   % colorbar only needed for one plot
   if a == 1
       c = colorbar(ax1, 'Position', [0.794539493904313 0.0996651445966501 0.0122239710908905 0.541856925418569]);
       clim(ax1,[min(h_2(:,1)),max(h_2(:,1))]);
       colormap(ax1,c_map2);
       c.Label.String = 'Date [mm/dd]'; % Set the label for the colorbar
       set(c,'fontname','Arial')
       set(c,'fontweight','normal')
       set(c,'fontsize',16)
       %set(c, 'YTick', linspace(min(h_2(:,1)), max(h_2(:,1)), 5));
       datetick(c,'y','keepticks','keeplimits')
   end


   if a == 1
       pbaspect([1 1 1])
       set(ax1,'xlim',[  9.8311   10.5515])
       set(ax1,'ylim',[  28.0449   30.7649])
       set(ax1,'zlim',[  0.8 2.00])
       view(43,11);
       grid minor 
       set(ax1, 'Position',[ 0.1684    0.3815    0.3347    0.2857]);
       ax1.XLabel.Visible = 'on';
       ax1.YLabel.Visible = 'on';
       xlabel(ax1,'X [m]','FontWeight','bold');
       ylabel(ax1,'Y [m]','FontWeight','bold');
       zlabel(ax1,'Z [m]','FontWeight','bold');
       ax1.Color = 'none';
       set(ax1,'fontsize',12)

   elseif a == 2
       pbaspect([1 1 1])
       set(ax2,'xlim',[  13.4647   14.3446])
       set(ax2,'ylim',[  27.7812   29.9609])
       set(ax2,'zlim',[ 0.8 2.00])
       view(43,11);
       grid minor 
       set(ax2, 'Position',[ 0.4970    0.3815    0.3347    0.2857]);
       ax2.XLabel.Visible = 'on';
       ax2.YLabel.Visible = 'on';
       xlabel(ax2,'X [m]','FontWeight','bold');
       ylabel(ax2,'Y [m]','FontWeight','bold');
       zlabel(ax2,'Z [m]','FontWeight','bold');
       ax2.Color = 'none';
       set(ax2,'fontsize',12)


   elseif a == 3
       pbaspect([1 1 1])
       set(ax3,'xlim',[  18.8372   20.7678])
       set(ax3,'ylim',[  26.5955   29.6775])
       set(ax3,'zlim',[ 0.8 2.00])
       view(43,11);
       grid minor    
       pos1 = get(ax1, 'Position'); % gives the position of current sub-plot
       new_pos1 = pos1 +[0 -0.32 0 0];
       set(ax3, 'Position',new_pos1);
       ax3.XLabel.Visible = 'on';
       ax3.YLabel.Visible = 'on';
       xlabel(ax3,'X [m]','FontWeight','bold');
       ylabel(ax3,'Y [m]','FontWeight','bold');
       zlabel(ax3,'Z [m]','FontWeight','bold');
       ax3.Color = 'none';
       set(ax3,'fontsize',12)
      
   elseif a == 4
       pbaspect([1 1 1])
       set(ax4,'xlim',[ 22.7073   23.5522])
       set(ax4,'ylim',[  25.8569   26.7017])
       set(ax4,'zlim',[ 0.8 2.00])
       view(43,11);
       grid minor
       pos1 = get(ax2, 'Position'); % gives the position of current sub-plot
       new_pos1 = pos1 +[0 -0.32 0 0];
       set(ax4, 'Position',new_pos1);
       ax4.XLabel.Visible = 'on';
       ax4.YLabel.Visible = 'on';
       xlabel(ax4,'X [m]','FontWeight','bold');
       ylabel(ax4,'Y [m]','FontWeight','bold');
       zlabel(ax4,'Z [m]','FontWeight','bold');
       ax4.Color = 'none';
       set(ax4,'fontsize',12)

   end

end


% label the plots
annotation(fig,'textbox',...
    [0.170491956238961 0.894337899543378 0.0251942237661938 0.0342465753424658],...
    'String','A)',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
     [0.170491956238961 0.605905631659054 0.0251942237661938 0.0342465753424658],...
    'String','B)',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.502285457277418 0.605905631659054 0.0251942237661936 0.0342465753424658],...
    'String','C)',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.170491956238961 0.286270928462707 0.0251942237661936 0.0342465753424658],...
    'String','D)',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');

annotation(fig,'textbox',...
    [0.502285457277418 0.286270928462707 0.0251942237661936 0.0342465753424658],...
    'String','E)',...
    'FontWeight','bold',...
    'FontSize',16,...
    'FontName','Arial',...
    'FitBoxToText','off',...
    'EdgeColor','none');


exportgraphics(fig,[output_dir '\lp_and_bank_sub.png'],'Resolution',600);
