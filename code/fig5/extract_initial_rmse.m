
listing         = dir(initial_icp_logs);

for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(3:end);
files_temp  = cellfun(@(v)v(1:19),listingName,'UniformOutput',false);
uc          = unique(files_temp) ;

% internal or external alignment?
if internal == 1
    stringIn = '_initial_icp_logfile.txt';
else
    stringIn = '_scan02_CROPPED1_MERGED_logfile.txt';
end

files_temp2  = cellfun(@(uc)[uc stringIn],files_temp,'UniformOutput',false);
uc          = unique(files_temp) ;
files_temp2 = uc;

RMSE(1:numel(files_temp2),:) = NaN;
dateTime(1:numel(files_temp2),:) = NaN;
for a = 2:length(files_temp2)
    try
        tempTable   = readtable([initial_icp_logs char(files_temp2(a)) stringIn], 'ReadVariableNames',false);
        tempTable   = table2cell(tempTable);

        if internal ~=1
            index       = cellfun(@(x) contains(x, 'RMS'), tempTable(:,3));
        else
            index       = cellfun(@(x) contains(x, 'RMS'), tempTable);
        end

        if numel(tempTable(index)) > 0
            if internal ~= 1
                RMScells    = tempTable(index,4);
                RMSE(a)     = str2double(RMScells);
            else
                RMScells    = tempTable(index);
                RMSE(a)     = str2double(regexp(RMScells{1}, '(?<=RMS: )\d+(\.\d+)?', 'match'));
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


