%**************************************************************************
% Inputs:
%  IBItable:
%   IBItable(1,:): timestamp of IBI [sec]
%   IBItable(2,:): IBI [sec]
%  medianPar:
%   If $|IBI_{t_n} - IBI_{median}| > IBI_{median} \times medianPar$ is satisfied,
%   $IBI_{t_n}$ is removed as an outlier.
%  frames2Use:
%   frames2Use is $ 1\times2$ vector. IBI whoes timestamp satisfy $ frames2Use(1) <
%   IBI_{timeStamp} < frames2Use(end)$ could be removed.
%
% Outputs:
%  outPut_IBItable: the pure result of outlier removal
%  IBItable_for_RMSSD: the result of outlier removal for RMSSD estimation
%
% Last Update: 2019
%**************************************************************************
function [outPut_IBItable,IBItable_for_RMSSD,numOut] = removeOutIBImedian(IBItable,medianPar,frames2Use)

if iscell(IBItable)
    outPut_IBItable = cell(1,length(IBItable));
    for i = 1:length(IBItable)
        [outPut_IBItable{1,i},IBItable_for_RMSSD(1,i),numOut] = helper(IBItable{1,i},medianPar);
    end
else
    if nargin==2
        [outPut_IBItable,IBItable_for_RMSSD,numOut] = helper(IBItable,medianPar);
    elseif nargin == 3
        
        for i = 1:length(frames2Use)
            IBIidx = frames2Use{1,i}(1) < IBItable(1,:) & IBItable(1,:) < frames2Use{1,i}(end);
            [outPut_IBItable{1,i},IBItable_for_RMSSD{1,i},numOut{1,i}] = helper(IBItable(:,IBIidx),medianPar);
        end
        outPut_IBItable = cell2mat(outPut_IBItable);
        IBItable_for_RMSSD = cell2mat(IBItable_for_RMSSD);
        numOut = cell2mat(numOut);
    end
end
end
function [IBItable,IBItable_for_RMSSD,numOut] = helper(IBItable,medianPar)
median_IBI = median(IBItable(2,:));
inliear_IBI=medianPar*median_IBI;
idx = (IBItable(2,:) > median_IBI+inliear_IBI) | (IBItable(2,:) < median_IBI-inliear_IBI);
IBItable_for_RMSSD = IBItable;
IBItable(:,idx) = [];
IBItable_for_RMSSD(:,idx) = 0;
numOut = [sum(idx),length(idx)];

end

