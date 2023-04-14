clear all; close all; clc;

nameIn = 'Y:\livox\livox_pcd_exported';
listingX        = dir(nameIn);
listingNameX    = {};
for x = 1:length(listingX)
    listingNameX(x,1) = cellstr(listingX(x).name);
end
clear x



% bring in the first scan which had been aligned to scan02
fileInZ_old         = contains(listingNameX,['_scan02.ply']);
fileInZ_old         = listingNameX(fileInZ_old);

for c = 1:length(listingNameX)

    fileInZ_t         = char(fileInZ_old(c));
    fileInZ             = [nameIn '\' fileInZ_t];

    fileInA             = ['Y:\livox\livox_pcd_organised\' fileInZ_t];

    java.io.File(fileInZ).renameTo(java.io.File(fileInA));
end