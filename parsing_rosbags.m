clear all;
bagreader = rosbagreader('2021-11-20_21-01-32.bag');
msgs = readMessages(bagreader);

a = 1;
tempData3 = [];
while a < height(bagreader.MessageList)
    tempData        = msgs{a,1}.Data;
    nMeasurements   = length(tempData)./18;
    idx             = 1:18:length(tempData);
    
    for b = 1:nMeasurements % this isn't correct
        if b < nMeasurements
            tempData2(b,:)      = transpose(tempData(idx(b):idx(b+1)-1));
        else
           tempData2(b,:)       = transpose(tempData(idx(b):length(tempData))); 
        end
    end
    
    tempData3 = [tempData3; tempData2];
    clear tempData2 tempData nMeasurements idx
    a = a + 1;
end