clear all;

inputLocation   = 'C:\Users\Matt\Downloads\2021-11-05_16-24-48\aws_pcd_files\2021-11-05_16-24-48\';
listing         = dir(inputLocation);
scan_01         = [];
scan_02         = [];

for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(contains(listingName,'.pcd'));

justLimitsZ = [];
for a = 1:length(listingName)
    %justTime(a,1) = str2double(listingName{a,1}(1:end-4));
    ptCloud        = pcread([inputLocation char(listingName(a))]);
    justLimitsZ     = [justLimitsZ;  ptCloud.ZLimits];
    clear ptCloud
end

[Y,E] = discretize(justLimitsZ(:,1),2); % bin according to min Z elevation

for a = 1:length(listingName)
    if rem(Y(a),2) ~= 0 %odd = sensor 1
        ptCloud_01      = pcread([inputLocation char(listingName(a,1))]);
        scan_01_temp    = [ptCloud_01.Location, ptCloud_01.Intensity];
        scan_01         = [scan_01; scan_01_temp];
    
    else  %even = sensor 2
        ptCloud_02      = pcread([inputLocation char(listingName(a,1))]);
        scan_02_temp    = [ptCloud_02.Location, ptCloud_02.Intensity];
        scan_02         = [scan_02; scan_02_temp];
    end

    clear ptCloud_01 ptCloud_02 scan_01_temp scan_02_temp
end 

scatter3(scan_01(:,1),scan_01(:,2),scan_01(:,3),'b+'); hold on
scatter3(scan_02(:,1),scan_02(:,2),scan_02(:,3),'r+');
