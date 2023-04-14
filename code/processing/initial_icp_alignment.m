
single_corr = 0;

if single_corr == 1

    rotation_filename = 'reference_initial_ICP_matrix.txt';
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
    fileInZ_old         = contains(listingNameX,[folderName '_scan01_trans.ply']);
    fileInZ_old         = listingNameX(fileInZ_old);
    fileInZ_old         = char(fileInZ_old(1));
    fileInZ             = ['Y:\livox\rotation_correction\' folderName '_scan01_trans.ply'];

    % bring in the first scan which had been aligned to scan02
    fileInA_old         = contains(listingNameX,[folderName '_scan02.ply']);
    fileInA_old         = listingNameX(fileInA_old);
    fileInA_old         = char(fileInA_old(1));
    fileInA             = ['Y:\livox\rotation_correction\' folderName '_scan02.ply'];

    % create copies of the files
    copyfile (['Y:\livox\livox_pcd_exported\' fileInZ_old], fileInZ)
    copyfile (['Y:\livox\livox_pcd_exported\' fileInA_old], fileInA)


    % bring in the rotation matrix from the alignment above
    fileForImport   = rotation_filename;

    cc_command = ['"C:\Program Files\CloudCompare\CloudCompare.exe " ' ...
        '-SILENT '...
        '-LOG_FILE ' [fileInZ(1:end-10) '_MATCHED_rotation_logfile.txt '] ...
        '-C_EXPORT_FMT PLY '...
        '-NO_TIMESTAMP ' ...
        '-O ' fileInZ ' '...  %scan 1
        '-APPLY_TRANS ' 'Y:\livox\livox_pcd_exported\' fileForImport ' ' ...
        ];
    [status,cmdout] = system(cc_command);

    % move the files
    files_to_move = { ...
        [fileInZ(1:end-4) '_TRANSFORMED.ply']; ...
        };

    move_location = { ...
        [fileInZ(1:end-4) '_MATCHED.ply']; ...
        };

    for c = 1:length(files_to_move)
        oldFileNameSingle = char(files_to_move(c,1));
        newFileNameSingle = char(move_location(c,1));
        java.io.File(oldFileNameSingle).renameTo(java.io.File(newFileNameSingle));
    end

else
    nameIn          = 'Y:\livox\livox_pcd_exported\';

    if length(nameIn) > 0 %~exist ([inputLocation(1:end-1) '_exported\' folderName '_initial_icp_logfile.txt'], 'file')

        if exist ([inputLocation(1:end-1) '_organised\' folderName '_scan01.ply'], 'file')

            saveName01      = [inputLocation(1:end-1) '_organised\' folderName '_scan01.ply'];
            saveName01_trans= [inputLocation(1:end-1) '_exported\' folderName '_scan01_trans.ply'];
            saveName02      = [inputLocation(1:end-1) '_organised\' folderName '_scan02.ply'];
        else
            saveName01      = [inputLocation(1:end-1) '_exported\' folderName '_scan01.ply'];
            saveName01_trans= [inputLocation(1:end-1) '_exported\' folderName '_scan01_trans.ply'];
            saveName02      = [inputLocation(1:end-1) '_exported\' folderName '_scan02.ply'];
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


        % initiate plots to show the segmented clouds to be aligned
        %figure();
        %hold on;
        %pcshow(ptCloud02_seg.Location,[1 0.2 0.2]); hold on;
        %pcshow(ptCloud01_seg.Location,[0.2 1 0.2]); hold on;

        % export the segmented reference cloud
        ref_cloud_seg   =  [inputLocation(1:end-1) '_exported\' folderName '_scan02_segmented.ply'];
        pcwrite(ptCloud02_seg,ref_cloud_seg,'Encoding','ascii');

        % export the segmented target cloud
        target_cloud_seg   =  [inputLocation(1:end-1) '_exported\' folderName '_scan01_trans_segmented.ply'];
        pcwrite(ptCloud01_seg,target_cloud_seg,'Encoding','ascii');


        % algn the clouds using cloud compare
        % the first cloud acts as the reference
        % newly aligned cloud is exported as saveName03
        %'-RANDOM_SAMPLING_LIMIT ' num2str(length(scan_01)+1) ' ' ...
        % '-SAVE_CLOUDS'

        limiter = max([length(ptCloud01_seg.Location); length(ptCloud02_seg.Location)]);

        cc_command = ['"C:\Program Files\CloudCompare\CloudCompare.exe " ' ...
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
    listingX        = dir(nameIn);
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
        copyfile (['Y:\livox\livox_pcd_exported\' fileInA], ['Y:\livox\livox_pcd_organised\' fileInA]) % create a copy of pointcloud01 for alignment
    catch
    end

    % bring in the rotation matrix from the alignment above
    substring       = [folderName '_scan01_trans_segmented_REGISTRATION_MATRIX'];
    Index           = find(contains(listingNameX,substring));
    Index           = min(Index);
    fileForImport   = char(listingNameX(Index));
    target_cloud_seg   =  [inputLocation(1:end-1) '_exported\' folderName '_scan01_trans_segmented.ply'];

    cc_command = ['"C:\Program Files\CloudCompare\CloudCompare.exe " ' ...
        '-SILENT '...
        '-LOG_FILE ' [target_cloud_seg(1:end-4) '_rotation_logfile.txt '] ...
        '-C_EXPORT_FMT PLY '...
        '-NO_TIMESTAMP ' ...
        '-O ' 'Y:\livox\livox_pcd_exported\' fileInZ ' '...  %scan 1
        '-APPLY_TRANS ' 'Y:\livox\livox_pcd_exported\' fileForImport ' ' ...
        ];
    [status,cmdout] = system(cc_command);


    % move the files
    files_to_move = { ...
        ['Y:\livox\livox_pcd_exported\' ... 
        fileInZ(1:end-4) '_TRANSFORMED.ply']; ...
        };

    move_location = { ...
       ['Y:\livox\livox_pcd_exported\' ... 
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

end