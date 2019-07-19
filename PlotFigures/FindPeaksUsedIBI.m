function [idx] = FindPeaksUsedIBI(IBI_time,time)
idx = [];
for i = 1: length(IBI_time)
    idx_temp = find(time ==IBI_time(i));
    idx = [idx idx_temp];
end
end