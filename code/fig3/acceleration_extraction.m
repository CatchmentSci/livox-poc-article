
clear listingName
listing         = dir(accelerometer_data);

for a = 1:length(listing)
    listingName(a,1) = cellstr(listing(a).name);
end

listingName = listingName(3:end);
files_temp  = cellfun(@(v)datenum(v,'yyyymmdd_HHMMSS'),listingName,'UniformOutput',false);
uc_dn       = cell2mat(files_temp) ;

for a = 1:length(listingName)
    tempTable   = readtable([accelerometer_data char(listingName(a))], 'ReadVariableNames',false);
    tempTable   = cell2mat(table2cell(tempTable));

    % calculate total average acceleration
    if ~isempty(tempTable)
        acceleration = sqrt(tempTable(:,2).^2 ...
            + tempTable(:,3).^2 ...
            + tempTable(:,4).^2);

        fs = 200; % sample frequency [Hz]
        [y, ~] = bandpass(acceleration(2:end),[30 80],fs); % 100 is ignored
        noisy(a,1) = rms(y);

    else
        acceleration = NaN;
        noisy(a,1) = NaN;
    end

end

%% FFT plots
fft_plot = 0;
if fft_plot == 1
    Fs = 1;
    T = 1/Fs;
    L = length(noisy);
    t = (0:L-1)*T;

    f = Fs*(0:(L/2))/L;
    Y = fft(acceleration);
    Y(1) = [];
    power = abs(Y(1:L/2)).^2;
    nyquist = Fs/2;
    freq = (1:L/2)/(L/2)*nyquist;
    figure(); hold on;
    plot(freq,power), grid on
end