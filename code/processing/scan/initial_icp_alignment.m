
if ~isempty(exported_dir)

    if exist ([onganised_dir folderName '_scan01.ply'], 'file')

        saveName01      = [onganised_dir folderName '_scan01.ply'];
        saveName01_trans= [exported_dir folderName '_scan01_trans.ply'];
        saveName02      = [onganised_dir folderName '_scan02.ply'];
    else
        saveName01      = [exported_dir folderName '_scan01.ply'];
        saveName01_trans= [exported_dir folderName '_scan01_trans.ply'];
        saveName02      = [exported_dir folderName '_scan02.ply'];
    end

    % import and segment scan 02 (reference)
    fileInRef       = [saveName02]; % this is the reference cloud
    temp_pt_02      = pcread(fileInRef);
    temp_z1         = [double(temp_pt_02.Location(:,1)),double(temp_pt_02.Location(:,2)),double(temp_pt_02.Location(:,3))];
    pts_icp_segmentation;
    ptCloud02_seg   = select(temp_pt_02,indices);
    clear temp_z1

    % import and segment scan 01 (target)
    fileInRef       = [saveName01_trans]; % this is the target cloud
    temp_pt_01      = pcread(fileInRef);
    temp_z1         = [double(temp_pt_01.Location(:,1)),double(temp_pt_01.Location(:,2)),double(temp_pt_01.Location(:,3))];
    pts_icp_segmentation;
    ptCloud01_seg   = select(temp_pt_01,indices);
    clear temp_z1

    % export the segmented reference cloud
    ref_cloud_seg   =  [exported_dir folderName '_scan02_segmented.ply'];
    pcwrite(ptCloud02_seg,ref_cloud_seg,'Encoding','ascii');

    % export the segmented target cloud
    target_cloud_seg   =  [exported_dir folderName '_scan01_trans_segmented.ply'];
    pcwrite(ptCloud01_seg,target_cloud_seg,'Encoding','ascii');

    limiter = max([length(ptCloud01_seg.Location); length(ptCloud02_seg.Location)]);

    cc_command = [ccpath ' ' ...
        '-SILENT '...
        '-LOG_FILE ' [target_cloud_seg(1:end-26) 'initial_icp_logfile.txt '] ...
        '-C_EXPORT_FMT PLY '...
        '-NO_TIMESTAMP ' ...
        '-O ' ref_cloud_seg ' '...
        '-O ' target_cloud_seg ' '...
        '-ICP '...
        '-MIN_ERROR_DIFF 1e-7 '...
        '-RANDOM_SAMPLING_LIMIT ' num2str(limiter+1) ' ' ...
        '-FARTHEST_REMOVAL '...
        '-OVERLAP 100 '...
        '-REFERENCE_IS_FIRST '
        ];
    [status,cmdout] = system(cc_command);

end
% Bring in the other part of the scan (01), which was previously
% aligned to scan 02.
listingX        = dir(exported_dir);
listingNameX    = {};
for x = 1:length(listingX)
    listingNameX(x,1) = cellstr(listingX(x).name);
end
clear x

% bring in the first scan which had been coarsley aligned to scan02
fileInZ         = contains(listingNameX,[folderName '_scan01_trans.ply']);
fileInZ         = listingNameX(fileInZ);
fileInZ         = char(fileInZ(1));
fileInA         = [folderName '_scan02.ply'];

try
    copyfile ([exported_dir fileInA], [onganised_dir fileInA]) % create a copy of pointcloud01 for alignment
catch
end

% bring in the rotation matrix from the alignment above
substring       = [folderName '_scan01_trans_segmented_REGISTRATION_MATRIX'];
Index           = find(contains(listingNameX,substring));
Index           = min(Index);
fileForImport   = char(listingNameX(Index));
target_cloud_seg   =  [exported_dir folderName '_scan01_trans_segmented.ply'];

cc_command = [ccpath ' ' ...
    '-SILENT '...
    '-LOG_FILE ' [target_cloud_seg(1:end-4) '_rotation_logfile.txt '] ...
    '-C_EXPORT_FMT PLY '...
    '-NO_TIMESTAMP ' ...
    '-O ' exported_dir fileInZ ' '...  %scan 1
    '-APPLY_TRANS ' exported_dir fileForImport ' ' ...
    ];
[status,cmdout] = system(cc_command);


% move the files
files_to_move = { ...
    [exported_dir ...
    fileInZ(1:end-4) '_TRANSFORMED.ply']; ...
    };

move_location = { ...
    [exported_dir ...
    fileInZ(1:end-4) '_MATCHED.ply']; ...
    };

for c = 1:length(files_to_move)
    try
        oldFileNameSingle = char(files_to_move(c,1));
        newFileNameSingle = char(move_location(c,1));
        movefile(oldFileNameSingle,newFileNameSingle,'f');
    catch
    end
end

