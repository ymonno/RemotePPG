%**************************************************************************
% Find the side (plus or minus) of BVP signals
%**************************************************************************
function [icasigOUT,side] = findSide(icasig,traces,lambda)
idx = 0;
side = 0;

traces(1,:) = detrendingFilter(traces(1,:)',lambda)';
traces(2,:) = detrendingFilter(traces(2,:)',lambda)';

[acor,lag] = xcorr(icasig,traces(1,:));
[~,lagRGB{1,1}] = findpeaks(acor,lag,'SortStr','descend');
[acor,lag] = xcorr((-1).*icasig,traces(1,:));
[~,lagRGB{1,2}] = findpeaks(acor,lag,'SortStr','descend');
if(min(abs(lagRGB{1,1})>min(abs(lagRGB{1,2}))))
    icasigOUT = icasig.*(-1);
    idx = 1;
else
    icasigOUT = icasig;
end
[acor,lag] = xcorr(icasig,traces(2,:));
[~,lagNIR{1,1}] = findpeaks(acor,lag,'SortStr','descend');
[acor,lag] = xcorr((-1).*icasig,traces(2,:));
[~,lagNIR{1,2}] = findpeaks(acor,lag,'SortStr','descend');
if(min(abs(lagNIR{1,1})>min(abs(lagNIR{1,2}))))
    if(idx == 0)
        side =-1;
    end
else
    if(idx ==1)
        side = -1;
    end
end

end