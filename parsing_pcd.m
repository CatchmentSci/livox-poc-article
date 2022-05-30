clear all; close all; clc;

inputLocation   = 'X:\Staff\MTP\_cam_monitoring_data\goldrill\livox_pcd\';
outputDir       = 'X:\Staff\MTP\_cam_monitoring_data\goldrill\livox_pcd_extracted\';
listing         = dir(inputLocation);


for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(contains(listingName,'.zip'));


%this section pulls out the times at 12 noon for each day of monitoring
s1 = {datenum('20220129_120000','yyyymmdd_HHMMSS')};
s2 = now;
s3 = {datestr(cell2mat(s1),'yyyymmdd_HHMMSS')};

a = 2;
while datenum(s3{a-1},'yyyymmdd_HHMMSS') < s2
    s3{a,1} = datestr(addtodate(datenum(s3{a-1},'yyyymmdd_HHMMSS'),24,'h'),'yyyymmdd_HHMMSS'); % add 24-hours
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

for a = unique(closestIndex) % cycle through each of the files

    scan_01         = [];
    scan_02         = [];
    temp = [outputDir char(listingName(a))];

    % extract the pcd files into a new folder when required
    if ~exist (temp(1:end-4), 'dir')
        [status,result] = system(['"C:\Program Files\7-Zip\7zG.exe" -y x ' '"' [inputLocation listingName{a}] '"' ' -o' '"' outputDir '"']);
        listing2        = dir([outputDir '\aws_pcd_files']);
        folderName      = char(cellstr(listing2(3).name));
        newActiveFolder = [outputDir 'aws_pcd_files\' folderName '\'];

        movefile ([newActiveFolder '*'], [outputDir folderName '\']);
        rmdir([outputDir 'aws_pcd_files\'], "s");
    else
        folderName      = [char(listingName{a}(1:end-4))];
    end

    % grab only .pcd files
    listing3 = dir([outputDir folderName '\']);
    for b = 1:length(listing3)
        listingNameFiles(b,1) = cellstr(listing3(b).name);
    end
    listingNameFiles = listingNameFiles(contains(listingNameFiles,'.pcd'));

    % split the data into discrete scans and convert to ply for export if
    % this hasn't already been done
    if ~exist ([inputLocation(1:end-1) '_exported\' folderName '_scan01.ply'], 'file')

        justLimitsX = [];
        justLimitsY = [];
        justLimitsZ = [];
        for c = 1:length(listingNameFiles)
            try
                ptCloud        = pcread([outputDir folderName '\' char(listingNameFiles(c))]);
                justLimitsX    = [justLimitsX;  ptCloud.XLimits];
                justLimitsY    = [justLimitsY;  ptCloud.YLimits];
                justLimitsZ    = [justLimitsZ;  ptCloud.ZLimits];
                clear ptCloud
            catch
            end
        end

        [scan01_idx, scan02_idx] = splittingLivox(justLimitsX,justLimitsY,justLimitsZ);
        Y(scan01_idx) = 1;
        Y(scan02_idx) = 2;

        for d = 1:length(Y)
            tempIn = char(listingNameFiles(d));
            try

                if Y(d) == 1 %sensor 1
                    ptCloud_01      = pcread([outputDir folderName '\' tempIn]);
                    scan_01_temp    = [ptCloud_01.Location, ptCloud_01.Intensity];
                    scan_01         = [scan_01; scan_01_temp];

                elseif Y(d) == 2 %even = sensor 2
                    ptCloud_02      = pcread([outputDir folderName '\' tempIn]);
                    scan_02_temp    = [ptCloud_02.Location, ptCloud_02.Intensity];
                    scan_02         = [scan_02; scan_02_temp];
                end

            catch
            end

        end

        % bring in the broad-scale alignment data for the livox
        refDataIn      = readtable('X:\Staff\MTP\_cam_monitoring_data\goldrill\georeferencing\GCPs_20220128_raw_OSGB.xlsx',...
            'Sheet', 'Livox TLS Georeferencing');
        refDataIn           = table2array(refDataIn(:,2:end));
        [tform]             = estimateGeometricTransform3D(refDataIn(:,1:3),refDataIn(:,4:6),'rigid'); % transform one to two
        [x,y,z]             = transformPointsForward(tform,scan_01(:,1),scan_01(:,2),scan_01(:,3));
        scan01_trans        = [x,y,z];

        %scatter3(scan_02(:,1),scan_02(:,2),scan_02(:,3),'+b'); hold on;
        %scatter3(scan01_trans(:,1),scan01_trans(:,2),scan01_trans(:,3),'+r'); hold on;

        % write the data to the dir as seperate ply files
        temp_trans          = ['D:\Temp\'];
        temp01              = [temp_trans folderName '_scan01.ply'];
        temp01_trans        = [temp_trans folderName '_scan01_trans.ply'];
        temp02              = [temp_trans folderName '_scan02.ply'];

        ptCloud01           = pointCloud(scan_01(:,1:3),Intensity=scan_01(:,4));
        ptCloud01_trans     = pointCloud(single(scan01_trans(:,1:3)),Intensity=scan_01(:,4));
        ptCloud02           = pointCloud(scan_02(:,1:3),Intensity=scan_02(:,4));

        pcwrite(ptCloud01,temp01,'Encoding','ascii');
        pcwrite(ptCloud02,temp02,'Encoding','ascii');
        pcwrite(ptCloud01_trans,temp01_trans,'Encoding','ascii');

        saveName01          = [inputLocation(1:end-1) '_exported\' folderName '_scan01.ply'];
        saveName01_trans    = [inputLocation(1:end-1) '_exported\' folderName '_scan01_trans.ply'];
        saveName02          = [inputLocation(1:end-1) '_exported\' folderName '_scan02.ply'];

        movefile (temp01, saveName01);
        movefile (temp01_trans, saveName01_trans);
        movefile (temp02, saveName02);

        clear ptCloud_01 ptCloud_02 scan_01_temp scan_02_temp saveName01 saveName02 scan01 scan02 Y scan01_idx scan02_idx
    end


    % only run if logfile does not exist
    if ~exist ([inputLocation(1:end-1) '_exported\' folderName '_scan01_trans_logfile.txt'], 'file')

        saveName01      = [inputLocation(1:end-1) '_exported\' folderName '_scan01.ply'];
        saveName01_trans= [inputLocation(1:end-1) '_exported\' folderName '_scan01_trans.ply'];
        saveName02      = [inputLocation(1:end-1) '_exported\' folderName '_scan02.ply'];

        % algn the clouds using cloud compare
        % the first cloud acts as the reference
        % newly aligned cloud is exported as saveName03
        %'-RANDOM_SAMPLING_LIMIT ' num2str(length(scan_01)+1) ' ' ...
        % '-SAVE_CLOUDS'
        cc_command = ['"C:\Program Files\CloudCompare\CloudCompare.exe " ' ...
            '-SILENT '...
            '-LOG_FILE ' [saveName01_trans(1:end-4) '_logfile.txt ']...
            '-C_EXPORT_FMT PLY '...
            '-O ' saveName02 ' '...
            '-O ' saveName01_trans ' '...
            '-ICP '...
            '-MIN_ERROR_DIFF 1e-6 '...
            '-RANDOM_SAMPLING_LIMIT 50000 '...
            '-FARTHEST_REMOVAL '...
            '-OVERLAP 10 '...
            '-REFERENCE_IS_FIRST '...
            ];
        [status,cmdout] = system(cc_command);

    end

    % merge the aligned clouds and export in BNG coordiante systems
    if ~exist ([inputLocation(1:end-1) '_exported\' folderName '_aligned_merged.ply'], 'file')
        
        nameIn          = 'X:\Staff\MTP\_cam_monitoring_data\goldrill\livox_pcd_exported';
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
        refDataIn      = readtable('X:\Staff\MTP\_cam_monitoring_data\goldrill\georeferencing\GCPs_20220128_raw_OSGB.xlsx',...
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
                all_intensity   = temp_pts(idx3(idx4),1:3);
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

    end


end

