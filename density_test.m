clear all; close all; clc;

inputLocation = 'Y:\livox\livox_pcd\';
extracted_dir = 'Y:\livox\density_test\';
fileIn = '2022-01-29_12-57-43.zip';

listing         = dir(inputLocation);

for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(contains(listingName,'.zip'));

for a = 1 % cycle through each of the files

    scan_01         = [];
    scan_02         = [];
    temp = [extracted_dir char(listingName(a))];

    % extract the pcd files into a new folder when required
    if ~exist (temp(1:end-4), 'dir')
        [status,result] = system(['"C:\Program Files\7-Zip\7zG.exe" -y x ' '"' [inputLocation fileIn] '"' ' -o' '"' extracted_dir '"']);
        listing2        = dir([extracted_dir '\aws_pcd_files']);
        folderName      = char(cellstr(listing2(3).name));
        newActiveFolder = [extracted_dir 'aws_pcd_files\' folderName '\'];

        movefile ([newActiveFolder '*'], [extracted_dir folderName '\']);
        rmdir([extracted_dir 'aws_pcd_files\'], "s");
    else
        folderName      = [char(listingName{a}(1:end-4))];
    end

    % grab only .pcd files
    listing3 = dir([extracted_dir folderName '\']);
    for b = 1:length(listing3)
        listingNameFiles(b,1) = cellstr(listing3(b).name);
    end
    listingNameFiles = listingNameFiles(contains(listingNameFiles,'.pcd'));

    % split the data into discrete scans and convert to ply for export if
    % this hasn't already been done

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

            % CALCULATE DENSITY OF ROI
            x = 12.00;
            y = 28.00;
            z = 1.00;
            r = 0.5;
            areaD = (pi.*r^2); %m2
            p       = sqrt((scan_02(:,1)-x).^2 + (scan_02(:,2)-y).^2 + (scan_02(:,3)-z).^2)<r;
            withinD{d} = scan_02(p,:);

            if d == length(Y)
                withinD{:}; temp1 = ans;
                density_ROI_1 = length(temp1)./areaD;
            end
 

            % CALCULATE DENSITY OF ROI2
            x = 22.80;
            y = 43.50;
            z = 3.00;
            r = 0.5;
            areaD = (pi.*r^2); %m2
            p       = sqrt((scan_02(:,1)-x).^2 + (scan_02(:,2)-y).^2 + (scan_02(:,3)-z).^2)<r;
            withinD2{d} = scan_02(p,:);

            if d == length(Y)
                withinD2{:}; temp1 = ans;
                density_ROI_2 = length(temp1)./areaD;
            end


        catch
        end
    end
end
