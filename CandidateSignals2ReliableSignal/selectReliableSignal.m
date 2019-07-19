%**************************************************************************
% This code selects the most reliable BVP signal with Q_CR, Q_SNR or Q_PHV
% reliability metric.
% 'candidateSignalsData' contains candidate BVP signals in cell(1,x).
%
% Inputs:
%  bvpCandidates: BVP candidates
%  frameRate: framerate of the movie
%
% Outputs:
%  Q_CR, Q_SNR and Q_PHV: selected signals with each metric xx.MetricValue:
%  the value of the metric
%   xx.Signal: selected BVP with the metric
%   xx.IBI: IBI which is directly calculated with xx.Signal
%   xx.IBI_removedOutlier: IBI after applying outlier removal to xx.IBI
%   xx.AverageHR: average heart rate derived by 60/mean(xx.IBI_removedOutlier)
%
% Last Update: July 18, 2019
%**************************************************************************
function [Q_CR,Q_SNR,Q_PHV] = selectReliableSignal(bvpCandidates,frameRate,time)

NumSignals = length(bvpCandidates);
Q_CRTable = zeros(1,NumSignals);
Q_SNRTable = zeros(1,NumSignals);
Q_PHVTable = zeros(1,NumSignals);
IBITable = cell(1,NumSignals);
IBI_removedOutTable = cell(1,NumSignals);
RMSSDTable = zeros(1,NumSignals);

for i = 1:NumSignals
    % calculate each metric and IBIs for each candidate BVP signal
    [Q_CRTable(1,i), Q_SNRTable(1,i), Q_PHVTable(1,i), IBITable{1,i}, IBI_removedOutTable{1,i}, RMSSDTable(1,i)] = signal2Metric_and_IBI(bvpCandidates{1,i}, frameRate,time);
end

% select the most reliable BVP signal with Q_CR (the larger, the better)
[Q_CR.MetricValue,Q_CR.Signal,Q_CR.IBI,Q_CR.IBI_removedOutlier,Q_CR.RMSSD,Q_CR.AverageHR] =selectSignalHelper(Q_CRTable,bvpCandidates,IBITable,IBI_removedOutTable,RMSSDTable);

% select the most reliable BVP signal with Q_SNR (the larger, the better)
[Q_SNR.MetricValue,Q_SNR.Signal,Q_SNR.IBI,Q_SNR.IBI_removedOutlier,Q_SNR.RMSSD,Q_SNR.AverageHR] =selectSignalHelper(Q_SNRTable,bvpCandidates,IBITable,IBI_removedOutTable,RMSSDTable);

% select the most reliable BVP signal with Q_PHV (the smaller, the better)
[Q_PHV.MetricValue,Q_PHV.Signal,Q_PHV.IBI,Q_PHV.IBI_removedOutlier,Q_PHV.RMSSD,Q_PHV.AverageHR] =selectSignalHelper(1./Q_PHVTable,bvpCandidates,IBITable,IBI_removedOutTable,RMSSDTable);

end

function [MetricValue,Signal,IBI,IBI_removedOutlier,RMSSD,AverageHR] =selectSignalHelper(metric,CandidateSignalsData,IBITable,IBI_removedOutTable,RMSSDTable)
[MetricValue,idx] = max(metric);
Signal = CandidateSignalsData{idx};
IBI = IBITable{idx};
IBI_removedOutlier = IBI_removedOutTable{idx};
RMSSD = RMSSDTable(idx);
AverageHR = 60/mean(IBI_removedOutlier(2,:));
end

