%% Estimates the rigid transform between 2D Points

% Get from FileExgange
% http://www.mathworks.com/matlabcentral/fileexchange/48287-rigid-transform-estimation/content/computeRigidTransformation.m

% 13/05/2019
function [ transformation ] = computeRigidTransformation( points1, points2 )
%COMPUTERIGIDTRANSFORMATION Computers a rigid transformation from points1
%to points2
%   This functions assumes that all points are inliers and uses SVD to
%   compute the best transformation. 

    nPoints = size(points1, 1);
    dimension = size(points1, 2);
    
    centroid1 = sum(points1, 1)./nPoints;
    centroid2 = sum(points2, 1)./nPoints;
    
    centered1 = points1 - repmat(centroid1, nPoints, 1);
    centered2 = points2 - repmat(centroid2, nPoints, 1);
    
    W = eye(nPoints, nPoints);
    
    S = centered1' * W * centered2;
    
    [U, Sigma, V] = svd(S);
    
    M = eye(dimension, dimension);
    M(dimension, dimension) = det(V*U');
    
    R = V * M * U';
    
    t = centroid2' - R*centroid1';
    
    transformation = eye(3,3);
    transformation(1:2, 1:2) = R;
    transformation(1:2, 3) = t;

end

