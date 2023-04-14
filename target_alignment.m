nameIn          = 'Y:\livox\livox_pcd_exported';
saveName01      = [inputLocation(1:end-1) '_exported\' folderName '_scan01.ply'];
temp_pt_01      = pcread(saveName01);
listingX        = dir(nameIn);

listingNameX     = {};
for x = 1:length(listingX)
    listingNameX(x,1) = cellstr(listingX(x).name);
end
clear x

% bring in the aligned ply files
fileInX         = listingNameX(contains(listingNameX,[folderName '_scan01_trans_REGISTERED']));
fileInY         = listingNameX(contains(listingNameX,[folderName '_scan02']));
temp_pt         = pcread([nameIn '\' char(fileInX)]);
ptCloud01_reg   = pointCloud(temp_pt.Location,Intensity=temp_pt_01.Intensity);
ptCloud02       = pcread([nameIn '\' char(fileInY)]);

% merge the aligned point clouds
ptCloudOut          = pccat([ptCloud01_reg,ptCloud02]);
ptCloudOut_BNG      = ptCloudOut; % create a copy
temp_pts            = ptCloudOut.Location;

% align the livox data with the GNSS GCP survey data
refDataIn      = readtable('Y:\livox\georeferencing\GCPs_20220128_raw_OSGB.xlsx',...
    'Sheet', 'Livox Georeferencing - BNG');
refDataIn           = table2array(refDataIn(:,2:end));
idx(1:6)            = true;

initialLocations = refDataIn(:,4:6);
for x = 1:length(idx)

    idx2            = rangesearch(temp_pts,initialLocations(x,:),0.25); % find points within 0.25m search radius
    idx3            = cell2mat(idx2)';
    val_idx         = max(ptCloudOut.Intensity(idx3));
    idx4            = find(ptCloudOut.Intensity(idx3,:)==val_idx);

    if length(idx4) ==1
        max_intensity(x,:)   = temp_pts(idx3(idx4),1:3);
        scatter3(temp_pts(idx3,1),temp_pts(idx3,2),temp_pts(idx3,3),'b'); hold on;
        scatter3(temp_pts(idx3(idx4),1),temp_pts(idx3(idx4),2),temp_pts(idx3(idx4),3),'r')
    else
        all_intensity        = temp_pts(idx3(idx4),1:3);
        max_intensity(x,:)   = median(all_intensity); % take the median of the high intensity points
        scatter3(temp_pts(idx3,1),temp_pts(idx3,2),temp_pts(idx3,3),'b'); hold on;
        scatter3(temp_pts(idx3(idx4),1),temp_pts(idx3(idx4),2),temp_pts(idx3(idx4),3),'r')
        scatter3(max_intensity(x,1),max_intensity(x,2),max_intensity(x,3),'k'); hold on;
    end
    movementGCP(x,:) = initialLocations(x,:) - max_intensity(x,:);
end

[tform]             = estimateGeometricTransform3D(refDataIn(idx,4:6),refDataIn(idx,1:3),'rigid');
[x,y,z]             = transformPointsForward(tform,max_intensity(:,1),max_intensity(:,2),max_intensity(:,3));
difference1(:,1)    = refDataIn(:,1) - x;
difference1(:,2)    = refDataIn(:,2) - y;
difference1(:,3)    = refDataIn(:,3) - z;
rmse1               = mean(sqrt(difference1(idx,1).^2 + difference1(idx,2).^2 + difference1(idx,3).^2));
[x,y,z]             = transformPointsForward(tform,temp_pts(:,1),temp_pts(:,2),temp_pts(:,3));

ptCloud01_BNG       = pointCloud( single([x,y,z]),Intensity=ptCloudOut.Intensity);

temp_trans          = ['D:\Temp\'];
temp_merged         = [temp_trans folderName '_aligned_merged.ply'];
temp_merged_BNG     = [temp_trans folderName '_aligned_merged_BNG.ply'];

pcwrite(ptCloudOut,temp_merged,'Encoding','ascii');
pcwrite(ptCloud01_BNG,temp_merged_BNG,'Encoding','ascii');

saveName01          = [inputLocation(1:end-1) '_exported\' folderName '_aligned_merged.ply'];
saveName02          = [inputLocation(1:end-1) '_exported\' folderName '_aligned_merged_BNG.ply'];

movefile (temp_merged, saveName01);
movefile (temp_merged_BNG, saveName02)

