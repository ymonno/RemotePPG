%**************************************************************************
% Count the number of components in the dataMatrix whose error is
% less than a thresthold.
%
% Inputs
%  dataMatrics: target data matrics
%  x_Vector: error threshold
%
% Outputs
%  successRatioVector:
%  successRatioVector(1,x)=count(dataMatrics < x_Vector(1,x))/count(dataMatrix)
%
% Last Update: July 18, 2019
%**************************************************************************
function [successRatioVector] = successRatio(x_Vector,dataMatrics)

if iscell(dataMatrics)
    dataMatrics = cell2mat(dataMatrics);
end
i_max = length(x_Vector);
successRatioVector = (-1)*ones(1,i_max);
[m,n] = size(dataMatrics);
numElement = m*n;
for i = 1:i_max
    idx =  dataMatrics<=x_Vector(1,i);
    successRatioVector(1,i) = sum(sum(idx))/numElement;
end

end