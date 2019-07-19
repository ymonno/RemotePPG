function [data]=normalizecPPG(data)
% average will be zero and normalize with maximum amplitude
data = data-mean(data);
data = data./max(data);
end