function [RMSSD] = getRMSSD(IBItable)
SD = [];
for i = 1:length(IBItable)-1
    if (IBItable(2,i)*IBItable(2,i+1)~=0) % if IBI had been regarded as an outlier, we dont calculate RMSSD with the IBI.
        SD = [SD,(IBItable(2,i)-IBItable(2,i+1))^2];
    end
end
RMSSD = sqrt(mean(SD));
end