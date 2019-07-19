%**************************************************************************
% This function calculates Q_SNR
%**************************************************************************
function [Q_SNR] = getQ_SNR(pxxEst, freqRange_width, freqRange)
SNR_width = 20/freqRange_width;
[~,idx] = max(pxxEst);
% Q_SNR is defined as the following.
% $$Q_{SNR} = \frac{\int_{f_a-d}^{f_a+d} \hat{P}_f df + \int_{2f_a-2d}^{2f_a+2d} \hat{P}_f df}{\int_{\Omega} \hat{P}_f df - \left(\int_{f_a-d}^{f_a+d} \hat{P}_f df + \int_{2f_a-2d}^{2f_a+2d} \hat{P}_f df\right)}$$
if 2*idx - SNR_width*freqRange_width<0
    signal_power = 0;
else
    signal_power = sum(pxxEst(max(round(idx - SNR_width*freqRange_width/2),1):round(idx + SNR_width*freqRange_width/2)))+sum(pxxEst(min(length(freqRange),round((2*idx+freqRange(1)/freqRange_width) - SNR_width*freqRange_width)):min(length(freqRange),round((2*idx+freqRange(1)/freqRange_width)) + SNR_width*freqRange_width)));
end
Q_SNR = signal_power/(sum(pxxEst)-signal_power);
end