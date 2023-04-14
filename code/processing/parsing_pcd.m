clear all; close all; clc;

ignore1 = 0;
inputLocation   = 'Y:\livox\livox_pcd\';
extracted_dir   = 'Y:\livox\livox_pcd_extracted\';
onganised_dir   = 'Y:\livox\livox_pcd_organised\';
exported_dir    = 'Y:\livox\livox_pcd_exported\';
%inputLocation   = 'C:\Users\Matt\Downloads\2021-11-05_16-24-48\aws_pcd_files\2021-11-05_16-24-48\';
listing         = dir(inputLocation);


for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(contains(listingName,'.zip'));


%this section pulls out the times at 12 noon for each day of monitoring
s1 = {datenum('20220129_120000','yyyymmdd_HHMMSS')};
s2 =  datenum('20220531_120000','yyyymmdd_HHMMSS');
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
ii       = randperm(length(h));
indexUse = h(ii(1:length(ii)));

for a = indexUse % cycle through each of the files

    scan_01         = [];
    scan_02         = [];
    temp = [extracted_dir char(listingName(a))];

    % extract the pcd files into a new folder when required
    if ~exist (temp(1:end-4), 'dir')
        [status,result] = system(['"C:\Program Files\7-Zip\7zG.exe" -y x ' '"' [inputLocation listingName{a}] '"' ' -o' '"' extracted_dir '"']);
        listing2        = dir([extracted_dir '\aws_pcd_files']);
        folderName      = char(cellstr(listing2(3).name));
        newActiveFolder = [extracted_dir 'aws_pcd_files\' folderName '\'];

        movefile ([newActiveFolder '*'], [extracted_dir folderName '\'],'f');
        rmdir([extracted_dir 'aws_pcd_files\'], "s");
    else
        folderName      = [char(listingName{a}(1:end-4))];
    end

    % check to see if data has already been processed
    if exist (['Y:\livox\livox_processed\' folderName '_MERGED.ply'], 'file')
        continue
    end


    % grab only .pcd files
    listing3 = dir([extracted_dir folderName '\']);
    for b = 1:length(listing3)
        listingNameFiles(b,1) = cellstr(listing3(b).name);
    end
    listingNameFiles = listingNameFiles(contains(listingNameFiles,'.pcd'));

    % split the data into discrete scans and convert to ply for export if
    % this hasn't already been done
    if ~exist ([inputLocation(1:end-1) '_organised\' folderName '_scan01.ply'], 'file')

        justLimitsX = [];
        justLimitsY = [];
        justLimitsZ = [];
        for c = 1:length(listingNameFiles)
            try
                ptCloud        = pcread([extracted_dir folderName '\' char(listingNameFiles(c))]);
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
                    ptCloud_01      = pcread([extracted_dir folderName '\' tempIn]);
                    scan_01_temp    = [ptCloud_01.Location, ptCloud_01.Intensity];
                    scan_01         = [scan_01; scan_01_temp];

                elseif Y(d) == 2 %even = sensor 2
                    ptCloud_02      = pcread([extracted_dir folderName '\' tempIn]);
                    scan_02_temp    = [ptCloud_02.Location, ptCloud_02.Intensity];
                    scan_02         = [scan_02; scan_02_temp];
                end

            catch
            end
        end
    end

    if numel(scan_01) < 1 && numel(scan_02) < 1
        ignore1     = 1;
        scan_01     = pcread([inputLocation(1:end-1) '_organised\' folderName '_scan01.ply']);
        scan_01     = [scan_01.Location, scan_01.Intensity];
        scan_02     = pcread([inputLocation(1:end-1) '_organised\' folderName '_scan02.ply']);
        scan_02     = [scan_02.Location, scan_02.Intensity];
    end

    % bring in the broad-scale alignment data for the livox
    %refDataIn      = readtable('Y:\livox\georeferencing\GCPs_20220128_raw_OSGB.xlsx',...
    %    'Sheet', 'Livox TLS Georeferencing');
    %refDataIn           = table2array(refDataIn(:,2:end));
    %[tform]             = estimateGeometricTransform3D(refDataIn(:,1:3),refDataIn(:,4:6),'rigid'); % transform one to two
    %[x,y,z]             = transformPointsForward(tform,scan_01(:,1),scan_01(:,2),scan_01(:,3));
    %scan01_trans        = [x,y,z];


    %0.962879 -0.269929 -0.001716 0.745131; ...
    %0.269928 0.962787 0.013400 -0.327171; ...
    %-0.001965 -0.013366 0.999909 1.189322; ...
    %0.000000 0.000000 0.000000 1.000000


    A = [0.9635062801497850 0.2676850741516215 -0.0005909216237436 -0.5493350603457076; ...
        -0.2676623656437154 0.9633906846000911 -0.0153377587599350 0.5095186021667442; ...
        -0.0035364007033295 0.0149361943683409 0.9998821950449247 -1.1867910034680096; ...
        0.0000000000000000 0.0000000000000000 0.0000000000000000 1.0000000000000000; ...
        ];
    tform = affinetform3d(A);
    %[x,y,z]             = transformPointsForward(tform,scan_01(:,1),scan_01(:,2),scan_01(:,3));
    [x,y,z]             = transformPointsInverse(tform,scan_01(:,1),scan_01(:,2),scan_01(:,3));
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

    %if ignore1 == 1
    %    pcwrite(ptCloud01_trans,temp01_trans,'Encoding','ascii');
    %    saveName01_trans    = [inputLocation(1:end-1) '_exported\' folderName '_scan01_trans.ply'];
    %    movefile (temp01_trans, saveName01_trans);
    %else
    pcwrite(ptCloud01,temp01,'Encoding','ascii');
    pcwrite(ptCloud02,temp02,'Encoding','ascii');
    pcwrite(ptCloud01_trans,temp01_trans,'Encoding','ascii');

    saveName01          = [inputLocation(1:end-1) '_exported\' folderName '_scan01.ply'];
    saveName01_trans    = [inputLocation(1:end-1) '_exported\' folderName '_scan01_trans.ply'];
    saveName02          = [inputLocation(1:end-1) '_exported\' folderName '_scan02.ply'];

    movefile (temp01, saveName01,'f');
    movefile (temp01_trans, saveName01_trans,'f');
    movefile (temp02, saveName02,'f');
    %end
    clear ptCloud_01 ptCloud_02 scan_01_temp scan_02_temp saveName01 saveName02 scan01 scan02 Y scan01_idx scan02_idx

    % run the initial icp alignment on a subset of the point cloud
    initial_icp_alignment

    % merge the aligned clouds and export in BNG coordinate systems
    marker_align        = 0;
    fixed_point_align   = 1;
    rotation_align      = 0;

    if ~exist ([inputLocation(1:end-1) '_exported\' folderName '_aligned_merged.ply'], 'file') && ...
            marker_align == 1

        % call the target alignment script
        target_alignment

    elseif fixed_point_align == 1 % use a different method

        tree_alignment

    elseif rotation_align == 1 % use a different method
        if contains('2022-01-29_12-57-43', folderName) == 0
            rotation_alignment
        end


    end

end

