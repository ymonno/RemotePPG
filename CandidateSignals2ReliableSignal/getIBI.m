%**************************************************************************
% Input:
%  locs: timestamps of peaks [sec]
%
% Outputs:
%  IBItable:
%   IBItable(1,:): timestamp of IBI [sec]
%   IBItable(2,:): IBI [sec]
%
% Last Update: July 17, 2019
%**************************************************************************
function [IBItable] = getIBI(locs)
LocsShift = circshift(locs,1);
IBI = locs-LocsShift;
IBItable(2,:) = IBI(2:end);
IBItable(1,:) = locs(2:end);
end