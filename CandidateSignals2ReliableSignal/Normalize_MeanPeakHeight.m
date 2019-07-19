function [dataout]=Normalize_MeanPeakHeight(data,time,MinPeakDistance,MinPeakHeight)
data = data-mean(data); % Set mean of signal as zero.
[pks,~] = findpeaks(data,time,'MinPeakDistance',MinPeakDistance,'MinPeakHeight',MinPeakHeight);
dataout = data./mean(pks);
end