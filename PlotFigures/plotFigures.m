function plotFigures(Q_CR,Q_SNR,Q_PHV,frameRate,IBIPPG,PPGsignal,timePPG)

fntSize = 12;
% BVP signal
lineWidth = 2;
time = 1/frameRate:1/frameRate:length(Q_PHV.Signal)/frameRate;
BVPsignalPlot(time,Q_CR.Signal,PPGsignal,timePPG,Q_CR.IBI_removedOutlier,IBIPPG,'Q_{CR}',fntSize,lineWidth)
BVPsignalPlot(time,Q_SNR.Signal,PPGsignal,timePPG,Q_SNR.IBI_removedOutlier,IBIPPG,'Q_{SNR}',fntSize,lineWidth)
BVPsignalPlot(time,Q_PHV.Signal,PPGsignal,timePPG,Q_PHV.IBI_removedOutlier,IBIPPG,'Q_{PHV}',fntSize,lineWidth)
% IBI
lineWidth = 3;
IBIplot(Q_CR.IBI_removedOutlier,IBIPPG,'Q_{CR}',fntSize,lineWidth)
IBIplot(Q_SNR.IBI_removedOutlier,IBIPPG,'Q_{SNR}',fntSize,lineWidth)
IBIplot(Q_PHV.IBI_removedOutlier,IBIPPG,'Q_{PHV}',fntSize,lineWidth)

end