
nameIn = exported_dir;
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

    try

        fileInZ_t         = char(fileInZ_old(c));
        fileInZ             = [nameIn '\' fileInZ_t];
        fileInA             = [onganised_dir fileInZ_t];
        java.io.File(fileInZ).renameTo(java.io.File(fileInA));
        
    catch
    end
end