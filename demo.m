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
% Last Update: July 17, 2019
%**************************************************************************

% path setting
p = mfilename('fullpath');
[codeRootDirec,] = fileparts(p);
frameRate = 30;

addpath(genpath(codeRootDirec));
VideoFileName = fullfile(codeRootDirec,'Video',strcat('sample', num2str(frameRate), '.avi'));
[direc,~] = fileparts(VideoFileName);

if ~exist(VideoFileName,'file')
    disp(['Sample video does not exist.'  newline 'Please run "setupIBIestimation()"'])
    return
end

% get candidate BVP signals from the random face patch sampling-based method
isDisplayFacialLandmark = 1;startTime = 0;endTime = 20-1/frameRate; % parameter setting
[CandidateSignalsData,frameRate,time] = getCandidateSignals_AllFrame(VideoFileName,isDisplayFacialLandmark,startTime,endTime);

% select the most reliable BVP signal with each reliability metric
[Q_CR,Q_SNR,Q_PHV] = selectReliableSignal(CandidateSignalsData,frameRate,time);

% prosess reference contact PPG sensor data
load(fullfile(direc,'PPGdata'))
PPGsignal = normalizecPPG(PPGsignal);
[IBIPPG] = getIBI(locsPPG);

% plot figures
plotFigures(Q_CR,Q_SNR,Q_PHV,frameRate,IBIPPG,PPGsignal,timePPG)
str = sprintf('Reference average HR is %1f\nEstimated average HR is Q_{CR}:%1f, Q_{SNR}:%1f, and Q_{PHV}:%1f',60/mean(IBIPPG(2,:)),Q_CR.AverageHR,Q_SNR.AverageHR,Q_PHV.AverageHR);
disp(str)

save('resultDemo','Q_CR','Q_SNR','Q_PHV')
