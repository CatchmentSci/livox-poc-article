clear all; close all; clc;

% provide inputs specific to your computer - these folders need to exist
% in advance of running the script
root_dir        = 'Y:\livox\'; % specify the root dir for your workspace
inputLocation   = [root_dir 'livox_pcd\']; % do not edit
extracted_dir   = [root_dir 'livox_pcd_extracted\']; % SPECIFY the location where data downloaded from the archive (livox_pcd) data is stored. The files stored in this folder should be the unzipped contents of the 'livox_pcd.7z' - i.e. 1048 .7z files
onganised_dir   = [root_dir 'livox_pcd_organised\']; % CREATE THIS SUBFOLDER: temp dir for data - should be an empty folder to start
exported_dir    = [root_dir 'livox_pcd_exported\']; % CREATE THIS SUBFOLDER: temp dir where data is stored - should be an empty folder to start
processed_dir   = [root_dir 'livox_processed\']; % CREATE THIS SUBFOLDER: final dir where processed data is stored - should be an empty folder to start
scratch_dir     = 'D:\Temp\'; % EDIT THIS path to a temp dir where data isto be stored 
zip_location    = '"C:\Program Files\7-Zip\7zG.exe"'; % EDIT THIS path to 7zip installation - needs the double quotes
ccpath          = '"C:\Program Files\CloudCompare\CloudCompare.exe"'; % EDIT THIS path to cloud compare installation - needs the double quotes

listing         = dir(inputLocation);
ignore1 = 0;
for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(contains(listingName,'.zip'));

%this section pulls out the times at 12 noon for each day of monitoring
s1 = {datenum('20220129_120000','yyyymmdd_HHMMSS')};
s2 =  datenum('20220501_120000','yyyymmdd_HHMMSS');
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

% for random input order
%h        = unique(closestIndex);
%ii       = randperm(length(h));
%indexUse = h(ii(1:length(ii)));

% for chronological order
h        = unique(closestIndex);
indexUse = h;

for a = indexUse % cycle through each of the files

    scan_01         = [];
    scan_02         = [];
    temp = [extracted_dir char(listingName(a))];

    % extract the pcd files into a new folder when required
    if ~exist (temp(1:end-4), 'dir')
        [status,result] = system([zip_location ' -y x ' '"' [inputLocation listingName{a}] '"' ' -o' '"' extracted_dir '"']);
        listing2        = dir([extracted_dir '\aws_pcd_files']);
        folderName      = char(cellstr(listing2(3).name));
        newActiveFolder = [extracted_dir 'aws_pcd_files\' folderName '\'];

        movefile ([newActiveFolder '*'], [extracted_dir folderName '\'],'f');
        rmdir([extracted_dir 'aws_pcd_files\'], "s");
    else
        folderName      = [char(listingName{a}(1:end-4))];
    end

    % check to see if data has already been processed
    if exist ([processed_dir folderName '_MERGED.ply'], 'file')
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
    if ~exist ([onganised_dir folderName '_scan01.ply'], 'file')

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
        scan_01     = pcread([onganised_dir folderName '_scan01.ply']);
        scan_01     = [scan_01.Location, scan_01.Intensity];
        scan_02     = pcread([onganised_dir folderName '_scan02.ply']);
        scan_02     = [scan_02.Location, scan_02.Intensity];
    end

    % initial coarse transformation
    A = [0.9635062801497850 0.2676850741516215 -0.0005909216237436 -0.5493350603457076; ...
        -0.2676623656437154 0.9633906846000911 -0.0153377587599350 0.5095186021667442; ...
        -0.0035364007033295 0.0149361943683409 0.9998821950449247 -1.1867910034680096; ...
        0.0000000000000000 0.0000000000000000 0.0000000000000000 1.0000000000000000; ...
        ];
    tform = affinetform3d(A);

    % check to see if there is data within the scan arrays and exit if not
    if isempty(scan_01) || isempty(scan_02)
        continue
    end

    [x,y,z]             = transformPointsInverse(tform,scan_01(:,1),scan_01(:,2),scan_01(:,3));
    scan01_trans        = [x,y,z];

    % write the data to the dir as seperate ply files
    temp_trans          = scratch_dir;
    temp01              = [temp_trans folderName '_scan01.ply'];
    temp01_trans        = [temp_trans folderName '_scan01_trans.ply'];
    temp02              = [temp_trans folderName '_scan02.ply'];

    ptCloud01           = pointCloud(scan_01(:,1:3),Intensity=scan_01(:,4));
    ptCloud01_trans     = pointCloud(single(scan01_trans(:,1:3)),Intensity=scan_01(:,4));
    ptCloud02           = pointCloud(scan_02(:,1:3),Intensity=scan_02(:,4));

    pcwrite(ptCloud01,temp01,'Encoding','ascii');
    pcwrite(ptCloud02,temp02,'Encoding','ascii');
    pcwrite(ptCloud01_trans,temp01_trans,'Encoding','ascii');

    saveName01          = [exported_dir folderName '_scan01.ply'];
    saveName01_trans    = [exported_dir folderName '_scan01_trans.ply'];
    saveName02          = [exported_dir folderName '_scan02.ply'];

    java.io.File(temp01).renameTo(java.io.File(saveName01));
    java.io.File(temp01_trans).renameTo(java.io.File(saveName01_trans));
    java.io.File(temp02).renameTo(java.io.File(saveName02));
    clear ptCloud_01 ptCloud_02 scan_01_temp scan_02_temp saveName01 saveName02 scan01 scan02 Y scan01_idx scan02_idx

    % run the initial icp alignment on a subset of the point cloud
    initial_icp_alignment

    % run the external alignment
    tree_alignment

end

% tidy up the folders - move scan02 to processed dir
move_pcd_files



