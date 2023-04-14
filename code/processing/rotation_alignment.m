% the alignment producing the lowest rmse value is
% 2022-02-28_12-57-59_scan02_CROPPED_logfile. The rmse of this is 0.022m.
single_corr  = 1;
if single_corr == 1

rotation_filename = 'reference_CROPPED_rotation_logfile.txt';
nameIn            = 'Y:\livox\livox_pcd_exported\';

% Bring in the other part of the scan (01), which was previously
% aligned to scan 02.
listingX        = dir(nameIn);
listingNameX    = {};
for x = 1:length(listingX)
    listingNameX(x,1) = cellstr(listingX(x).name);
end
clear x

% bring in the first scan which had been aligned to scan02
fileInZ         = contains(listingNameX,[folderName '_scan01_trans_MATCHED.ply']);
fileInZ         = listingNameX(fileInZ);
fileInZ         = char(fileInZ(1));

% bring in the first scan which had been aligned to scan02
fileInA         = contains(listingNameX,[folderName '_scan02.ply']);
fileInA         = listingNameX(fileInA);
fileInA         = char(fileInA(1));


% bring in the rotation matrix from the alignment above
fileForImport   = rotation_filename;


cc_command = ['"C:\Program Files\CloudCompare\CloudCompare.exe " ' ...
    '-SILENT '...
    '-LOG_FILE ' ['Y:\livox\rotation_correction\' fileInA(1:end-4) '_rotation_logfile.txt '] ...
    '-C_EXPORT_FMT PLY '...
    '-NO_TIMESTAMP ' ...
    '-O ' 'Y:\livox\livox_pcd_exported\' fileInA ' '... %scan 2
    '-O ' 'Y:\livox\livox_pcd_exported\' fileInZ ' '...  %scan 1
    '-APPLY_TRANS ' 'Y:\livox\rotation_correction\' fileForImport ' ' ...
    ];
[status,cmdout] = system(cc_command);

else

r_matrix = ...
    [0.999996 0.000273 0.002918 -0.044537; ...
    -0.000267 0.999998 -0.002069 0.055142; ...
    -0.002918 0.002069 0.999994 -0.084291; ...
    0.000000 0.000000 0.000000 1.000000]';

rotation_filename = 'reference_CROPPED_rotation_logfile.txt';
nameIn          = 'Y:\livox\livox_pcd_exported\';

% Bring in the other part of the scan (01), which was previously
% aligned to scan 02.
listingX        = dir(nameIn);
listingNameX    = {};
for x = 1:length(listingX)
    listingNameX(x,1) = cellstr(listingX(x).name);
end
clear x

% bring in the first scan which had been aligned to scan02
fileInZ         = contains(listingNameX,[folderName '_scan01_trans_TRANSFORMED.ply']);
fileInZ         = listingNameX(fileInZ);
fileInZ         = char(fileInZ(1));

% bring in the first scan which had been aligned to scan02
fileInA         = contains(listingNameX,[folderName '_scan02.ply']);
fileInA         = listingNameX(fileInA);
fileInA         = char(fileInA(1));


% bring in the rotation matrix from the alignment above
fileForImport   = rotation_filename;


cc_command = ['"C:\Program Files\CloudCompare\CloudCompare.exe " ' ...
    '-SILENT '...
    '-LOG_FILE ' [fileInA(1:end-4) '_rotation_logfile.txt '] ...
    '-C_EXPORT_FMT PLY '...
    '-NO_TIMESTAMP ' ...
    '-O ' 'Y:\livox\livox_pcd_exported\' fileInA ' '... %scan 2
    '-O ' 'Y:\livox\livox_pcd_exported\' fileInZ ' '...  %scan 1
    '-APPLY_TRANS ' 'Y:\livox\livox_pcd_exported\' fileForImport ' ' ...
    ];
[status,cmdout] = system(cc_command);

% move the files
files_to_move = ...
    {['Y:\livox\livox_pcd_exported\' fileInA(1:end-4) '_rotation_logfile.txt']; ...
    ['Y:\livox\livox_pcd_exported\' fileInA(1:end-4) '_TRANSFORMED.ply']; ...
    ['Y:\livox\livox_pcd_exported\' fileInZ]; ...
    };

move_location = ...
    {['Y:\livox\rotation_correction\' fileInA(1:end-4) '_rotation_logfile.txt']; ...
    ['Y:\livox\rotation_correction\' fileInA(1:end-4) '_TRANSFORMED.ply']; ...
    ['Y:\livox\rotation_correction\' fileInZ(1:end-15) 'MATCHED.ply']; ...
    };

for c = 1:length(files_to_move)
    oldFileNameSingle = char(files_to_move(c,1));
    newFileNameSingle = char(move_location(c,1));
    java.io.File(oldFileNameSingle).renameTo(java.io.File(newFileNameSingle));
end



end

