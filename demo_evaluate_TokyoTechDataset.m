%**************************************************************************
% Copyright (C) 2019, Yuichiro MAKI, all rights reserved.
%  Do not redistribute without permission.
%  Strictly for academic and non-commerial purpose only.
%  Use at your own risk.
%
% Please cite the following paper if you use this code.
%  Yuichiro Maki, Yusuke Monno, Kazunori Yoshizaki, Masayuki Tanaka, and
%  Masatoshi Okutomi, "Inter-Beat Interval Estimation from Facial Video
%  Based on Reliability of BVP Signals," International Conference of the
%  IEEE Engineering in Medicine and Biology Society (EMBC), 2019.
%
% Contact:
%  vital-sensing@ok.sc.e.titech.ac.jp
%  Vital Sensing Group, Okutomi-Tanaka Lab., Tokyo Institute of Technology.
%
% Last Update: July 18, 2019
%**************************************************************************
%
% Setup:
% Please put Tokyo Tech Remote PPG Dataset at /TokyoTechDataset.
% *************************************************************************

% path setting
videoFolderName = 'TokyoTechDataset\01\30fps';
cPPGFileName = 'TokyoTechDataset\01\contactPPG.mat';
frameRate = 30;

p = mfilename('fullpath');
[codeRootDirec,] = fileparts(p);
addpath(genpath(codeRootDirec))

% video name
list = dir(fullfile(videoFolderName,'*.avi'));
% vector of error theresthold
x_vectorIBI = [0.01:0.01:0.2];

% loop for nine 20 seconds sequences for one subject
for i = 1:9
    if i == 1
        % get candidate BVP signals from random face sampling based ICA method
        [bvpCandidates,frameRate,time] = getCandidateSignals_AllFrame(fullfile(videoFolderName,list(i).name),0,0,20-1/frameRate);
        % select the most rerianble signal with each metric
        [Q_CR,Q_SNR,Q_PHV] = selectReliableSignal(bvpCandidates,frameRate,time);
    else
        % get candidate BVP signals from random face sampling based ICA method
        [bvpCandidates,frameRate,time] = getCandidateSignals_AllFrame(fullfile(videoFolderName,list(i).name),0,0,20-1/frameRate);
        % select the most rerianble signal with each metric
        [Q_CRtemp,Q_SNRtemp,Q_PHVtemp] = selectReliableSignal(bvpCandidates,frameRate,time);
        
        % modify timestamp
        [Q_CR] = modifyTimeStamp(Q_CRtemp,i,Q_CR);
        [Q_SNR] = modifyTimeStamp(Q_SNRtemp,i,Q_SNR);
        [Q_PHV] = modifyTimeStamp(Q_PHVtemp,i,Q_PHV);
    end
    disp(['Sequence ',num2str(i),' is finished'])
end

[Q_CR.ADofIBI] = getADofIBI(cPPGFileName, Q_CR);
[Q_SNR.ADofIBI] = getADofIBI(cPPGFileName, Q_SNR);
[Q_PHV.ADofIBI] = getADofIBI(cPPGFileName, Q_PHV);

[f] = successRatioGraph({'Q_{CR}','Q_{SNR}','Q_{PHV}'},{Q_CR.ADofIBI,Q_SNR.ADofIBI,Q_PHV.ADofIBI},x_vectorIBI);
save('resultDemo_evaluate_TokyoTechDataset','Q_CR','Q_SNR','Q_PHV')

function [selectedSignal] = modifyTimeStamp(selectedSignaltemp,i,selectedSignal)
selectedSignal.IBI = [selectedSignal.IBI, selectedSignaltemp.IBI+[20*(i-1)*ones(1,length(selectedSignaltemp.IBI(1,:)));zeros(1,length(selectedSignaltemp.IBI(1,:)))]];
selectedSignal.IBI_removedOutlier = [selectedSignal.IBI_removedOutlier, selectedSignaltemp.IBI_removedOutlier + [20*(i-1)*ones(1,length(selectedSignaltemp.IBI_removedOutlier(1,:)));zeros(1,length(selectedSignaltemp.IBI_removedOutlier(1,:)))]];
selectedSignal.Signal = [selectedSignal.Signal, selectedSignaltemp.Signal];
selectedSignal.RMSSD = [selectedSignal.RMSSD, selectedSignaltemp.RMSSD];
end

