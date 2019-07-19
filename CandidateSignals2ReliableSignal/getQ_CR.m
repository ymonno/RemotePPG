%**************************************************************************
% This function calculates Q_CR. 'a' is the amplitude of the highest peak
% in SPD and 'b' is that of the second largest one.
%**************************************************************************
function [Q_CR] = getQ_CR(pxxEst)
pks_pxx = findpeaks(pxxEst);
[a,tempIdx] = max(pks_pxx);
pks_pxx(tempIdx) = [];
b = max(pks_pxx);
Q_CR = a/b;
end