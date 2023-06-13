
listing         = dir(registration_matrix);

for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(3:end);
files_temp  = cellfun(@(v)v(1:19),listingName,'UniformOutput',false);
uc          = unique(files_temp) ;

% internal or external alignment?
if internal == 1
    stringIn = '_scan01_trans_segmented_REGISTRATION_MATRIX';
else
    stringIn = '_scan02_CROPPED1_MERGED_REGISTRATION_MATRIX';
end

files_temp2 = cellfun(@(uc)[uc stringIn],files_temp,'UniformOutput',false);
uc          = unique(files_temp) ;
files_temp2 = uc;

dateTime(1:numel(files_temp2),:) = NaN;
reference_point = [6.70, 29.80,2.00; ...
    21.5 26.5 2.00; ...
    42.0 17.5 2.00];

for a = 2:length(files_temp2)
    try
        
        tempTable   = readtable([registration_matrix char(files_temp2(a)) stringIn '.txt'], 'ReadVariableNames',false);
        tempTable   = table2cell(tempTable);
        if numel(tempTable) > 0
            T   = cell2mat(tempTable)';
            tform1 = affine3d(T);

            for b = 1:3
                [x1{b}(a),y1{b}(a),z1{b}(a)] = transformPointsForward(tform1,reference_point(b,1),reference_point(b,2),reference_point(b,3));
                x_adj{b}(a,1) = x1{b}(a) - x1{b}(2);
                y_adj{b}(a,1) = y1{b}(a) - y1{b}(2);
                z_adj{b}(a,1) = z1{b}(a) - z1{b}(2);
            end
            % Extracting scale
            scale(a,1:3) = sqrt(sum(T(1:3,1:3).^2));

            % Extracting translation
            translation(a,1:3) = T(4,1:3); %20230416

            % Extracting Euler angles
            sy = sqrt(T(1,1)^2 + T(2,1)^2);
            if sy > 1e-6
                thetaX(a,1) = rad2deg(atan2(T(3,2), T(3,3)));
                thetaY(a,1) = rad2deg(atan2(-T(3,1), sy));
                thetaZ(a,1) = rad2deg(atan2(T(2,1), T(1,1)));
            else
                thetaX(a,1) = rad2deg(atan2(-T(2,3), T(2,2)));
                thetaY(a,1) = rad2deg(atan2(-T(3,1), sy));
                thetaZ(a,1) = 0;
            end

        end
    catch
    end


    dateTime(a) = datenum(files_temp2{a}(1:19),'yyyy-mm-dd_HH-MM-SS');
    if dateTime(a) > datenum('2022-04-30_23-00-00','yyyy-mm-dd_HH-MM-SS') % mod 20230424
        RMSE(a) = NaN;
        dateTime(a) = NaN;
    end

end

