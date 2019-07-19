%**************************************************************************
% Inputs
%  cPPGFileName: matfile name which contains contact PPG sensor data
%  (full path or relative path)
%  selectedSignal: Q_CR, Q_SNR, or Q_PHV
%
% Outputs
%  ADofIBI: absolute difference between estimated and reference IBIs
%
% Last Update: July 18, 2019
%**************************************************************************
function [ADofIBI] = getADofIBI(cPPGFileName, selectedSignal)

% load contact PPG peak location
s = load(cPPGFileName,'locsA');
cPPG.locs = s.locsA;
clear s

% calculate IBI of contact PPG
cPPG.IBI = getIBI(cPPG.locs);


% calculate absolute difference of IBIs
selectedSignal.pchip = interp1(selectedSignal.IBI_removedOutlier(1,:),selectedSignal.IBI_removedOutlier(2,:),cPPG.IBI(1,:),'pchip',-Inf);
cPPG.IBI(:,selectedSignal.pchip==-Inf) = [];
selectedSignal.pchip(:,selectedSignal.pchip==-Inf) = [];
ADofIBI = abs(selectedSignal.pchip-cPPG.IBI(2,:));

end