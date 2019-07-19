%**************************************************************************
% Inputs:
%  signal: BVP signal (contact PPG or imaging PPG)
%  Fs: sampling rate of the signal [Hz]
%  time: timestamp of the signal [sec]
%
% Outputs:
%  Q_CR, Q_SNR and Q_PHV: selected signals with each metric xx.MetricValue:
%  the value of the metric
%   xx.Signal: selected BVP with the metric
%   xx.IBI: IBI which is directly calculated with xx.Signal
%   xx.IBI_removedOutlier: IBI after applying outlier removal to xx.IBI
%   xx.AverageHR: average heart rate derived by 60/mean(xx.IBI_removedOutlier)
%
%  IBItable:
%   IBItable(1,:): timestamp of IBI [sec]
%   IBItable(2,:): IBI [sec]
%  IBI_removedOut: result of outlier removal
%  RMSSD: Root Mean Squared Sucsessive Difference
%
% Last Update: July 17, 2019
%**************************************************************************
function [Q_CR, Q_SNR, Q_PHV, IBItable, IBI_removedOut, RMSSD] = signal2Metric_and_IBI(signal,Fs,time)

% parameter setting
% time = 1/Fs:1/Fs:length(signal)/Fs;
MinPeakDistance = 60/240; % maximum heart rate assumed to be 240 bpm.
MinPeakHeight = 0; % all heartbeat peaks are assumed to be non-negative
medianPar = 0.2; % if |IBI_{t_n} - IBI_{median}| > IBI_{median} * 0.2(medianPar)
% is satisfied, IBI_{t_n} is removed as an outlier.
freqRange_width = 0.01;freqRange = 0.6:freqRange_width:4; % frequency range of typical human heart rates.

% calculate reliabilty metric
[signal]=Normalize_MeanPeakHeight(signal,time,MinPeakDistance,MinPeakHeight); % normalize peak height with mean of peak height
[pks,locs] = findpeaks(signal,time,'MinPeakDistance',MinPeakDistance,'MinPeakHeight',MinPeakHeight);
[pxxEst,~] = pwelch(signal,length(signal),[],freqRange,Fs);
% calculate Q_CR
[Q_CR] = getQ_CR(pxxEst);
% calculate Q_SNR
[Q_SNR] = getQ_SNR(pxxEst, freqRange_width, freqRange);
% calculate Q_PHV
Q_PHV = var(pks);

% calculate IBI
[IBItable] = getIBI(locs); % calculate IBI
[IBI_removedOut,IBI_removedOut_for_RMSSD,~] = removeOutIBImedian(IBItable,medianPar); % outlier removal
[RMSSD] = getRMSSD(IBI_removedOut_for_RMSSD); % calculate RMSSD

end

